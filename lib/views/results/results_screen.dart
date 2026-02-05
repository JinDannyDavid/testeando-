import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';
import '../../viewmodels/results_viewmodel.dart';
import 'widgets/result_chart.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ResultsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ResultsViewModel();
    _loadResults();
  }

  Future<void> _loadResults() async {
    await _viewModel.loadResults();
  }

  Future<void> _handleRefresh() async {
    await _viewModel.refreshResults();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ResultsViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.resultsTitle),
          actions: [
            Consumer<ResultsViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: viewModel.isLoading ? null : _handleRefresh,
                  tooltip: 'Actualizar resultados',
                );
              },
            ),
          ],
        ),
        body: Consumer<ResultsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return _buildErrorState(viewModel.errorMessage!);
            }

            if (viewModel.candidates.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: CustomScrollView(
                slivers: [
                  // Header con estadísticas generales
                  SliverToBoxAdapter(child: _buildStatsHeader(viewModel)),

                  // Mensaje de ganador o empate
                  if (viewModel.totalVotes > 0)
                    SliverToBoxAdapter(child: _buildWinnerBanner(viewModel)),

                  // Lista de resultados
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final candidate = viewModel.candidates[index];
                        final percentage = viewModel.getPercentage(candidate);
                        final isWinner =
                            viewModel.winner?.id == candidate.id &&
                            !viewModel.hasTie &&
                            viewModel.totalVotes > 0;

                        return ResultBarChart(
                          candidate: candidate,
                          percentage: percentage,
                          totalVotes: viewModel.totalVotes,
                          isWinner: isWinner,
                          rank: index + 1,
                        );
                      }, childCount: viewModel.candidates.length),
                    ),
                  ),

                  // Botón de salir
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text(
                            'Salir',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Espacio al final
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsHeader(ResultsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.poll_rounded, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Resultados de la Votación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.how_to_vote,
                label: 'Total de votos',
                value: '${viewModel.totalVotes}',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.people,
                label: 'Candidatos',
                value: '${viewModel.candidates.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildWinnerBanner(ResultsViewModel viewModel) {
    if (viewModel.hasTie) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.timer, color: AppColors.warning, size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hay un empate en los primeros lugares',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.winner != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withOpacity(0.2),
              AppColors.success.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.success, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Candidato con más votos',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.winner!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 100, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noResults,
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 100, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
