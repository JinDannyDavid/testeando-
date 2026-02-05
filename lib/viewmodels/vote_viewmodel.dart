import 'package:flutter/material.dart';
import '../data/models/candidate_model.dart';
import '../data/models/student_model.dart';
import '../data/repositories/vote_repository.dart';
import '../core/utils/location_helper.dart';

class VoteViewModel extends ChangeNotifier {
  final VoteRepository _voteRepository = VoteRepository();

  // Estado de la UI
  bool _isSubmitting = false;
  String? _errorMessage;

  // Getters
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  /// Registra el voto
  Future<bool> submitVote({
    required StudentModel student,
    required CandidateModel candidate,
  }) async {
    _setSubmitting(true);
    _clearError();

    try {
      // Obtener ubicación actual
      final position = await LocationHelper.getCurrentLocation();

      if (position == null) {
        _setError('No se pudo obtener la ubicación');
        _setSubmitting(false);
        return false;
      }

      // Verificar que esté en la universidad
      final isInUniversity = await LocationHelper.isInUniversity();

      if (!isInUniversity) {
        _setError('Debes estar en la universidad para votar');
        _setSubmitting(false);
        return false;
      }

      // Registrar el voto
      final success = await _voteRepository.registerVote(
        studentId: student.id!,
        candidateId: candidate.id!,
        votedAt: DateTime.now().toIso8601String(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!success) {
        _setError('Error al registrar el voto');
        _setSubmitting(false);
        return false;
      }

      _setSubmitting(false);
      return true;
    } catch (e) {
      _setError('Error inesperado: ${e.toString()}');
      _setSubmitting(false);
      return false;
    }
  }

  /// Obtiene el total de votos
  Future<int> getTotalVotes() async {
    return await _voteRepository.getTotalVotes();
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

  /// Establece el estado de envío
  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
