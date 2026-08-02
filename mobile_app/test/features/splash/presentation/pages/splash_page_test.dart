import 'package:ai_teacher/features/splash/presentation/controllers/splash_controller.dart';
import 'package:ai_teacher/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
  });

  testWidgets('renders the Figma-derived Splash content', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    Get.put<SplashController>(SplashController(autoNavigate: false));

    await tester.pumpWidget(const GetMaterialApp(home: SplashPage()));

    expect(find.text('AI Teacher'), findsOneWidget);
    expect(find.text('REAL-TIME AI SPEAKING'), findsOneWidget);
    expect(find.text('Private practice. Real confidence.'), findsOneWidget);
    expect(
      find.text('Your conversation stays private by default'),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Loading your learning space…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Almost ready…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 850));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
