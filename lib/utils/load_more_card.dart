import 'dart:ui';
import 'package:flutter/material.dart';

class LoadMoreCard extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final Color? primaryColor;
  final String title; // নতুন প্যারামিটার
  final String subtitle; // নতুন প্যারামিটার

  const LoadMoreCard({
    super.key,
    required this.onTap,
    required this.isLoading,
    this.title = "VIEW MORE", // ডিফল্ট ভ্যালু
    this.subtitle = "Explore more items", // ডিফল্ট ভ্যালু
    this.primaryColor,
  });

  @override
  State<LoadMoreCard> createState() => _LoadMoreCardState();
}

class _LoadMoreCardState extends State<LoadMoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.primaryColor ?? Theme.of(context).primaryColor;

    return InkWell(
      onTap: widget.isLoading ? null : widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DotPatternPainter(activeColor.withOpacity(0.05)),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPremiumPulseIcon(activeColor),
                      const SizedBox(height: 20),

                      // ডাইনামিক টাইটেল
                      Text(
                        widget.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.2,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ডাইনামিক সাবটাইটেল
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (widget.isLoading)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.white.withOpacity(0.2),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: activeColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPulseIcon(Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildRipple(
              color,
              scale: 1.0 + _controller.value * 0.5,
              opacity: 1.0 - _controller.value,
            ),
            _buildRipple(
              color,
              scale:
                  1.0 +
                  (_controller.value > 0.5 ? (_controller.value - 0.5) : 0.0) *
                      0.5,
              opacity: (_controller.value > 0.5
                  ? (1.0 - (_controller.value - 0.5) * 2)
                  : 0.0),
            ),

            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.keyboard_double_arrow_down_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRipple(
    Color color, {
    required double scale,
    required double opacity,
  }) {
    return Transform.scale(
      scale: scale,
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(opacity * 0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  final Color color;
  DotPatternPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double i = 0; i < size.width; i += 15) {
      for (double j = 0; j < size.height; j += 15) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
