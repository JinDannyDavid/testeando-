import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';
import '../../data/models/candidate_model.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/vote_viewmodel.dart';

class VoteConfirmationScreen extends StatefulWidget {
  const VoteConfirmationScreen({super.key});

  @override
  State<VoteConfirmationScreen> createState() => _VoteConfirmationScreenState();
}

class _VoteConfirmationScreenState extends State<VoteConfirmationScreen> {
  late VoteViewModel _voteViewModel;
  late LoginViewModel _loginViewModel;

  @override
  void initState() {
    super.initState();
    _voteViewModel = VoteViewModel();
    _loginViewModel = LoginViewModel();
  }

  @override
  void dispose() {
    _voteViewModel.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmVote(CandidateModel candidate) async {
    final student = _loginViewModel.currentStudent;

    if (student == null) {
      _showErrorSnackBar('Error: No se encontró información del estudiante');
      return;
    }

    // Confirmar con el usuario
    final confirmed = await _showConfirmationDialog(candidate);

    if (!confirmed || !mounted) return;

    // Registrar el voto
    final success = await _voteViewModel.submitVote(
      student: student,
      candidate: candidate,
    );

    if (!mounted) return;

    if (success) {
      // Navegar a pantalla de éxito
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.voteSuccess,
        arguments: candidate,
      );
    } else {
      // Mostrar error
      _showErrorSnackBar(
        _voteViewModel.errorMessage ?? 'Error al registrar el voto',
      );
    }
  }

  Future<bool> _showConfirmationDialog(CandidateModel candidate) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 64,
            ),
            title: const Text(AppStrings.confirmTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppStrings.confirmMessage} ${candidate.name}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Esta acción no se puede deshacer.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(AppStrings.cancelButton),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(AppStrings.confirmButton),
              ),
            ],
          ),
        ) ??
        false;
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
    final candidate =
        ModalRoute.of(context)!.settings.arguments as CandidateModel;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VoteViewModel>.value(value: _voteViewModel),
        ChangeNotifierProvider<LoginViewModel>.value(value: _loginViewModel),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Confirmar voto')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Icono de confirmación
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.how_to_vote_rounded,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Título
                      const Text(
                        'Estás a punto de votar por:',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Tarjeta del candidato
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(
                                  candidate.imageUrl,
                                ),
                                backgroundColor: AppColors.divider,
                              ),

                              const SizedBox(height: 16),

                              // Nombre
                              Text(
                                candidate.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 16),

                              // Propuesta
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.lightbulb_outline,
                                          size: 20,
                                          color: AppColors.secondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Propuesta',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.secondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      candidate.proposal,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      textAlign: TextAlign.justify,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Advertencia
                      Card(
                        color: AppColors.warning.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.warning.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.warning,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tu voto es único e irrevocable. Asegúrate de tu elección antes de confirmar.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botones de acción
              Consumer<VoteViewModel>(
                builder: (context, viewModel, child) {
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
                    child: Column(
                      children: [
                        // Botón confirmar
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: viewModel.isSubmitting
                                ? null
                                : () => _handleConfirmVote(candidate),
                            icon: viewModel.isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.check_circle),
                            label: Text(
                              viewModel.isSubmitting
                                  ? 'Registrando voto...'
                                  : AppStrings.confirmButton,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Botón cancelar
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: TextButton(
                            onPressed: viewModel.isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text(
                              AppStrings.cancelButton,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
