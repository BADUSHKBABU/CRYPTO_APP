abstract class WatchlistEvent {}

class FetchWatchlistEvent extends WatchlistEvent {}

class ToggleWatchlistCoinEvent extends WatchlistEvent {
  final String coinId;
  ToggleWatchlistCoinEvent(this.coinId);
}

