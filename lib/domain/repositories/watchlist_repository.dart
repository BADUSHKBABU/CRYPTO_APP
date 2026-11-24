abstract class WatchlistRepository {
  Future<List<String>> getWatchlistCoinIds();
  Future<bool> isCoinInWatchlist(String coinId);
  Future<void> addToWatchlist(String coinId);
  Future<void> removeFromWatchlist(String coinId);
  Future<void> toggleWatchlist(String coinId);
}

