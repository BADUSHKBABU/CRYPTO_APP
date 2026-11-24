import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class PriceChangeBadge extends StatelessWidget {
  final double changePercentage;
  final double fontSize;
  final EdgeInsets padding;

  const PriceChangeBadge({
    super.key,
    required this.changePercentage,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercentage >= 0;
    final color = isPositive ? AppTheme.gainGreen : AppTheme.lossRed;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
            color: color,
            size: fontSize + 4,
          ),
          const SizedBox(width: 1),
          Text(
            CurrencyFormatter.formatPercentage(changePercentage),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
