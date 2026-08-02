import 'package:ai_teacher_phase1_livekit/src/app.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiveKitClient.initialize();
  runApp(const Phase1SpikeApp());
}
