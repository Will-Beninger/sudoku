import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Standard device dimensions for testing
class DeviceDimensions {
  // Pixel 10 Pro (Simulated based on high-end Android)
  // Logic: ~412 x 915
  static const Size pixel10Pro = Size(412, 915);

  // iPhone 17 (Simulated based on modern iPhone)
  // Logic: ~430 x 932
  static const Size iPhone17 = Size(430, 932);

  // Laptop / Web Standard
  // Logic: 1536 x 864 (Common 1080p scaled or 13" laptop)
  static const Size laptop = Size(1536, 864);
}

/// Helper to run a test on multiple device sizes
void testUI(String description,
    {required Future<void> Function(WidgetTester tester, Size deviceSize)
        callback}) {
  final devices = {
    'Pixel 10 Pro': DeviceDimensions.pixel10Pro,
    'iPhone 17': DeviceDimensions.iPhone17,
    'Laptop': DeviceDimensions.laptop,
  };

  for (final entry in devices.entries) {
    testWidgets('$descriptionOn ${entry.key}', (tester) async {
      // Set surface size
      tester.view.physicalSize = entry.value * tester.view.devicePixelRatio;
      tester.view.devicePixelRatio = 1.0; // Simplify for layout tests

      // Reset on completion
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await callback(tester, entry.value);
    });
  }
}

String get descriptionOn => ' - on';
