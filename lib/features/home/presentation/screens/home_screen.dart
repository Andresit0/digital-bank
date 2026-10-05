import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/experience/domain/entities/quick_action_type.dart';
import '../../../../features/experience/presentation/widgets/experience_renderer.dart';
import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/bank_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onExperienceAction(BuildContext context, QuickActionType action) {
    switch (action) {
      case QuickActionType.viewAccounts:
        context.push('/accounts');
      case QuickActionType.viewMovements:
        context.push('/accounts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BankAppBar(title: 'Home'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Welcome back',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your finances, all in one place.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ExperienceRenderer(
                    onAction: (action) => _onExperienceAction(context, action),
                  ),
                  const Text(
                    'Quick access',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/accounts'),
                      icon: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.orange,
                      ),
                      label: const Text(
                        'My accounts',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        alignment: Alignment.centerLeft,
                        side: BorderSide(color: Colors.grey.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
