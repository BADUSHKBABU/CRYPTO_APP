import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/coin_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../coin_details/ui/coin_details_page.dart';
import '../../watchlist/watchlist_bloc/watchlist_bloc.dart';
import '../../watchlist/watchlist_bloc/watchlist_event.dart';
import '../../watchlist/watchlist_bloc/watchlist_state.dart';

class CoinListTile extends StatelessWidget {
  final CoinEntity coin;

  const CoinListTile({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CoinDetailsPageWrapper(initialCoin: coin),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 24,
              child: Text(
                '${coin.marketCapRank}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Coin Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                coin.image,
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) => Container(
                  width: 36,
                  height: 36,
                  color: AppTheme.cardColor,
                  child: const Icon(
                    Icons.currency_bitcoin,
                    size: 22,
                    color: AppTheme.primaryAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name & Symbol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          coin.symbol,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MCap ${CurrencyFormatter.formatCompact(coin.marketCap)}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price & 24h Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatCurrency(coin.currentPrice),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                PriceChangeBadge(
                  changePercentage: coin.priceChangePercentage24h,
                  fontSize: 11,
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Watchlist Star Icon
            BlocBuilder<WatchlistBloc, WatchlistState>(
              builder: (context, state) {
                final isWatched =
                    state is WatchlistLoadedState && state.isWatched(coin.id);
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    context.read<WatchlistBloc>().add(
                      ToggleWatchlistCoinEvent(coin.id),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      isWatched
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isWatched ? Colors.amber : AppTheme.textMuted,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
