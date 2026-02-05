import '../database/database_helper.dart';
import '../models/vote_model.dart';

class VoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Registra un voto completo (transacción)
  Future<bool> registerVote({
    required int studentId,
    required int candidateId,
    required String votedAt,
    required double latitude,
    required double longitude,
  }) async {
    return await _dbHelper.registerVote(
      studentId: studentId,
      candidateId: candidateId,
      votedAt: votedAt,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Obtiene todos los votos
  Future<List<VoteModel>> getAllVotes() async {
    return await _dbHelper.getAllVotes();
  }

  /// Obtiene el total de votos registrados
  Future<int> getTotalVotes() async {
    return await _dbHelper.getTotalVotes();
  }

  /// Obtiene el voto de un estudiante
  Future<VoteModel?> getVoteByStudentId(int studentId) async {
    return await _dbHelper.getVoteByStudentId(studentId);
  }
}
