import 'dart:math' as math;

import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class VoiceWaveform extends StatefulWidget {
  const VoiceWaveform({super.key, this.barCount = 14, this.height = 22});

  final int barCount;
  final double height;

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List<Widget>.generate(widget.barCount, (int index) {
              final double wave = math.sin(
                (_controller.value * math.pi * 2) + (index * 0.62),
              );
              final double normalized = (wave + 1) / 2;
              final double barHeight = 5 + (normalized * (widget.height - 5));

              return Container(
                width: 3,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(
                    alpha: index >= widget.barCount - 3 ? 0.58 : 1,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
