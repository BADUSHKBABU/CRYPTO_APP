import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/coin_model.dart';
import '../models/global_market_model.dart';
import '../models/chart_point_model.dart';
import 'mock_crypto_data.dart';

abstract class CryptoRemoteDataSource {
  Future<List<CoinModel>> getCoins({int page = 1, int perPage = 50});
  Future<CoinModel> getCoinDetails(String coinId);
  Future<List<ChartPointModel>> getMarketChart(String coinId, {int days = 7});
  Future<GlobalMarketModel> getGlobalMarketStats();
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  final http.Client client;

  CryptoRemoteDataSourceImpl({http.Client? client}) : client = client ?? http.Client();

  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  @override
  Future<List<CoinModel>> getCoins({int page = 1, int perPage = 50}) async {
    final uri = Uri.parse(
      '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$perPage&page=$page&sparkline=true&price_change_percentage=24h,7d',
    );

    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((e) => CoinModel.fromJson(e)).toList();
      } else {
        debugPrint('CoinGecko returned status ${response.statusCode}. Falling back to mock data.');
        return MockCryptoData.mockCoins;
      }
    } catch (e) {
      debugPrint('Error fetching coins from API: $e. Using resilient mock data.');
      return MockCryptoData.mockCoins;
    }
  }

  @override
  Future<CoinModel> getCoinDetails(String coinId) async {
    final uri = Uri.parse(
      '$_baseUrl/coins/$coinId?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=true',
    );

    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final marketData = data['market_data'] ?? {};
        
        List<double> sparkline = [];
        if (marketData['sparkline_7d'] != null && marketData['sparkline_7d']['price'] != null) {
          final list = marketData['sparkline_7d']['price'] as List<dynamic>;
          sparkline = list.map((e) => (e as num).toDouble()).toList();
        }

        String description = '';
        if (data['description'] != null && data['description']['en'] != null) {
          description = data['description']['en'].toString();
        }

        return CoinModel(
          id: data['id']?.toString() ?? coinId,
          symbol: (data['symbol']?.toString() ?? '').toUpperCase(),
          name: data['name']?.toString() ?? '',
          image: data['image'] is Map ? (data['image']['large'] ?? data['image']['small'] ?? '') : '',
          currentPrice: (marketData['current_price']?['usd'] as num?)?.toDouble() ?? 0.0,
          marketCap: (marketData['market_cap']?['usd'] as num?)?.toDouble() ?? 0.0,
          marketCapRank: (data['market_cap_rank'] as num?)?.toInt() ?? 0,
          totalVolume: (marketData['total_volume']?['usd'] as num?)?.toDouble() ?? 0.0,
          high24h: (marketData['high_24h']?['usd'] as num?)?.toDouble() ?? 0.0,
          low24h: (marketData['low_24h']?['usd'] as num?)?.toDouble() ?? 0.0,
          priceChange24h: (marketData['price_change_24h'] as num?)?.toDouble() ?? 0.0,
          priceChangePercentage24h: (marketData['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
          priceChangePercentage7d: (marketData['price_change_percentage_7d'] as num?)?.toDouble() ?? 0.0,
          circulatingSupply: (marketData['circulating_supply'] as num?)?.toDouble() ?? 0.0,
          totalSupply: (marketData['total_supply'] as num?)?.toDouble() ?? 0.0,
          maxSupply: (marketData['max_supply'] as num?)?.toDouble() ?? 0.0,
          ath: (marketData['ath']?['usd'] as num?)?.toDouble() ?? 0.0,
          athChangePercentage: (marketData['ath_change_percentage']?['usd'] as num?)?.toDouble() ?? 0.0,
          athDate: marketData['ath_date']?['usd']?.toString() ?? '',
          sparklineIn7d: sparkline,
          description: description,
        );
      } else {
        return _findMockCoin(coinId);
      }
    } catch (e) {
      debugPrint('Error fetching coin details: $e. Using mock details.');
      return _findMockCoin(coinId);
    }
  }

  @override
  Future<List<ChartPointModel>> getMarketChart(String coinId, {int days = 7}) async {
    final uri = Uri.parse(
      '$_baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=$days',
    );

    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> prices = data['prices'] ?? [];
        return prices.map((item) => ChartPointModel.fromList(item as List<dynamic>)).toList();
      } else {
        final coin = _findMockCoin(coinId);
        return MockCryptoData.generateMockChartPoints(coin.currentPrice, days);
      }
    } catch (e) {
      debugPrint('Error fetching market chart: $e. Using generated points.');
      final coin = _findMockCoin(coinId);
      return MockCryptoData.generateMockChartPoints(coin.currentPrice, days);
    }
  }

  @override
  Future<GlobalMarketModel> getGlobalMarketStats() async {
    final uri = Uri.parse('$_baseUrl/global');

    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return GlobalMarketModel.fromJson(data);
      } else {
        return MockCryptoData.mockGlobalMarket;
      }
    } catch (e) {
      debugPrint('Error fetching global market stats: $e. Using mock stats.');
      return MockCryptoData.mockGlobalMarket;
    }
  }

  CoinModel _findMockCoin(String coinId) {
    return MockCryptoData.mockCoins.firstWhere(
      (c) => c.id.toLowerCase() == coinId.toLowerCase(),
      orElse: () => MockCryptoData.mockCoins.first,
    );
  }
}

