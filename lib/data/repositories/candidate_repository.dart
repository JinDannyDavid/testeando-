import '../database/database_helper.dart';
import '../models/candidate_model.dart';

class CandidateRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Obtiene todos los candidatos
  Future<List<CandidateModel>> getAllCandidates() async {
    return await _dbHelper.getAllCandidates();
  }

  /// Obtiene un candidato por ID
  Future<CandidateModel?> getCandidateById(int id) async {
    return await _dbHelper.getCandidateById(id);
  }

  /// Incrementa el contador de votos de un candidato
  Future<bool> incrementVoteCount(int candidateId) async {
    final result = await _dbHelper.updateCandidateVoteCount(candidateId, 1);
    return result > 0;
  }
}
