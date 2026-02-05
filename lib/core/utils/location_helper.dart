import 'package:geolocator/geolocator.dart';

class LocationHelper {
  // Coordenadas de la Universidad Continental (ejemplo - Huancayo)
  // Ajusta estas coordenadas según la ubicación real de tu universidad
  static const double universityLatitude = -12.0653;
  static const double universityLongitude = -75.2049;

  // Radio permitido en metros (500 metros = 0.5 km)
  static const double allowedRadiusInMeters = 500.0;

  /// Verifica si los permisos de ubicación están otorgados
  static Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Solicita permisos de ubicación
  static Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Obtiene la ubicación actual del dispositivo
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      return null;
    }
  }

  /// Calcula la distancia entre dos puntos en metros
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Verifica si el usuario está dentro de la universidad
  static Future<bool> isInUniversity() async {
    try {
      final position = await getCurrentLocation();

      if (position == null) {
        return false;
      }

      final distance = calculateDistance(
        lat1: position.latitude,
        lon1: position.longitude,
        lat2: universityLatitude,
        lon2: universityLongitude,
      );

      return distance <= allowedRadiusInMeters;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la distancia actual desde la universidad
  static Future<double?> getDistanceFromUniversity() async {
    try {
      final position = await getCurrentLocation();

      if (position == null) {
        return null;
      }

      return calculateDistance(
        lat1: position.latitude,
        lon1: position.longitude,
        lat2: universityLatitude,
        lon2: universityLongitude,
      );
    } catch (e) {
      return null;
    }
  }

  /// Abre la configuración de ubicación del dispositivo
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Abre la configuración de la aplicación
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
