import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/order_model.dart';

class OrderStatusStepper extends StatefulWidget {
  final String status;

  const OrderStatusStepper({super.key, required this.status});

  @override
  State<OrderStatusStepper> createState() => _OrderStatusStepperState();
}

class _OrderStatusStepperState extends State<OrderStatusStepper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: .92,
    upperBound: 1.08,
  );

  @override
  void initState() {
    super.initState();
    if (widget.status != OrderStatus.delivered &&
        widget.status != OrderStatus.cancelled) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant OrderStatusStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final terminal =
        widget.status == OrderStatus.delivered ||
        widget.status == OrderStatus.cancelled;
    if (terminal) {
      _pulse.stop();
      _pulse.value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: AppColors.warning, size: 32),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'الطلب ملغي - مفيش أي مبالغ اتخصمت',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = OrderStatus.stageIndex(widget.status);
    final subtitles = [
      'بنراجع طلبك مع المطبخ',
      'اتأكدنا من الطلب، الدفع كاش عند الاستلام',
      'الكشري بيتعمل على النار 🍛',
      'المندوب في السكة عليك، جهز الفلوس 💵',
      'بالهنا والشفا! قيم تجربتك ⭐',
    ];

    return Column(
      children: [
        for (var i = 0; i < OrderStatus.flow.length; i++)
          _stageRow(
            index: i,
            isDone: i < currentIndex,
            isActive: i == currentIndex,
            title: OrderStatus.label(OrderStatus.flow[i]),
            subtitle: subtitles[i],
            showLine: i < OrderStatus.flow.length - 1,
          ),
      ],
    );
  }

  Widget _stageRow({
    required int index,
    required bool isDone,
    required bool isActive,
    required String title,
    required String subtitle,
    required bool showLine,
  }) {
    final status = OrderStatus.flow[index];
    final circleColor = isDone
        ? AppColors.success
        : (isActive ? AppColors.primary : AppColors.grey);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                if (isActive)
                  ScaleTransition(
                    scale: _pulse,
                    child: _circle(circleColor, status, isActive),
                  )
                else
                  _circle(circleColor, status, isActive),
                if (showLine)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 4,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.success
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: isActive || isDone
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isActive || isDone
                          ? AppColors.textDark
                          : AppColors.grey,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 4),
                    AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(Color color, String status, bool isActive) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(color: color, width: 3),
      boxShadow: isActive
          ? [
              BoxShadow(
                color: color.withValues(alpha: .45),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ]
          : null,
    ),
    child: Icon(OrderStatus.icon(status), color: color, size: 24),
  );
}
