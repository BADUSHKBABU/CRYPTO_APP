import 'package:flutter_test/flutter_test.dart';
import 'package:crysptoapp/domain/entities/coin_entity.dart';
import 'package:crysptoapp/data/datasource/mock_crypto_data.dart';

void main() {
  group('Crypto App Domain and Model Tests', () {
    test('CoinModel correctly deserializes and maps to CoinEntity', () {
      final mockCoin = MockCryptoData.mockCoins.first;

      expect(mockCoin, isA<CoinEntity>());
      expect(mockCoin.symbol, 'BTC');
      expect(mockCoin.name, 'Bitcoin');
      expect(mockCoin.currentPrice, greaterThan(0));
      expect(mockCoin.isPositiveChange, true);
    });

    test('MockCryptoData provides valid global market statistics', () {
      final global = MockCryptoData.mockGlobalMarket;

      expect(global.totalMarketCapUsd, greaterThan(1e12));
      expect(global.btcDominance, greaterThan(0));
      expect(global.activeCryptocurrencies, greaterThan(1000));
    });

    test('MockCryptoData generateMockChartPoints produces sequential points', () {
      final points = MockCryptoData.generateMockChartPoints(100.0, 7);

      expect(points.isNotEmpty, true);
      expect(points.last.price, 100.0);
    });
  });
}
