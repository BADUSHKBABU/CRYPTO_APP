import '../entities/global_market_entity.dart';
import '../repositories/crypto_repository.dart';

class GetGlobalMarketUseCase {
  final CryptoRepository repository;

  GetGlobalMarketUseCase(this.repository);

  Future<GlobalMarketEntity> execute() {
    return repository.getGlobalMarketStats();
  }
}

