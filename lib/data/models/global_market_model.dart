import '../../domain/entities/global_market_entity.dart';

class GlobalMarketModel extends GlobalMarketEntity {
  const GlobalMarketModel({
    required super.totalMarketCapUsd,
    required super.total24hVolumeUsd,
    required super.marketCapChangePercentage24h,
    required super.btcDominance,
    required super.ethDominance,
    required super.activeCryptocurrencies,
    required super.markets,
  });

  factory GlobalMarketModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    double totalCap = 0.0;
    if (data['total_market_cap'] != null && data['total_market_cap']['usd'] != null) {
      totalCap = (data['total_market_cap']['usd'] as num).toDouble();
    } else if (data['total_market_cap_usd'] != null) {
      totalCap = (data['total_market_cap_usd'] as num).toDouble();
    }

    double totalVol = 0.0;
    if (data['total_volume'] != null && data['total_volume']['usd'] != null) {
      totalVol = (data['total_volume']['usd'] as num).toDouble();
    } else if (data['total_24h_volume_usd'] != null) {
      totalVol = (data['total_24h_volume_usd'] as num).toDouble();
    }

    double btcDom = 0.0;
    double ethDom = 0.0;
    if (data['market_cap_percentage'] != null) {
      btcDom = (data['market_cap_percentage']['btc'] as num?)?.toDouble() ?? 0.0;
      ethDom = (data['market_cap_percentage']['eth'] as num?)?.toDouble() ?? 0.0;
    } else {
      btcDom = (data['btc_dominance'] as num?)?.toDouble() ?? 0.0;
      ethDom = (data['eth_dominance'] as num?)?.toDouble() ?? 0.0;
    }

    return GlobalMarketModel(
      totalMarketCapUsd: totalCap,
      total24hVolumeUsd: totalVol,
      marketCapChangePercentage24h: (data['market_cap_change_percentage_24h_usd'] as num?)?.toDouble() ?? 0.0,
      btcDominance: btcDom,
      ethDominance: ethDom,
      activeCryptocurrencies: (data['active_cryptocurrencies'] as num?)?.toInt() ?? 0,
      markets: (data['markets'] as num?)?.toInt() ?? 0,
    );
  }
}

