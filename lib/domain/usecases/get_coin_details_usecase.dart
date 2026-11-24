import '../entities/coin_entity.dart';
import '../repositories/crypto_repository.dart';

class GetCoinDetailsUseCase {
  final CryptoRepository repository;

  GetCoinDetailsUseCase(this.repository);

  Future<CoinEntity> execute(String coinId) {
    return repository.getCoinDetails(coinId);
  }
}

