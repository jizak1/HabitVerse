import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool animate;
  final Duration animationDuration;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.color,
    this.backgroundColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.child,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      
      if (widget.animate) {
        _controller.reset();
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = widget.color ?? theme.colorScheme.primary;
    final bgColor = widget.backgroundColor ?? 
        theme.colorScheme.onSurface.withOpacity(0.1);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress Ring
          AnimatedBuilder(
            animation: widget.animate ? _animation : AlwaysStoppedAnimation(widget.progress),
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: ProgressRingPainter(
                  progress: widget.animate ? _animation.value : widget.progress,
                  strokeWidth: widget.strokeWidth,
                  progressColor: progressColor,
                  backgroundColor: bgColor,
                ),
              );
            },
          ),
          
          // Child widget (usually percentage text)
          if (widget.child != null)
            widget.child!
          else
            AnimatedBuilder(
              animation: widget.animate ? _animation : AlwaysStoppedAnimation(widget.progress),
              builder: (context, child) {
                final currentProgress = widget.animate ? _animation.value : widget.progress;
                return Text(
                  '${(currentProgress * 100).round()}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      const startAngle = -math.pi / 2; // Start from top

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}

class MultiProgressRing extends StatelessWidget {
  final List<ProgressData> progressList;
  final double size;
  final double strokeWidth;
  final double spacing;
  final Widget? child;

  const MultiProgressRing({
    super.key,
    required this.progressList,
    this.size = 100,
    this.strokeWidth = 6,
    this.spacing = 4,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Multiple progress rings
          ...progressList.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final ringSize = size - (index * (strokeWidth + spacing) * 2);
            
            return ProgressRing(
              progress: data.progress,
              size: ringSize,
              strokeWidth: strokeWidth,
              color: data.color,
              animate: data.animate,
            );
          }),
          
          // Center content
          if (child != null) child!,
        ],
      ),
    );
  }
}

class ProgressData {
  final double progress;
  final Color color;
  final bool animate;

  const ProgressData({
    required this.progress,
    required this.color,
    this.animate = true,
  });
}

class AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Duration animationDuration;
  final Curve curve;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.color,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.curve = Curves.elasticOut,
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ProgressRing(
            progress: _progressAnimation.value,
            size: widget.size,
            strokeWidth: widget.strokeWidth,
            color: widget.color,
            animate: false,
          ),
        );
      },
    );
  }
}
