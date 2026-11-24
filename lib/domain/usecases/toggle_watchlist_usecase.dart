import '../repositories/watchlist_repository.dart';

class ToggleWatchlistUseCase {
  final WatchlistRepository repository;

  ToggleWatchlistUseCase(this.repository);

  Future<void> execute(String coinId) {
    return repository.toggleWatchlist(coinId);
  }
}

