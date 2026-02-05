class StudentModel {
  final int? id;
  final String email;
  final String studentCode;
  final bool hasVoted;
  final String? votedAt;
  final int? votedCandidateId;

  StudentModel({
    this.id,
    required this.email,
    required this.studentCode,
    this.hasVoted = false,
    this.votedAt,
    this.votedCandidateId,
  });

  // Convertir de Map a StudentModel (desde BD)
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as int?,
      email: map['email'] as String,
      studentCode: map['student_code'] as String,
      hasVoted: (map['has_voted'] as int) == 1,
      votedAt: map['voted_at'] as String?,
      votedCandidateId: map['voted_candidate_id'] as int?,
    );
  }

  // Convertir de StudentModel a Map (para BD)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'student_code': studentCode,
      'has_voted': hasVoted ? 1 : 0,
      'voted_at': votedAt,
      'voted_candidate_id': votedCandidateId,
    };
  }

  // Método copyWith para crear copias con modificaciones
  StudentModel copyWith({
    int? id,
    String? email,
    String? studentCode,
    bool? hasVoted,
    String? votedAt,
    int? votedCandidateId,
  }) {
    return StudentModel(
      id: id ?? this.id,
      email: email ?? this.email,
      studentCode: studentCode ?? this.studentCode,
      hasVoted: hasVoted ?? this.hasVoted,
      votedAt: votedAt ?? this.votedAt,
      votedCandidateId: votedCandidateId ?? this.votedCandidateId,
    );
  }

  @override
  String toString() {
    return 'StudentModel(id: $id, email: $email, studentCode: $studentCode, hasVoted: $hasVoted)';
  }
}
