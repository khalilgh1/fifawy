import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';

// Pre-built decoration — avoids BoxDecoration allocation on every build
const _pitchDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.all(Radius.circular(24)),
  border: Border.fromBorderSide(
    BorderSide(color: AppColors.surfaceBorder, width: 1.2),
  ),
  boxShadow: [
    BoxShadow(
      color: Color(0x4D000000), // ~30% black
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ],
);

class PitchPlaceholder extends StatefulWidget {
  final double height;
  final String videoAsset;

  const PitchPlaceholder({
    super.key,
    this.height = 180,
    this.videoAsset = 'data/football_pitch_widget_loop.mp4',
  });

  @override
  State<PitchPlaceholder> createState() => _PitchPlaceholderState();
}

class _PitchPlaceholderState extends State<PitchPlaceholder> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.asset(widget.videoAsset);
      _controller = controller;

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      await controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: _pitchDecoration,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(23)),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if (_isInitialized && _controller != null && !_hasError)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width > 0
                          ? _controller!.value.size.width
                          : 16,
                      height: _controller!.value.size.height > 0
                          ? _controller!.value.size.height
                          : 9,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                )
              else
                // Fallback pitch custom painter if video is initializing or fails
                CustomPaint(
                  size: Size.infinite,
                  painter: _PitchPainter(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF2C3647).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerDotPaint = Paint()
      ..color = const Color(0xFF2C3647).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    const margin = 28.0;
    final pitchRect = Rect.fromLTWH(
      margin,
      margin,
      size.width - margin * 2,
      size.height - margin * 2,
    );

    // Outer Pitch Boundary
    canvas.drawRRect(
      RRect.fromRectAndRadius(pitchRect, const Radius.circular(8)),
      linePaint,
    );

    // Halfway line
    final centerX = size.width / 2;
    canvas.drawLine(
      Offset(centerX, margin),
      Offset(centerX, size.height - margin),
      linePaint,
    );

    // Center Circle
    final centerCircleRadius = (size.height - margin * 2) * 0.35;
    canvas.drawCircle(
      Offset(centerX, size.height / 2),
      centerCircleRadius,
      linePaint,
    );

    // Center Spot
    canvas.drawCircle(
      Offset(centerX, size.height / 2),
      3.5,
      centerDotPaint,
    );

    // Left Penalty Box
    final boxWidth = (size.width - margin * 2) * 0.16;
    final boxHeight = (size.height - margin * 2) * 0.6;
    final boxTop = margin + ((size.height - margin * 2) - boxHeight) / 2;

    canvas.drawRect(
      Rect.fromLTWH(margin, boxTop, boxWidth, boxHeight),
      linePaint,
    );

    // Right Penalty Box
    canvas.drawRect(
      Rect.fromLTWH(size.width - margin - boxWidth, boxTop, boxWidth, boxHeight),
      linePaint,
    );

    // Left Goal area
    final goalWidth = boxWidth * 0.45;
    final goalHeight = boxHeight * 0.5;
    final goalTop = margin + ((size.height - margin * 2) - goalHeight) / 2;

    canvas.drawRect(
      Rect.fromLTWH(margin, goalTop, goalWidth, goalHeight),
      linePaint,
    );

    // Right Goal area
    canvas.drawRect(
      Rect.fromLTWH(size.width - margin - goalWidth, goalTop, goalWidth, goalHeight),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
