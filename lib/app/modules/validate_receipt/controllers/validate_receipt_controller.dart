import 'dart:async';

import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Drives the receipt camera scanner.
///
/// The camera is only running while this tab is the visible one. Leaving the
/// tab stops it, which keeps the camera indicator off and does not drain the
/// battery in the background.
class ValidateReceiptController extends GetxController {
  late final MobileScannerController scanner;

  /// Code read from the most recent successful scan.
  final RxString scannedCode = ''.obs;

  /// Format of the code that was read, for display.
  final Rx<BarcodeFormat> scannedFormat = BarcodeFormat.qrCode.obs;

  /// True once a code has been read and the camera has been stopped.
  final RxBool hasScanned = false.obs;

  /// True while the camera is warming up or starting.
  final RxBool isStarting = true.obs;

  /// True once a scan has been read and rejected by the server.
  final RxBool isInvalid = false.obs;

  /// Guards against a burst of frames all reporting the same code: the camera
  /// delivers several detections per second, and each one would otherwise
  /// trigger a lookup.
  bool _isHandlingResult = false;

  @override
  void onInit() {
    super.onInit();

    scanner = MobileScannerController(
      // Receipts are held still in front of the camera, so there is no benefit
      // to scanning as fast as possible.
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const <BarcodeFormat>[
        BarcodeFormat.qrCode,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.ean13,
        BarcodeFormat.pdf417,
      ],
    );
  }

  /// Starts the camera. Safe to call when it is already running.
  Future<void> startScanning() async {
    if (hasScanned.value) return;

    isStarting.value = true;
    try {
      if (scanner.value.isInitialized) {
        await scanner.start();
      }
    } catch (_) {
      // A camera that refuses to start is surfaced by the view through
      // MobileScanner's own errorBuilder, so there is nothing to add here.
    } finally {
      isStarting.value = false;
    }
  }

  /// Stops the camera, releasing it back to other apps.
  Future<void> stopScanning() async {
    try {
      await scanner.stop();
    } catch (_) {
      // Already stopped.
    }
  }

  /// Handles a frame from the camera.
  ///
  /// The first readable code wins and the camera is stopped so the result
  /// screen is not immediately replaced by a second detection.
  void onDetect(BarcodeCapture capture) {
    if (hasScanned.value || _isHandlingResult) return;

    final String? code = capture.barcodes
        .map((Barcode barcode) => barcode.rawValue)
        .firstWhere(
          (String? value) => value != null && value.isNotEmpty,
          orElse: () => null,
        );

    if (code == null) return;

    _isHandlingResult = true;
    scannedCode.value = code;
    scannedFormat.value = capture.barcodes.first.format;
    hasScanned.value = true;
    isInvalid.value = false;

    // TODO: replace this local check with the receipt validation request.
    unawaited(_validate(code));
  }

  Future<void> _validate(String code) async {
    // TODO: send [code] to the validation endpoint and set isInvalid from the
    // response. Until then every code is treated as pending review.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _isHandlingResult = false;
  }

  /// Clears the current result and resumes scanning.
  Future<void> scanAgain() async {
    scannedCode.value = '';
    hasScanned.value = false;
    isInvalid.value = false;
    await startScanning();
  }

  Future<void> toggleTorch() => scanner.toggleTorch();

  Future<void> switchCamera() => scanner.switchCamera();

  @override
  void onClose() {
    // The controller is a ValueNotifier; dispose it or the platform channel
    // keeps streaming frames for a scanner nobody is showing.
    unawaited(scanner.dispose());
    super.onClose();
  }
}
