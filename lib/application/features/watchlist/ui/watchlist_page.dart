import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_empty_widget.dart';
import '../../../core/widgets/app_loading_widget.dart';
import '../../market/market_bloc/market_bloc.dart';
import '../../market/market_bloc/market_state.dart';
import '../../market/widgets/coin_list_tile.dart';
import '../watchlist_bloc/watchlist_bloc.dart';
import '../watchlist_bloc/watchlist_event.dart';
import '../watchlist_bloc/watchlist_state.dart';

class WatchlistPage extends StatelessWidget {
  final VoidCallback onExploreTapped;

  const WatchlistPage({super.key, required this.onExploreTapped});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<WatchlistBloc>().add(FetchWatchlistEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, watchlistState) {
          if (watchlistState is WatchlistLoadingState) {
            return const AppLoadingWidget(message: 'Loading your watchlist...');
          }

          final watchedIds = watchlistState is WatchlistLoadedState ? watchlistState.coinIds : <String>[];

          return BlocBuilder<MarketBloc, MarketState>(
            builder: (context, marketState) {
              if (marketState is! MarketLoadedState) {
                return const AppLoadingWidget(message: 'Syncing market rates...');
              }

              final allCoins = marketState.allCoins;
              final watchedCoins = allCoins.where((c) => watchedIds.contains(c.id.toLowerCase())).toList();

              if (watchedCoins.isEmpty) {
                return AppEmptyWidget(
                  title: 'Your Watchlist is Empty',
                  description: 'Star any cryptocurrency from the Market screen to monitor its live price changes here.',
                  icon: Icons.star_border_rounded,
                  actionLabel: 'Explore Market Coins',
                  onAction: onExploreTapped,
                );
              }

              // Calculate total portfolio value and average 24h change
              final totalValue = watchedCoins.fold<double>(0.0, (acc, c) => acc + c.currentPrice);
              final avgChange = watchedCoins.fold<double>(0.0, (acc, c) => acc + c.priceChangePercentage24h) / watchedCoins.length;

              return RefreshIndicator(
                color: AppTheme.primaryAccent,
                backgroundColor: AppTheme.surfaceColor,
                onRefresh: () async {
                  context.read<WatchlistBloc>().add(FetchWatchlistEvent());
                },
                child: ListView(
                  children: [
                    // Watchlist Performance Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.surfaceColor,
                            AppTheme.secondaryAccent.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Watchlist Aggregate Price',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.formatCurrency(totalValue),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Avg 24h Move', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.formatPercentage(avgChange),
                                style: TextStyle(
                                  color: avgChange >= 0 ? AppTheme.gainGreen : AppTheme.lossRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tracking ${watchedCoins.length} Coins',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Swipe to remove',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    ...watchedCoins.map((coin) {
                      return Dismissible(
                        key: Key('watchlist_${coin.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: AppTheme.lossRed.withValues(alpha: 0.25),
                          child: const Icon(Icons.delete_outline_rounded, color: AppTheme.lossRed),
                        ),
                        onDismissed: (_) {
                          context.read<WatchlistBloc>().add(ToggleWatchlistCoinEvent(coin.id));
                        },
                        child: CoinListTile(coin: coin),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
