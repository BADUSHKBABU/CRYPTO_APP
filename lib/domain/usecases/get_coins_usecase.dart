import '../entities/coin_entity.dart';
import '../repositories/crypto_repository.dart';

class GetCoinsUseCase {
  final CryptoRepository repository;

  GetCoinsUseCase(this.repository);

  Future<List<CoinEntity>> execute({int page = 1, int perPage = 50}) {
    return repository.getCoins(page: page, perPage: perPage);
  }
}

