import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/crypto_repository_impl.dart';
import '../../../../domain/entities/coin_entity.dart';
import '../../../../domain/usecases/get_coin_details_usecase.dart';
import '../../../../domain/usecases/get_market_chart_usecase.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading_widget.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../watchlist/watchlist_bloc/watchlist_bloc.dart';
import '../../watchlist/watchlist_bloc/watchlist_event.dart';
import '../../watchlist/watchlist_bloc/watchlist_state.dart';
import '../details_bloc/details_bloc.dart';
import '../details_bloc/details_event.dart';
import '../details_bloc/details_state.dart';
import '../widgets/interactive_price_chart.dart';
import '../widgets/market_stats_grid.dart';

class CoinDetailsPageWrapper extends StatelessWidget {
  final CoinEntity initialCoin;

  const CoinDetailsPageWrapper({super.key, required this.initialCoin});

  @override
  Widget build(BuildContext context) {
    final repo = CryptoRepositoryImpl();
    return BlocProvider(
      create: (_) => DetailsBloc(
        getCoinDetailsUseCase: GetCoinDetailsUseCase(repo),
        getMarketChartUseCase: GetMarketChartUseCase(repo),
      )..add(FetchCoinDetailsEvent(coinId: initialCoin.id, days: 7)),
      child: CoinDetailsPage(initialCoin: initialCoin),
    );
  }
}

class CoinDetailsPage extends StatelessWidget {
  final CoinEntity initialCoin;

  const CoinDetailsPage({super.key, required this.initialCoin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                initialCoin.image,
                width: 28,
                height: 28,
                errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, size: 28, color: AppTheme.primaryAccent),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                initialCoin.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (context, state) {
              final isWatched = state is WatchlistLoadedState && state.isWatched(initialCoin.id);
              return IconButton(
                icon: Icon(
                  isWatched ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isWatched ? Colors.amber : AppTheme.textSecondary,
                  size: 26,
                ),
                onPressed: () {
                  context.read<WatchlistBloc>().add(ToggleWatchlistCoinEvent(initialCoin.id));
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DetailsBloc, DetailsState>(
        builder: (context, state) {
          if (state is DetailsLoadingState) {
            return const AppLoadingWidget(message: 'Loading comprehensive market data...');
          } else if (state is DetailsErrorState) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<DetailsBloc>().add(FetchCoinDetailsEvent(coinId: initialCoin.id));
              },
            );
          } else if (state is DetailsLoadedState) {
            final coin = state.coin;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Price & Rank
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.formatCurrency(coin.currentPrice),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              PriceChangeBadge(changePercentage: coin.priceChangePercentage24h),
                              const SizedBox(width: 8),
                              const Text('24h Change', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Text(
                          'Rank #${coin.marketCapRank}',
                          style: const TextStyle(
                            color: AppTheme.secondaryAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Interactive Chart with Timeframes
                  InteractivePriceChart(
                    chartPoints: state.chartPoints,
                    selectedDays: state.selectedDays,
                    isLoading: state.isChartLoading,
                    onTimeframeChanged: (days) {
                      context.read<DetailsBloc>().add(
                            ChangeChartTimeframeEvent(coinId: coin.id, days: days),
                          );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Market Statistics Grid
                  MarketStatsGrid(coin: coin),
                  const SizedBox(height: 28),

                  // About Section
                  if (coin.description.isNotEmpty) ...[
                    const Text(
                      'About',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Text(
                        coin.description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

