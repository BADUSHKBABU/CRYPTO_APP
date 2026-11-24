import '../entities/chart_point_entity.dart';
import '../repositories/crypto_repository.dart';

class GetMarketChartUseCase {
  final CryptoRepository repository;

  GetMarketChartUseCase(this.repository);

  Future<List<ChartPointEntity>> execute(String coinId, {int days = 7}) {
    return repository.getMarketChart(coinId, days: days);
  }
}

