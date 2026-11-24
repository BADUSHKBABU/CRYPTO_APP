import 'package:flutter/material.dart';
import '../../../../domain/entities/coin_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

class MarketStatsGrid extends StatelessWidget {
  final CoinEntity coin;

  const MarketStatsGrid({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Market Statistics',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildStatItem('Market Cap', CurrencyFormatter.formatCompact(coin.marketCap), Icons.pie_chart_outline_rounded),
            _buildStatItem('24h Volume', CurrencyFormatter.formatCompact(coin.totalVolume), Icons.bar_chart_rounded),
            _buildStatItem('24h High', CurrencyFormatter.formatCurrency(coin.high24h), Icons.arrow_upward_rounded),
            _buildStatItem('24h Low', CurrencyFormatter.formatCurrency(coin.low24h), Icons.arrow_downward_rounded),
            _buildStatItem('Circulating Supply', '${CurrencyFormatter.formatNumberCompact(coin.circulatingSupply)} ${coin.symbol}', Icons.change_circle_outlined),
            _buildStatItem('Max Supply', coin.maxSupply > 0 ? '${CurrencyFormatter.formatNumberCompact(coin.maxSupply)} ${coin.symbol}' : 'Unlimited', Icons.all_inclusive_rounded),
            _buildStatItem('All-Time High (ATH)', CurrencyFormatter.formatCurrency(coin.ath), Icons.stars_rounded),
            _buildStatItem('ATH Change', CurrencyFormatter.formatPercentage(coin.athChangePercentage), Icons.trending_down_rounded, isLoss: coin.athChangePercentage < 0),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {bool? isLoss}) {
    Color valueColor = AppTheme.textPrimary;
    if (isLoss == true) valueColor = AppTheme.lossRed;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

