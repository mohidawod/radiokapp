import 'package:flutter/material.dart';

class AnimatedWave extends StatefulWidget {
  final bool isActive;

  const AnimatedWave({Key? key, required this.isActive}) : super(key: key);

  @override
  State<AnimatedWave> createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<AnimatedWave>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim1;
  late final Animation<double> _anim2;
  late final Animation<double> _anim3;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _anim1 = Tween<double>(begin: 4, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0)),
    );
    _anim2 = Tween<double>(begin: 4, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0)),
    );
    _anim3 = Tween<double>(begin: 4, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBar(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 3,
          height: animation.value,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBar(_anim1),
        const SizedBox(width: 2),
        _buildBar(_anim2),
        const SizedBox(width: 2),
        _buildBar(_anim3),
      ],
    );
  }
}
