import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:neumorophic/app/modules/shell/controllers/shell_controller.dart';

import '../../../core/colors.dart';
import '../../../core/neumorphic.dart';
import '../controllers/validate_receipt_controller.dart';

/// Camera scanner for validating a receipt.
class ValidateReceiptView extends GetView<ValidateReceiptController> {
  const ValidateReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          const _ScannerHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: _ScannerStage(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerHeader extends StatelessWidget {
  const _ScannerHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Validate Receipt',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: CustomColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Point the camera at the receipt code',
            style: TextStyle(fontSize: 13, color: CustomColors.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}

/// Hosts the camera and keeps it in step with the bottom navigation.
///
/// The preview stays mounted so the controller keeps ownership of the camera
/// across tab switches, but it is stopped whenever this tab is not the visible
/// one.
class _ScannerStage extends StatefulWidget {
  const _ScannerStage({required this.controller});

  final ValidateReceiptController controller;

  @override
  State<_ScannerStage> createState() => _ScannerStageState();
}

class _ScannerStageState extends State<_ScannerStage> {
  /// Last state the camera was synced to, so redundant calls are skipped.
  bool? _cameraIsActive;

  @override
  void initState() {
    super.initState();

    // The camera has to follow the tab, not just the first frame: the shell is
    // already built when a user taps Receipt, so initState alone would leave the
    // camera stopped.
    ever<int>(
      Get.find<ShellController>().currentIndex,
      (int index) => _syncCamera(index == ShellController.receiptTab),
    );

    // Starting the camera touches the platform channel, so it cannot run during
    // the first build.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncCamera(
        Get.find<ShellController>().currentIndex.value ==
            ShellController.receiptTab,
      ),
    );
  }

  void _syncCamera(bool isActive) {
    if (!mounted || _cameraIsActive == isActive) return;
    _cameraIsActive = isActive;

    if (isActive) {
      widget.controller.startScanning();
    } else {
      widget.controller.stopScanning();
    }
  }

  @override
  void dispose() {
    // Leaving the tab behind must not leave the camera running.
    widget.controller.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Obx(() {
      final isActive =
          Get.find<ShellController>().currentIndex.value ==
          ShellController.receiptTab;

      return Column(
        children: <Widget>[
          Expanded(
            child: NeumorphicBox(
              depth: 8,
              radius: NeumorphicTokens.radiusLarge,
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  NeumorphicTokens.radiusLarge - 6,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    // Kept mounted while offstage so the camera is not torn
                    // down and rebuilt on every tab switch.
                    Offstage(
                      offstage: !isActive,
                      child: MobileScanner(
                        controller: controller.scanner,
                        onDetect: controller.onDetect,
                        errorBuilder: (context, error) => _CameraError(
                          message: error.errorDetails?.message,
                        ),
                      ),
                    ),
                    const _ScanWindowOverlay(),
                    if (!isActive)
                      ColoredBox(
                        color: NeumorphicTokens.baseColor,
                        child: const Center(
                          child: Text('Paused'),
                        ),
                      ),
                    if (controller.hasScanned.value)
                      _ScanResult(controller: controller),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ScannerControls(controller: controller),
        ],
      );
    });
  }
}

class _ScannerControls extends StatelessWidget {
  const _ScannerControls({required this.controller});

  final ValidateReceiptController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Torch state lives on the scanner's ValueNotifier, so listen to that
        // rather than mirroring it into another observable.
        ValueListenableBuilder<MobileScannerState>(
          valueListenable: controller.scanner,
          builder: (BuildContext context, MobileScannerState state, _) {
            final canUseTorch = state.torchState != TorchState.unavailable;
            final torchOn = state.torchState == TorchState.on ||
                state.torchState == TorchState.auto;

            return _RoundControl(
              icon: torchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
              label: 'Light',
              onPressed: canUseTorch ? controller.toggleTorch : null,
            );
          },
        ),
        const SizedBox(width: 28),
        _RoundControl(
          icon: Icons.cameraswitch_rounded,
          label: 'Flip',
          onPressed: controller.switchCamera,
        ),
      ],
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: onPressed,
      enabled: onPressed != null,
      shape: BoxShape.circle,
      depth: 5,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 22, color: CustomColors.secondaryTextColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CustomColors.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dims everything outside the scan window and draws the corner brackets.
class _ScanWindowOverlay extends StatelessWidget {
  const _ScanWindowOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Square window, sized to the shorter side with room for the brackets.
        final side = (constraints.maxWidth * 0.68).clamp(0.0, constraints.maxHeight * 0.6);

        return IgnorePointer(
          child: CustomPaint(
            painter: _ScanWindowPainter(side: side),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _ScanWindowPainter extends CustomPainter {
  const _ScanWindowPainter({required this.side});

  final double side;

  static const double _corner = 26;
  static const double _stroke = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    // Dim the surroundings so the eye lands on the window.
    final scrim = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(rrect),
    );
    canvas.drawPath(scrim, Paint()..color = Colors.black.withAlpha(140));

    final bracket = Paint()
      ..color = CustomColors.primaryColor
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void drawCorner(Offset pivot, double dx, double dy) {
      canvas.drawPath(
        Path()
          ..moveTo(pivot.dx + dx * _corner, pivot.dy)
          ..lineTo(pivot.dx, pivot.dy)
          ..lineTo(pivot.dx, pivot.dy + dy * _corner),
        bracket,
      );
    }

    drawCorner(rect.topLeft, 1, 1);
    drawCorner(rect.topRight, -1, 1);
    drawCorner(rect.bottomLeft, 1, -1);
    drawCorner(rect.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(_ScanWindowPainter oldDelegate) => oldDelegate.side != side;
}

/// Shown over the preview once a code has been read.
class _ScanResult extends StatelessWidget {
  const _ScanResult({required this.controller});

  final ValidateReceiptController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: NeumorphicTokens.baseColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            NeumorphicBox(
              shape: BoxShape.circle,
              depth: 6,
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(20),
              child: Icon(
                controller.isInvalid.value
                    ? Icons.close_rounded
                    : Icons.check_rounded,
                color: controller.isInvalid.value
                    ? CustomColors.errorColor
                    : CustomColors.primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Code captured',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            // Recessed slot so the long code scrolls instead of overflowing.
            NeumorphicBox(
              variant: NeumorphicVariant.pressed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: double.infinity,
              child: Text(
                controller.scannedCode.value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: CustomColors.primaryTextColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Awaiting validation',
              style: TextStyle(
                fontSize: 12,
                color: controller.isInvalid.value
                    ? CustomColors.errorColor
                    : CustomColors.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: controller.scanAgain,
              depth: 5,
              radius: NeumorphicTokens.radiusMedium,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: const Text(
                'Scan again',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CustomColors.primaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the camera cannot start, most often a denied permission.
class _CameraError extends StatelessWidget {
  const _CameraError({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.no_photography_outlined,
              size: 42,
              color: CustomColors.secondaryTextColor,
            ),
            const SizedBox(height: 12),
            const Text(
              'Camera unavailable',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message ?? 'Allow camera access to scan a receipt.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: CustomColors.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
