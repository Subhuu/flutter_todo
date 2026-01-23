import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double opacity;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.blur = 10,
    this.opacity = 0.2, // Default opacity for simple glass, can override
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    // Detect theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive colors
    final baseColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark ? Colors.black : Colors.grey;

    // Adjust defaults if not manually overridden (somewhat)
    // We stick to the passed opacity mostly, but change the base color logic

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // Key change: In light mode, white glass works but black/grey glass might be better?
            // "Glass" usually implies whiteish.
            // Let's keep it white-based for now but maybe darker in light mode?
            // Actually, for Glassmorphism on colorful backgrounds:
            // Dark Mode: White glass (opacity 0.1-0.2)
            // Light Mode: White glass (opacity 0.4-0.6) or Black glass?
            // Let's try White glass for both but adjusting border/shadow
            color: isDark
                ? Colors.white.withValues(alpha: opacity)
                : Colors.white.withValues(
                    alpha: 0.6,
                  ), // higher opacity in light mode

            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(
                      alpha: 0.8,
                    ), // stronger border in light
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: isDark ? 0.1 : 0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
