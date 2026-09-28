import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveBreakpoints Tests', () {
    testWidgets('identifies mobile below 1024px width', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool? isDesktop;
      bool? isMobile;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isDesktop = ResponsiveBreakpoints.isDesktop(context);
              isMobile = ResponsiveBreakpoints.isMobile(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isDesktop, isFalse);
      expect(isMobile, isTrue);
    });

    testWidgets('identifies desktop at 1024px and wider', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool? isDesktop;
      bool? isMobile;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isDesktop = ResponsiveBreakpoints.isDesktop(context);
              isMobile = ResponsiveBreakpoints.isMobile(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isDesktop, isTrue);
      expect(isMobile, isFalse);
    });

    testWidgets('identifies wide desktop at 1366px and wider', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool? isDesktopWide;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isDesktopWide = ResponsiveBreakpoints.isDesktopWide(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isDesktopWide, isTrue);
    });
  });
}
