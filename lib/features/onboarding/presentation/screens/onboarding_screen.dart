import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../notifiers/onboarding_notifier.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

const List<OnboardingPageData> onboardingPages = <OnboardingPageData>[
  OnboardingPageData(
    title: 'Your money, in one place',
    description: 'Accounts, balances and movements in a single view.',
  ),
  OnboardingPageData(
    title: 'A smarter experience',
    description: 'Personalized experience and dynamic content.',
  ),
  OnboardingPageData(
    title: 'Stay informed',
    description: 'Notifications and activity as things happen.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == onboardingPages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await ref.read(onboardingProvider.notifier).complete();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.orangeSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_outlined,
                        color: AppColors.orange,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    label: 'Skip onboarding',
                    button: true,
                    container: true,
                    excludeSemantics: true,
                    onTap: _complete,
                    child: TextButton(
                      onPressed: _complete,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: onboardingPages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) =>
                    _OnboardingPage(page: onboardingPages[index]),
              ),
            ),
            _OnboardingProgress(
              current: _currentPage,
              total: onboardingPages.length,
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: _isLastPage
                      ? 'Get started'
                      : 'Next onboarding step',
                  button: true,
                  container: true,
                  excludeSemantics: true,
                  onTap: _isLastPage ? _complete : _next,
                  child: FilledButton(
                    onPressed: _isLastPage ? _complete : _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(
                      _isLastPage ? 'Get started' : 'Next',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});

  final OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            excludeSemantics: true,
            child: Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.12),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 82,
                  color: AppColors.orange,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            page.description,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingProgress extends StatelessWidget {
  const _OnboardingProgress({
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('onboarding_progress'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(total, (index) {
        final isActive = index == current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.orange
                : AppColors.orange.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}