import '../../domain/repositories/watchlist_repository.dart';
import '../datasource/watchlist_local_data_source.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;

  WatchlistRepositoryImpl({WatchlistLocalDataSource? localDataSource})
      : localDataSource = localDataSource ?? WatchlistLocalDataSourceImpl();

  @override
  Future<List<String>> getWatchlistCoinIds() async {
    return await localDataSource.getWatchlistCoinIds();
  }

  @override
  Future<bool> isCoinInWatchlist(String coinId) async {
    return await localDataSource.isCoinInWatchlist(coinId);
  }

  @override
  Future<void> addToWatchlist(String coinId) async {
    await localDataSource.addToWatchlist(coinId);
  }

  @override
  Future<void> removeFromWatchlist(String coinId) async {
    await localDataSource.removeFromWatchlist(coinId);
  }

  @override
  Future<void> toggleWatchlist(String coinId) async {
    await localDataSource.toggleWatchlist(coinId);
  }
}

