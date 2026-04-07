import 'package:flutter/material.dart';
import 'package:radiokapp/view/main_view.dart';
import 'package:radiokapp/viewmodels/radio_viewmodel.dart';

class WelcomeScreen extends StatelessWidget {
  final RadioViewModel viewModel;

  const WelcomeScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Icon(
                            Icons.graphic_eq_rounded,
                            size: 38,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'إيقاع اللحظة الآن',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(fontSize: 34),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'استمع إلى محطات عربية متنوعة بواجهة خفيفة وسريعة، مع انتقال سلس بين المحطات وحفظ المفضلة بسهولة.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(height: 1.7),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: const [
                            _FeatureChip(
                              icon: Icons.radio_outlined,
                              label: 'محطات عربية',
                            ),
                            _FeatureChip(
                              icon: Icons.favorite_border_rounded,
                              label: 'مفضلة سريعة',
                            ),
                            _FeatureChip(
                              icon: Icons.bolt_rounded,
                              label: 'تشغيل أخف',
                            ),
                          ],
                        ),
                        const SizedBox(height: 34),
                        SizedBox(
                          width: 280,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              viewModel.initialize();
                              Navigator.pushReplacementNamed(
                                context,
                                MainView.routeName,
                              );
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('ابدأ الاستماع'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
