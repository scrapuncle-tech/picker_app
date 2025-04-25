import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

Future<void> printLogoImage() async {
  try {
    final ByteData data = await rootBundle.load('assets/icons/logo_full.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      debugPrint('Failed to decode image');
      return;
    }

    // Initialize generator for a 58mm paper size printer
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    // Resize image if needed
    final img.Image resized = img.copyResize(
      image,
      width: 200,
    ); // Resize to fit 58mm

    final List<int> imageBytes = generator.image(resized);

    await PrintBluetoothThermal.writeBytes(imageBytes);
    debugPrint('Logo image printed');
  } catch (e) {
    debugPrint("Error printing logo image: $e");
  }
}
