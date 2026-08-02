import 'package:ai_teacher_phase1_livekit/src/presentation/livekit_spike_binding.dart';
import 'package:ai_teacher_phase1_livekit/src/presentation/livekit_spike_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Phase1SpikeApp extends StatelessWidget {
  const Phase1SpikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Teacher Phase 1',
      debugShowCheckedModeBanner: false,
      initialBinding: LiveKitSpikeBinding(),
      home: const LiveKitSpikePage(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4AE0),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF090D1B),
      ),
    );
  }
}
