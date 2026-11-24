import '../../../../domain/entities/coin_entity.dart';
import '../../../../domain/entities/global_market_entity.dart';
import 'market_event.dart';

abstract class MarketState {}

class MarketInitialState extends MarketState {}

class MarketLoadingState extends MarketState {}

class MarketLoadedState extends MarketState {
  final List<CoinEntity> allCoins;
  final List<CoinEntity> displayedCoins;
  final GlobalMarketEntity globalMarket;
  final String searchQuery;
  final String selectedFilter;
  final SortOption sortOption;
  final bool isAscending;

  MarketLoadedState({
    required this.allCoins,
    required this.displayedCoins,
    required this.globalMarket,
    this.searchQuery = '',
    this.selectedFilter = 'all',
    this.sortOption = SortOption.marketCap,
    this.isAscending = false,
  });

  MarketLoadedState copyWith({
    List<CoinEntity>? allCoins,
    List<CoinEntity>? displayedCoins,
    GlobalMarketEntity? globalMarket,
    String? searchQuery,
    String? selectedFilter,
    SortOption? sortOption,
    bool? isAscending,
  }) {
    return MarketLoadedState(
      allCoins: allCoins ?? this.allCoins,
      displayedCoins: displayedCoins ?? this.displayedCoins,
      globalMarket: globalMarket ?? this.globalMarket,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      sortOption: sortOption ?? this.sortOption,
      isAscending: isAscending ?? this.isAscending,
    );
  }
}

class MarketErrorState extends MarketState {
  final String message;
  MarketErrorState({required this.message});
}

