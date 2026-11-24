import 'package:shared_preferences/shared_preferences.dart';

abstract class WatchlistLocalDataSource {
  Future<List<String>> getWatchlistCoinIds();
  Future<bool> isCoinInWatchlist(String coinId);
  Future<void> addToWatchlist(String coinId);
  Future<void> removeFromWatchlist(String coinId);
  Future<void> toggleWatchlist(String coinId);
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  static const String _watchlistKey = 'crypto_watchlist_coin_ids';
  final SharedPreferences? _prefs;

  WatchlistLocalDataSourceImpl({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    final prefs = _prefs;
    if (prefs != null) return prefs;
    return await SharedPreferences.getInstance();
  }

  @override
  Future<List<String>> getWatchlistCoinIds() async {
    final prefs = await _getPrefs();
    return prefs.getStringList(_watchlistKey) ?? ['bitcoin', 'ethereum', 'solana'];
  }

  @override
  Future<bool> isCoinInWatchlist(String coinId) async {
    final list = await getWatchlistCoinIds();
    return list.contains(coinId.toLowerCase());
  }

  @override
  Future<void> addToWatchlist(String coinId) async {
    final prefs = await _getPrefs();
    final list = (prefs.getStringList(_watchlistKey) ?? ['bitcoin', 'ethereum', 'solana']).toList();
    if (!list.contains(coinId.toLowerCase())) {
      list.add(coinId.toLowerCase());
      await prefs.setStringList(_watchlistKey, list);
    }
  }

  @override
  Future<void> removeFromWatchlist(String coinId) async {
    final prefs = await _getPrefs();
    final list = (prefs.getStringList(_watchlistKey) ?? ['bitcoin', 'ethereum', 'solana']).toList();
    list.remove(coinId.toLowerCase());
    await prefs.setStringList(_watchlistKey, list);
  }

  @override
  Future<void> toggleWatchlist(String coinId) async {
    final inWatchlist = await isCoinInWatchlist(coinId);
    if (inWatchlist) {
      await removeFromWatchlist(coinId);
    } else {
      await addToWatchlist(coinId);
    }
  }
}
