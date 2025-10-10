import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedLoadingIndicator extends StatefulWidget {
  const AnimatedLoadingIndicator({super.key});

  @override
  State<AnimatedLoadingIndicator> createState() =>
      _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getAnimatedColors(_controller.value),
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon with subtle pulse animation
                Transform.scale(
                  scale:
                      1.0 + (math.sin(_controller.value * 2 * math.pi) * 0.05),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/icon/icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if icon is not found
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.family_restroom,
                              size: 80,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Loading text with fade animation
                Opacity(
                  opacity:
                      0.5 + (math.sin(_controller.value * 2 * math.pi) * 0.5),
                  child: const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getAnimatedColors(double value) {
    // Create a smooth color transition through multiple colors
    final hue = (value * 360) % 360;

    return [
      HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor(),
      HSLColor.fromAHSL(1.0, (hue + 60) % 360, 0.6, 0.6).toColor(),
      HSLColor.fromAHSL(1.0, (hue + 120) % 360, 0.6, 0.5).toColor(),
    ];
  }
}
