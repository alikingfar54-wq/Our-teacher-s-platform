import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ===== Shimmer Loading - تأثير احترافي أثناء التحميل =====
class ShimmerCard extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerCard({
    super.key,
    this.height = 80,
    this.borderRadius = 16,
    this.baseColor = const Color(0xFF1A1A3A),
    this.highlightColor = const Color(0xFF2A2A5A),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// قائمة Shimmer للتحميل
class ShimmerList extends StatelessWidget {
  final int count;
  final double itemHeight;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerList({
    super.key,
    this.count = 5,
    this.itemHeight = 80,
    this.baseColor = const Color(0xFF1A1A3A),
    this.highlightColor = const Color(0xFF252545),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              children: [
                // دائرة أفاتار
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                // أسطر النص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 160,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
