class VoteModel {
  final int? id;
  final int studentId;
  final int candidateId;
  final String votedAt;
  final double latitude;
  final double longitude;

  VoteModel({
    this.id,
    required this.studentId,
    required this.candidateId,
    required this.votedAt,
    required this.latitude,
    required this.longitude,
  });

  // Convertir de Map a VoteModel (desde BD)
  factory VoteModel.fromMap(Map<String, dynamic> map) {
    return VoteModel(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      candidateId: map['candidate_id'] as int,
      votedAt: map['voted_at'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }

  // Convertir de VoteModel a Map (para BD)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'candidate_id': candidateId,
      'voted_at': votedAt,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Método copyWith para crear copias con modificaciones
  VoteModel copyWith({
    int? id,
    int? studentId,
    int? candidateId,
    String? votedAt,
    double? latitude,
    double? longitude,
  }) {
    return VoteModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      candidateId: candidateId ?? this.candidateId,
      votedAt: votedAt ?? this.votedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'VoteModel(id: $id, studentId: $studentId, candidateId: $candidateId, votedAt: $votedAt)';
  }
}
