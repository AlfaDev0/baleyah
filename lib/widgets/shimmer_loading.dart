import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/constants.dart';

class ShimmerLoading extends StatelessWidget {
  final int itemCount;
  final bool horizontalList;

  const ShimmerLoading({
    super.key,
    this.itemCount = 6,
    this.horizontalList = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: horizontalList
          ? SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => _box(width: 110, height: 120),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => Container(
                height: 112,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _bar(width: double.infinity, height: 16),
                          const SizedBox(height: 8),
                          _bar(width: 180, height: 12),
                          const SizedBox(height: 8),
                          _bar(width: 100, height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _box(width: 92, height: 92),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _box({required double width, required double height}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
  );

  Widget _bar({required double width, required double height}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
