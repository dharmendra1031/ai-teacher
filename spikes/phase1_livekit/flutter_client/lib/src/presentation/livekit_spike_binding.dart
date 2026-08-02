import 'package:ai_teacher_phase1_livekit/src/data/livekit_token_repository.dart';
import 'package:ai_teacher_phase1_livekit/src/presentation/livekit_spike_controller.dart';
import 'package:get/get.dart';

class LiveKitSpikeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveKitTokenRepository>(LiveKitTokenRepository.new);
    Get.lazyPut<LiveKitSpikeController>(
      () => LiveKitSpikeController(Get.find<LiveKitTokenRepository>()),
    );
  }
}
