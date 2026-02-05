import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/candidate_model.dart';

class ResultBarChart extends StatelessWidget {
  final CandidateModel candidate;
  final double percentage;
  final int totalVotes;
  final bool isWinner;
  final int rank;

  const ResultBarChart({
    super.key,
    required this.candidate,
    required this.percentage,
    required this.totalVotes,
    this.isWinner = false,
    required this.rank,
  });

  Color get _barColor {
    if (isWinner) return AppColors.success;

    switch (rank) {
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.secondary;
      case 3:
        return AppColors.info;
      default:
        return AppColors.textHint;
    }
  }

  IconData get _rankIcon {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isWinner ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isWinner
            ? const BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar y nombre
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(candidate.imageUrl),
                  backgroundColor: AppColors.divider,
                ),

                const SizedBox(width: 12),

                // Nombre y ranking
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_rankIcon, size: 20, color: _barColor),
                          const SizedBox(width: 4),
                          Text(
                            '#$rank',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _barColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Porcentaje
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _barColor,
                      ),
                    ),
                    Text(
                      '${candidate.voteCount} ${candidate.voteCount == 1 ? 'voto' : 'votos'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Fondo
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  // Barra de progreso
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    height: 32,
                    width:
                        MediaQuery.of(context).size.width * (percentage / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_barColor, _barColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),

            // Medalla de ganador
            if (isWinner && totalVotes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.success, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'GANADOR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
