import '../entities/coin_entity.dart';
import '../entities/global_market_entity.dart';
import '../entities/chart_point_entity.dart';

abstract class CryptoRepository {
  Future<List<CoinEntity>> getCoins({int page = 1, int perPage = 50});
  Future<CoinEntity> getCoinDetails(String coinId);
  Future<List<ChartPointEntity>> getMarketChart(String coinId, {int days = 7});
  Future<GlobalMarketEntity> getGlobalMarketStats();
}

