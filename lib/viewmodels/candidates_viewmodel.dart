import 'package:flutter/material.dart';
import '../data/models/candidate_model.dart';
import '../data/repositories/candidate_repository.dart';
import '../core/utils/location_helper.dart';

class CandidatesViewModel extends ChangeNotifier {
  final CandidateRepository _candidateRepository = CandidateRepository();

  // Estado de la UI
  bool _isLoading = false;
  bool _isCheckingLocation = false;
  String? _errorMessage;
  List<CandidateModel> _candidates = [];
  CandidateModel? _selectedCandidate;
  bool _isInUniversity = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isCheckingLocation => _isCheckingLocation;
  String? get errorMessage => _errorMessage;
  List<CandidateModel> get candidates => _candidates;
  CandidateModel? get selectedCandidate => _selectedCandidate;
  bool get isInUniversity => _isInUniversity;

  /// Carga la lista de candidatos desde la base de datos
  Future<void> loadCandidates() async {
    _setLoading(true);
    _clearError();

    try {
      // Cargar desde base de datos
      _candidates = await _candidateRepository.getAllCandidates();

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar candidatos');
      _setLoading(false);
    }
  }

  /// Verifica la ubicación del usuario
  Future<bool> checkLocation() async {
    _isCheckingLocation = true;
    notifyListeners();

    try {
      // Verificar permisos
      final hasPermission = await LocationHelper.checkPermissions();

      if (!hasPermission) {
        final granted = await LocationHelper.requestPermissions();
        if (!granted) {
          _setError('Se requieren permisos de ubicación para votar');
          _isCheckingLocation = false;
          notifyListeners();
          return false;
        }
      }

      // Verificar si está en la universidad
      _isInUniversity = await LocationHelper.isInUniversity();

      if (!_isInUniversity) {
        // Obtener distancia para mostrar al usuario
        final distance = await LocationHelper.getDistanceFromUniversity();
        if (distance != null) {
          final distanceInKm = (distance / 1000).toStringAsFixed(2);
          _setError(
            'Debes estar en la universidad para votar. Estás a $distanceInKm km',
          );
        } else {
          _setError('Debes estar en la universidad para votar');
        }
      }

      _isCheckingLocation = false;
      notifyListeners();
      return _isInUniversity;
    } catch (e) {
      _setError('Error al verificar ubicación');
      _isCheckingLocation = false;
      notifyListeners();
      return false;
    }
  }

  /// Selecciona un candidato
  void selectCandidate(CandidateModel candidate) {
    _selectedCandidate = candidate;
    notifyListeners();
  }

  /// Limpia la selección de candidato
  void clearSelection() {
    _selectedCandidate = null;
    notifyListeners();
  }

  /// Limpia el error
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Establece un mensaje de error
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Establece el estado de carga
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
