import 'package:flutter/material.dart';
import '../data/models/candidate_model.dart';
import '../data/repositories/candidate_repository.dart';
import '../data/repositories/vote_repository.dart';

class ResultsViewModel extends ChangeNotifier {
  final CandidateRepository _candidateRepository = CandidateRepository();
  final VoteRepository _voteRepository = VoteRepository();

  // Estado de la UI
  bool _isLoading = false;
  String? _errorMessage;
  List<CandidateModel> _candidates = [];
  int _totalVotes = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CandidateModel> get candidates => _candidates;
  int get totalVotes => _totalVotes;

  // Obtener candidato ganador
  CandidateModel? get winner {
    if (_candidates.isEmpty) return null;

    var sorted = List<CandidateModel>.from(_candidates);
    sorted.sort((a, b) => b.voteCount.compareTo(a.voteCount));

    return sorted.first.voteCount > 0 ? sorted.first : null;
  }

  // Verificar si hay empate
  bool get hasTie {
    if (_candidates.isEmpty || _candidates.length < 2) return false;

    var sorted = List<CandidateModel>.from(_candidates);
    sorted.sort((a, b) => b.voteCount.compareTo(a.voteCount));

    return sorted[0].voteCount > 0 &&
        sorted[0].voteCount == sorted[1].voteCount;
  }

  /// Carga los resultados de la votación
  Future<void> loadResults() async {
    _setLoading(true);
    _clearError();

    try {
      // Cargar candidatos con sus votos
      _candidates = await _candidateRepository.getAllCandidates();

      // Ordenar por votos descendente
      _candidates.sort((a, b) => b.voteCount.compareTo(a.voteCount));

      // Obtener total de votos
      _totalVotes = await _voteRepository.getTotalVotes();

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar resultados');
      _setLoading(false);
    }
  }

  /// Recarga los resultados
  Future<void> refreshResults() async {
    await loadResults();
  }

  /// Obtiene el porcentaje de un candidato
  double getPercentage(CandidateModel candidate) {
    if (_totalVotes == 0) return 0.0;
    return (candidate.voteCount / _totalVotes) * 100;
  }

  /// Obtiene el porcentaje de participación (si se conoce el total de estudiantes)
  double getParticipationRate(int totalStudents) {
    if (totalStudents == 0) return 0.0;
    return (_totalVotes / totalStudents) * 100;
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
