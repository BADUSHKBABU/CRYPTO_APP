import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/coin_entity.dart';
import '../../../../domain/entities/global_market_entity.dart';
import '../../../../domain/usecases/get_coins_usecase.dart';
import '../../../../domain/usecases/get_global_market_usecase.dart';
import 'market_event.dart';
import 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final GetCoinsUseCase getCoinsUseCase;
  final GetGlobalMarketUseCase getGlobalMarketUseCase;

  MarketBloc({
    required this.getCoinsUseCase,
    required this.getGlobalMarketUseCase,
  }) : super(MarketInitialState()) {
    on<FetchMarketDataEvent>(_onFetchMarketData);
    on<RefreshMarketDataEvent>(_onRefreshMarketData);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<FilterCategoryChangedEvent>(_onFilterCategoryChanged);
    on<SortCriteriaChangedEvent>(_onSortCriteriaChanged);
  }

  Future<void> _onFetchMarketData(
    FetchMarketDataEvent event,
    Emitter<MarketState> emit,
  ) async {
    emit(MarketLoadingState());
    await _loadData(emit);
  }

  Future<void> _onRefreshMarketData(
    RefreshMarketDataEvent event,
    Emitter<MarketState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<MarketState> emit) async {
    try {
      final results = await Future.wait([
        getCoinsUseCase.execute(page: 1, perPage: 50),
        getGlobalMarketUseCase.execute(),
      ]);

      final coins = results[0] as List<CoinEntity>;
      final global = results[1] as GlobalMarketEntity;

      final currentState = state;
      final query = currentState is MarketLoadedState ? currentState.searchQuery : '';
      final filter = currentState is MarketLoadedState ? currentState.selectedFilter : 'all';
      final sort = currentState is MarketLoadedState ? currentState.sortOption : SortOption.marketCap;
      final asc = currentState is MarketLoadedState ? currentState.isAscending : false;

      final filtered = _applyFilterAndSort(coins, query, filter, sort, asc);

      emit(MarketLoadedState(
        allCoins: coins,
        displayedCoins: filtered,
        globalMarket: global,
        searchQuery: query,
        selectedFilter: filter,
        sortOption: sort,
        isAscending: asc,
      ));
    } catch (e) {
      emit(MarketErrorState(message: e.toString()));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<MarketState> emit,
  ) {
    if (state is MarketLoadedState) {
      final current = state as MarketLoadedState;
      final filtered = _applyFilterAndSort(
        current.allCoins,
        event.query,
        current.selectedFilter,
        current.sortOption,
        current.isAscending,
      );
      emit(current.copyWith(
        searchQuery: event.query,
        displayedCoins: filtered,
      ));
    }
  }

  void _onFilterCategoryChanged(
    FilterCategoryChangedEvent event,
    Emitter<MarketState> emit,
  ) {
    if (state is MarketLoadedState) {
      final current = state as MarketLoadedState;
      final filtered = _applyFilterAndSort(
        current.allCoins,
        current.searchQuery,
        event.category,
        current.sortOption,
        current.isAscending,
      );
      emit(current.copyWith(
        selectedFilter: event.category,
        displayedCoins: filtered,
      ));
    }
  }

  void _onSortCriteriaChanged(
    SortCriteriaChangedEvent event,
    Emitter<MarketState> emit,
  ) {
    if (state is MarketLoadedState) {
      final current = state as MarketLoadedState;
      final filtered = _applyFilterAndSort(
        current.allCoins,
        current.searchQuery,
        current.selectedFilter,
        event.sortOption,
        event.ascending,
      );
      emit(current.copyWith(
        sortOption: event.sortOption,
        isAscending: event.ascending,
        displayedCoins: filtered,
      ));
    }
  }

  List<CoinEntity> _applyFilterAndSort(
    List<CoinEntity> list,
    String query,
    String filter,
    SortOption sort,
    bool ascending,
  ) {
    var result = List<CoinEntity>.from(list);

    // Apply Search
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) || c.symbol.toLowerCase().contains(q);
      }).toList();
    }

    // Apply Category Filter
    if (filter == 'top10') {
      result = result.take(10).toList();
    } else if (filter == 'gainers') {
      result = result.where((c) => c.priceChangePercentage24h > 0).toList();
      result.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
    } else if (filter == 'losers') {
      result = result.where((c) => c.priceChangePercentage24h < 0).toList();
      result.sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
    }

    // Apply Sorting if not already sorted by gainers/losers
    if (filter != 'gainers' && filter != 'losers') {
      result.sort((a, b) {
        int cmp = 0;
        switch (sort) {
          case SortOption.marketCap:
            cmp = a.marketCap.compareTo(b.marketCap);
            break;
          case SortOption.price:
            cmp = a.currentPrice.compareTo(b.currentPrice);
            break;
          case SortOption.change24h:
            cmp = a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h);
            break;
          case SortOption.name:
            cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
        }
        return ascending ? cmp : -cmp;
      });
    }

    return result;
  }
}

