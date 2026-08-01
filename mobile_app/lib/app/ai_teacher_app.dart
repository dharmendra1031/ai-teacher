import 'package:ai_teacher/app/bindings/initial_binding.dart';
import 'package:ai_teacher/app/routes/app_pages.dart';
import 'package:ai_teacher/app/routes/app_routes.dart';
import 'package:ai_teacher/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiTeacherApp extends StatelessWidget {
  const AiTeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Teacher',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      theme: AppTheme.light,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
