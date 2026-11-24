import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../market_bloc/market_bloc.dart';
import '../market_bloc/market_event.dart';

class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final SortOption sortOption;
  final bool isAscending;

  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.sortOption,
    required this.isAscending,
  });

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Sort Cryptocurrencies By',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSortTile(context, 'Market Cap (Highest First)', SortOption.marketCap, false),
                _buildSortTile(context, 'Market Cap (Lowest First)', SortOption.marketCap, true),
                _buildSortTile(context, 'Price (Highest First)', SortOption.price, false),
                _buildSortTile(context, 'Price (Lowest First)', SortOption.price, true),
                _buildSortTile(context, '24h Gainers (%)', SortOption.change24h, false),
                _buildSortTile(context, '24h Losers (%)', SortOption.change24h, true),
                _buildSortTile(context, 'Name (A to Z)', SortOption.name, true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortTile(BuildContext context, String title, SortOption option, bool ascending) {
    final isSelected = sortOption == option && isAscending == ascending;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryAccent : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_rounded, color: AppTheme.primaryAccent) : null,
      onTap: () {
        context.read<MarketBloc>().add(
              SortCriteriaChangedEvent(sortOption: option, ascending: ascending),
            );
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input & Sort Action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (val) {
                    context.read<MarketBloc>().add(SearchQueryChangedEvent(val));
                  },
                  decoration: InputDecoration(
                    hintText: 'Search coin or symbol (e.g. BTC, Solana)...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                            onPressed: () {
                              searchController.clear();
                              context.read<MarketBloc>().add(SearchQueryChangedEvent(''));
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sort_rounded, color: AppTheme.secondaryAccent),
                  tooltip: 'Sort List',
                  onPressed: () => _showSortBottomSheet(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filter Category Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip(context, 'All Coins', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip(context, 'Top 10', 'top10'),
              const SizedBox(width: 8),
              _buildFilterChip(context, 'Top Gainers', 'gainers'),
              const SizedBox(width: 8),
              _buildFilterChip(context, 'Top Losers', 'losers'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String category) {
    final isSelected = selectedFilter == category;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        context.read<MarketBloc>().add(FilterCategoryChangedEvent(category));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryAccent.withValues(alpha: 0.18) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryAccent : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
