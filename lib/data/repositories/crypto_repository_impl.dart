import '../../domain/entities/chart_point_entity.dart';
import '../../domain/entities/coin_entity.dart';
import '../../domain/entities/global_market_entity.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../datasource/crypto_remote_data_source.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoRemoteDataSource remoteDataSource;

  CryptoRepositoryImpl({CryptoRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? CryptoRemoteDataSourceImpl();

  @override
  Future<List<CoinEntity>> getCoins({int page = 1, int perPage = 50}) async {
    return await remoteDataSource.getCoins(page: page, perPage: perPage);
  }

  @override
  Future<CoinEntity> getCoinDetails(String coinId) async {
    return await remoteDataSource.getCoinDetails(coinId);
  }

  @override
  Future<List<ChartPointEntity>> getMarketChart(String coinId, {int days = 7}) async {
    return await remoteDataSource.getMarketChart(coinId, days: days);
  }

  @override
  Future<GlobalMarketEntity> getGlobalMarketStats() async {
    return await remoteDataSource.getGlobalMarketStats();
  }
}

