import 'package:flutter/material.dart';

class BouncingWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;

  const BouncingWrapper({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.95, // 5% shrink
  });

  @override
  State<BouncingWrapper> createState() => _BouncingWrapperState();
}

class _BouncingWrapperState extends State<BouncingWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    // Classic dim-on-press effect
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) widget.onTap();
    });
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

