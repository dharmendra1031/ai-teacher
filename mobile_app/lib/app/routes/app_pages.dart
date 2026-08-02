import 'package:ai_teacher/app/routes/app_routes.dart';
import 'package:ai_teacher/features/onboarding/presentation/pages/onboarding_placeholder_page.dart';
import 'package:ai_teacher/features/splash/presentation/bindings/splash_binding.dart';
import 'package:ai_teacher/features/splash/presentation/pages/splash_page.dart';
import 'package:get/get.dart';

abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: AppRoutes.splash,
      page: SplashPage.new,
      binding: SplashBinding(),
    ),
    GetPage<void>(
      name: AppRoutes.onboarding,
      page: OnboardingPlaceholderPage.new,
    ),
  ];
}
