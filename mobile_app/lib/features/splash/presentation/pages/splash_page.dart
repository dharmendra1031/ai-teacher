import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/features/splash/presentation/controllers/splash_controller.dart';
import 'package:ai_teacher/features/splash/presentation/widgets/voice_waveform.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.dark,
              AppColors.darkMid,
              AppColors.darkPurple,
            ],
            stops: <double>[0, 0.52, 1],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const Positioned(
              top: 70,
              right: -54,
              child: _AmbientOrb(
                size: 210,
                color: AppColors.brandBright,
                opacity: 0.28,
              ),
            ),
            const Positioned(
              left: -86,
              bottom: 92,
              child: _AmbientOrb(
                size: 238,
                color: AppColors.blue,
                opacity: 0.18,
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: <Widget>[
                        const Spacer(flex: 3),
                        const _BrandLogo(),
                        const SizedBox(height: 48),
                        const _ProductBadge(),
                        const SizedBox(height: 24),
                        Text(
                          'AI Teacher',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 34,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.1,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Private practice. Real confidence.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFB8C2DE),
                                fontSize: 13,
                                height: 1.5,
                              ),
                        ),
                        const Spacer(flex: 4),
                        const _LoadingPanel(),
                        const SizedBox(height: 24),
                        Text(
                          'Your conversation stays private by default',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF7F8BAA),
                                fontSize: 11,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.brandBright,
            AppColors.blue,
          ],
        ),
        border: Border.all(
          color: const Color(0xFF8190C8).withValues(alpha: 0.72),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.36),
            offset: const Offset(0, 18),
            blurRadius: 44,
          ),
          BoxShadow(
            color: AppColors.brandBright.withValues(alpha: 0.22),
            blurRadius: 36,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFA9B4E8).withValues(alpha: 0.56),
              ),
            ),
          ),
          const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }
}

class _ProductBadge extends StatelessWidget {
  const _ProductBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF6D78A4).withValues(alpha: 0.56),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'REAL-TIME AI SPEAKING',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFFCFD6FF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
            ),
      ),
    );
  }
}

class _LoadingPanel extends GetView<SplashController> {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF7784B4).withValues(alpha: 0.30),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const VoiceWaveform(),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  controller.statusText.value,
                  key: ValueKey<String>(controller.statusText.value),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: opacity),
              blurRadius: 90,
              spreadRadius: 18,
            ),
          ],
        ),
      ),
    );
  }
}
