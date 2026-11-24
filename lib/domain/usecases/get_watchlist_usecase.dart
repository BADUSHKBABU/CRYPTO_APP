import '../repositories/watchlist_repository.dart';

class GetWatchlistUseCase {
  final WatchlistRepository repository;

  GetWatchlistUseCase(this.repository);

  Future<List<String>> execute() {
    return repository.getWatchlistCoinIds();
  }
}

