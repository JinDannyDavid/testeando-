import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/location_helper.dart';
import '../../viewmodels/candidates_viewmodel.dart';
import 'widgets/candidate_card.dart';

class CandidatesListScreen extends StatefulWidget {
  const CandidatesListScreen({super.key});

  @override
  State<CandidatesListScreen> createState() => _CandidatesListScreenState();
}

class _CandidatesListScreenState extends State<CandidatesListScreen> {
  late CandidatesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CandidatesViewModel();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Cargar candidatos
    await _viewModel.loadCandidates();

    // Verificar ubicación
    await _viewModel.checkLocation();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleVote() async {
    if (_viewModel.selectedCandidate == null) {
      _showErrorSnackBar('Debes seleccionar un candidato');
      return;
    }

    // Verificar ubicación antes de votar
    final isInUniversity = await _viewModel.checkLocation();

    if (!mounted) return;

    if (!isInUniversity) {
      _showLocationErrorDialog();
      return;
    }

    // Navegar a confirmación de voto
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.voteConfirmation,
      arguments: _viewModel.selectedCandidate,
    );

    // Si el voto fue exitoso, mostrar mensaje
    if (result == true && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.voteSuccess);
    }
  }

  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.location_off, color: AppColors.error, size: 64),
        title: const Text('Ubicación requerida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _viewModel.errorMessage ??
                  'Debes estar en la universidad para votar',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Por favor, activa tu GPS y asegúrate de estar dentro del campus universitario.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              LocationHelper.openLocationSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CandidatesViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.candidatesTitle),
          actions: [
            Consumer<CandidatesViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: Icon(
                    viewModel.isInUniversity
                        ? Icons.location_on
                        : Icons.location_off,
                    color: viewModel.isInUniversity
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  onPressed: () => viewModel.checkLocation(),
                  tooltip: viewModel.isInUniversity
                      ? 'Ubicación verificada'
                      : 'Verificar ubicación',
                );
              },
            ),
          ],
        ),
        body: Consumer<CandidatesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.candidates.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                // Header con información
                _buildHeader(viewModel),

                // Lista de candidatos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = viewModel.candidates[index];
                      final isSelected =
                          viewModel.selectedCandidate?.id == candidate.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CandidateCard(
                          candidate: candidate,
                          isSelected: isSelected,
                          onTap: () => viewModel.selectCandidate(candidate),
                        ),
                      );
                    },
                  ),
                ),

                // Botón de votar
                _buildVoteButton(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(CandidatesViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.candidatesSubtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          if (viewModel.isCheckingLocation)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Verificando ubicación...',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(CandidatesViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: viewModel.selectedCandidate != null ? _handleVote : null,
            icon: const Icon(Icons.how_to_vote),
            label: Text(
              viewModel.selectedCandidate != null
                  ? 'Votar por ${viewModel.selectedCandidate!.name.split(' ')[0]}'
                  : AppStrings.voteButton,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 100, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noCandidates,
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
