abstract class MarketEvent {}

class FetchMarketDataEvent extends MarketEvent {}

class RefreshMarketDataEvent extends MarketEvent {}

class SearchQueryChangedEvent extends MarketEvent {
  final String query;
  SearchQueryChangedEvent(this.query);
}

class FilterCategoryChangedEvent extends MarketEvent {
  final String category; // 'all', 'top10', 'gainers', 'losers'
  FilterCategoryChangedEvent(this.category);
}

enum SortOption { marketCap, price, change24h, name }

class SortCriteriaChangedEvent extends MarketEvent {
  final SortOption sortOption;
  final bool ascending;

  SortCriteriaChangedEvent({required this.sortOption, required this.ascending});
}

