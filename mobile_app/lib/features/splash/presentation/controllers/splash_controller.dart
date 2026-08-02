import 'package:ai_teacher/app/routes/app_routes.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  SplashController({this.autoNavigate = true});

  final bool autoNavigate;
  final RxString statusText = 'Preparing Maya…'.obs;

  @override
  void onReady() {
    super.onReady();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (isClosed) return;
    statusText.value = 'Loading your learning space…';

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (isClosed) return;
    statusText.value = 'Almost ready…';

    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (isClosed || !autoNavigate) return;
    await Get.offNamed<void>(AppRoutes.onboarding);
  }
}
