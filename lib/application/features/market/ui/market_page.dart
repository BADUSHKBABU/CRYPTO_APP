import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_empty_widget.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading_widget.dart';
import '../../auth/auth_bloc/auth_bloc.dart';
import '../../auth/auth_bloc/auth_state.dart';
import '../../auth/ui/login_page.dart';
import '../../auth/ui/user_profile_dialog.dart';
import '../market_bloc/market_bloc.dart';
import '../market_bloc/market_event.dart';
import '../market_bloc/market_state.dart';
import '../widgets/coin_list_tile.dart';
import '../widgets/market_summary_header.dart';
import '../widgets/search_and_filter_bar.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: AppTheme.primaryAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Crypto Market Page'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<MarketBloc>().add(RefreshMarketDataEvent());
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return IconButton(
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.primaryAccent,
                    child: Text(
                      state.user.name.isNotEmpty
                          ? state.user.name[0].toUpperCase()
                          : 'User',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => UserProfileDialog(user: state.user),
                    );
                  },
                );
              }
              return IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, state) {
          if (state is MarketLoadingState) {
            return const AppLoadingWidget(
              message: 'Connecting to live crypto markets...',
            );
          } else if (state is MarketErrorState) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<MarketBloc>().add(FetchMarketDataEvent());
              },
            );
          } else if (state is MarketLoadedState) {
            return RefreshIndicator(
              color: AppTheme.primaryAccent,
              backgroundColor: AppTheme.surfaceColor,
              onRefresh: () async {
                context.read<MarketBloc>().add(RefreshMarketDataEvent());
              },
              child: CustomScrollView(
                slivers: [
                  // Global Market Overview Summary
                  SliverToBoxAdapter(
                    child: MarketSummaryHeader(
                      globalMarket: state.globalMarket,
                    ),
                  ),

                  // Search & Filter controls
                  SliverToBoxAdapter(
                    child: SearchAndFilterBar(
                      searchController: _searchController,
                      selectedFilter: state.selectedFilter,
                      sortOption: state.sortOption,
                      isAscending: state.isAscending,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Coin List or Empty State
                  if (state.displayedCoins.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyWidget(
                        title: 'No Cryptocurrencies Found',
                        description:
                            'No coins matched your search "${state.searchQuery}". Try a different name or symbol.',
                        icon: Icons.search_off_rounded,
                        actionLabel: 'Reset Filters',
                        onAction: () {
                          _searchController.clear();
                          context.read<MarketBloc>().add(
                            SearchQueryChangedEvent(''),
                          );
                          context.read<MarketBloc>().add(
                            FilterCategoryChangedEvent('all'),
                          );
                        },
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final coin = state.displayedCoins[index];
                        return CoinListTile(coin: coin);
                      }, childCount: state.displayedCoins.length),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
