import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_loading_widget.dart';
import '../../market/market_bloc/market_bloc.dart';
import '../../market/market_bloc/market_state.dart';
import '../../market/widgets/coin_list_tile.dart';

class MarketStatsPage extends StatelessWidget {
  const MarketStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market Statistics')),
      body: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, state) {
          if (state is! MarketLoadedState) {
            return const AppLoadingWidget(
              message: 'Loading global market intelligence...',
            );
          }

          final global = state.globalMarket;
          final allCoins = state.allCoins;

          // Top 3 gainers
          final gainers = List.of(allCoins)
            ..sort(
              (a, b) => b.priceChangePercentage24h.compareTo(
                a.priceChangePercentage24h,
              ),
            );
          final top3Gainers = gainers.take(3).toList();

          // Top 3 losers
          final losers = List.of(allCoins)
            ..sort(
              (a, b) => a.priceChangePercentage24h.compareTo(
                b.priceChangePercentage24h,
              ),
            );
          final top3Losers = losers.take(3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Global Metric Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Total Market Cap',
                        CurrencyFormatter.formatCompact(
                          global.totalMarketCapUsd,
                        ),
                        '24h: ${CurrencyFormatter.formatPercentage(global.marketCapChangePercentage24h)}',
                        global.marketCapChangePercentage24h >= 0
                            ? AppTheme.gainGreen
                            : AppTheme.lossRed,
                        Icons.pie_chart_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        '24h Total Volume',
                        CurrencyFormatter.formatCompact(
                          global.total24hVolumeUsd,
                        ),
                        'Across all exchanges',
                        AppTheme.secondaryAccent,
                        Icons.insights_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Active Cryptos',
                        '${global.activeCryptocurrencies}',
                        'Tracked globally',
                        AppTheme.textPrimary,
                        Icons.token_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Tracked Markets',
                        '${global.markets}',
                        'Active pairs',
                        AppTheme.textPrimary,
                        Icons.storefront_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Market Dominance Visualizer
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Market Cap Dominance',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 14,
                          child: Row(
                            children: [
                              Expanded(
                                flex: (global.btcDominance * 10).toInt(),
                                child: Container(
                                  color: const Color(0xFFF7931A),
                                ),
                              ),
                              Expanded(
                                flex: (global.ethDominance * 10).toInt(),
                                child: Container(
                                  color: const Color(0xFF627EEA),
                                ),
                              ),
                              Expanded(
                                flex:
                                    ((100 -
                                                global.btcDominance -
                                                global.ethDominance) *
                                            10)
                                        .toInt()
                                        .clamp(1, 1000),
                                child: Container(
                                  color: AppTheme.secondaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLegend(
                            'Bitcoin (BTC)',
                            '${global.btcDominance.toStringAsFixed(1)}%',
                            const Color(0xFFF7931A),
                          ),
                          _buildLegend(
                            'Ethereum (ETH)',
                            '${global.ethDominance.toStringAsFixed(1)}%',
                            const Color(0xFF627EEA),
                          ),
                          _buildLegend(
                            'Others',
                            '${(100 - global.btcDominance - global.ethDominance).toStringAsFixed(1)}%',
                            AppTheme.secondaryAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Top Gainers Section
                const Text(
                  'Top Gainers 1 day',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...top3Gainers.map((c) => CoinListTile(coin: c)),
                const SizedBox(height: 20),

                // Top Losers Section
                const Text(
                  'Top Losers 1day',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...top3Losers.map((c) => CoinListTile(coin: c)),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    Color subColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              Icon(icon, size: 18, color: AppTheme.textMuted),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: subColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
