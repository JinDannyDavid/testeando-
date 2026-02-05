class CandidateModel {
  final int? id;
  final String name;
  final String proposal;
  final String imageUrl;
  final int voteCount;

  CandidateModel({
    this.id,
    required this.name,
    required this.proposal,
    required this.imageUrl,
    this.voteCount = 0,
  });

  // Convertir de Map a CandidateModel (desde BD)
  factory CandidateModel.fromMap(Map<String, dynamic> map) {
    return CandidateModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      proposal: map['proposal'] as String,
      imageUrl: map['image_url'] as String,
      voteCount: map['vote_count'] as int? ?? 0,
    );
  }

  // Convertir de CandidateModel a Map (para BD)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'proposal': proposal,
      'image_url': imageUrl,
      'vote_count': voteCount,
    };
  }

  // Método copyWith para crear copias con modificaciones
  CandidateModel copyWith({
    int? id,
    String? name,
    String? proposal,
    String? imageUrl,
    int? voteCount,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      proposal: proposal ?? this.proposal,
      imageUrl: imageUrl ?? this.imageUrl,
      voteCount: voteCount ?? this.voteCount,
    );
  }

  // Calcular porcentaje de votos
  double getVotePercentage(int totalVotes) {
    if (totalVotes == 0) return 0.0;
    return (voteCount / totalVotes) * 100;
  }

  @override
  String toString() {
    return 'CandidateModel(id: $id, name: $name, voteCount: $voteCount)';
  }
}
