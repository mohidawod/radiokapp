import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية')),
      body: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.8, end: 1.2),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: const Icon(
                Icons.storefront, // شعار المتجر
                size: 100,
                color: Colors.blue,
              ),
            );
          },
          onEnd: () {
            // تعيد الحركة باستمرار
            Future.delayed(
              Duration.zero,
              () => (context as Element).markNeedsBuild(),
            );
          },
        ),
      ),
    );
  }
}
