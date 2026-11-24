abstract class WatchlistState {}

class WatchlistInitialState extends WatchlistState {}

class WatchlistLoadingState extends WatchlistState {}

class WatchlistLoadedState extends WatchlistState {
  final List<String> coinIds;
  WatchlistLoadedState({required this.coinIds});

  bool isWatched(String coinId) => coinIds.contains(coinId.toLowerCase());
}

class WatchlistErrorState extends WatchlistState {
  final String message;
  WatchlistErrorState({required this.message});
}

