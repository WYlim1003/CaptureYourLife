import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Anime-style logo that draws itself left-to-right like a neon pen,
/// with a glowing color trail and no visible background.
///
/// The logo PNG has a white/cream background which is knocked out
/// at render-time using [ColorFiltered] with a luminance-invert matrix,
/// making it work seamlessly on any dark background.
class AnimatedLogo extends StatefulWidget {
  final double width;
  final double height;

  const AnimatedLogo({
    super.key,
    this.width = 280,
    this.height = 160,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _reveal;
  late Animation<double> _glowOpacity;
  late Animation<double> _sparkleScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // Main left-to-right reveal — eases in like a pen gaining momentum
    _reveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.88, curve: Curves.easeInOutSine),
    );

    // Glow fades out as drawing completes
    _glowOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
      ),
    );

    // Sparkle at the pen head pulses slightly
    _sparkleScale = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(
        parent: _controller,
        // Oscillates during the draw phase
        curve: const Interval(0.0, 0.88, curve: Curves.elasticInOut),
      ),
    );

    _controller.forward();
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
        final progress = _reveal.value;
        final glowAlpha = _glowOpacity.value;
        final headX = widget.width * progress;

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Revealed logo (white bg knocked out) ──────────────
              ClipRect(
                clipper: _HorizontalRevealClipper(progress),
                child: child,
              ),

              // ── Wide ambient glow behind the pen head ─────────────
              if (progress > 0.01 && progress < 0.99)
                Positioned(
                  left: headX - 30,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: (glowAlpha * 0.45).clamp(0.0, 1.0),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            AppColors.primaryColor.withValues(alpha: 0.25),
                            AppColors.primaryLight.withValues(alpha: 0.35),
                            AppColors.primaryColor.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Sharp neon pen-stroke line ────────────────────────
              if (progress > 0.01 && progress < 0.99)
                Positioned(
                  left: headX - 2,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: glowAlpha.clamp(0.0, 1.0),
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryLight.withValues(alpha: 0.2),
                            AppColors.primaryLight.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.9),
                            AppColors.primaryLight.withValues(alpha: 0.95),
                            AppColors.primaryLight.withValues(alpha: 0.2),
                          ],
                        ),
                        boxShadow: [
                          // Inner bright core
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 3,
                            spreadRadius: 0,
                          ),
                          // Mid glow
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.7),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                          // Outer anime bloom
                          BoxShadow(
                            color: AppColors.primaryLight.withValues(alpha: 0.4),
                            blurRadius: 22,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Sparkle dot at pen head ───────────────────────────
              if (progress > 0.01 && progress < 0.99)
                Positioned(
                  left: headX - 6,
                  top: widget.height / 2 - 6,
                  child: Opacity(
                    opacity: (glowAlpha * 0.9).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: _sparkleScale.value,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor,
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(alpha: 0.6),
                              blurRadius: 20,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      // ── Logo with white background knocked out ─────────────────────
      // ColorFilter matrix: turns near-white pixels transparent by
      // multiplying R,G,B channels and using the inverted luminance as alpha.
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          // R  G  B  A  const
          1, 0, 0, 0, 0, // out R
          0, 1, 0, 0, 0, // out G
          0, 0, 1, 0, 0, // out B
          -3, -3, -3, 10, 0, // out A: dark pixels survive, white → transparent
        ]),
        child: Image.asset(
          'assets/images/Logo.png',
          width: widget.width,
          height: widget.height,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.camera_alt,
            size: widget.height * 0.4,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

class _HorizontalRevealClipper extends CustomClipper<Rect> {
  final double progress;

  _HorizontalRevealClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(_HorizontalRevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
