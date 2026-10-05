import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../../domain/entities/experience_section.dart';
import '../experience_state.dart';
import '../notifiers/experience_notifier.dart';
import 'promotion_section.dart';
import 'quick_action_section.dart';

class ExperienceRenderer extends ConsumerStatefulWidget {
  const ExperienceRenderer({
    super.key,
    required this.onAction,
    this.onRetry,
  });

  final ValueChanged<QuickActionType> onAction;
  final VoidCallback? onRetry;

  @override
  ConsumerState<ExperienceRenderer> createState() => _ExperienceRendererState();
}

class _ExperienceRendererState extends ConsumerState<ExperienceRenderer> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() => ref.read(experienceProvider.notifier).load());
  }

  void _retry() {
    final onRetry = widget.onRetry;
    if (onRetry != null) {
      onRetry();
    } else {
      ref.read(experienceProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(experienceProvider);

    return switch (state) {
      ExperienceInitial() || ExperienceLoading() => const Padding(
        key: Key('experience_loading'),
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.orange,
            ),
          ),
        ),
      ),
      ExperienceEmpty() => const SizedBox(
        key: Key('experience_fallback'),
        height: 0,
      ),
      ExperienceDegraded() => _ExperienceDegraded(onRetry: _retry),
      ExperienceLoaded(:final definition) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in definition.sections) ...[
            _buildSection(section),
            const SizedBox(height: 14),
          ],
        ],
      ),
    };
  }

  Widget _buildSection(ExperienceSection section) {
    return switch (section) {
      PromotionSection(:final title, :final description) =>
        PromotionSectionWidget(title: title, description: description),
      QuickActionSection(:final label, :final action) =>
        QuickActionSectionWidget(
          label: label,
          action: action,
          onTap: widget.onAction,
        ),
    };
  }
}

class _ExperienceDegraded extends StatelessWidget {
  const _ExperienceDegraded({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('experience_degraded'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Some content is unavailable right now.',
              style: TextStyle(color: AppColors.darkText),
            ),
          ),
          TextButton(
            key: const Key('experience_retry'),
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(color: AppColors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
