import '../../domain/entities/coin_entity.dart';

class CoinModel extends CoinEntity {
  const CoinModel({
    required super.id,
    required super.symbol,
    required super.name,
    required super.image,
    required super.currentPrice,
    required super.marketCap,
    required super.marketCapRank,
    required super.totalVolume,
    required super.high24h,
    required super.low24h,
    required super.priceChange24h,
    required super.priceChangePercentage24h,
    super.priceChangePercentage7d,
    required super.circulatingSupply,
    super.totalSupply,
    super.maxSupply,
    super.ath,
    super.athChangePercentage,
    super.athDate,
    super.sparklineIn7d,
    super.description,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    List<double> sparkline = [];
    if (json['sparkline_in_7d'] != null && json['sparkline_in_7d']['price'] != null) {
      final list = json['sparkline_in_7d']['price'] as List<dynamic>;
      sparkline = list.map((e) => (e as num).toDouble()).toList();
    }

    String desc = '';
    if (json['description'] != null) {
      if (json['description'] is Map && json['description']['en'] != null) {
        desc = json['description']['en'].toString();
      } else if (json['description'] is String) {
        desc = json['description'].toString();
      }
    }

    return CoinModel(
      id: json['id']?.toString() ?? '',
      symbol: (json['symbol']?.toString() ?? '').toUpperCase(),
      name: json['name']?.toString() ?? '',
      image: json['image'] is Map ? (json['image']['large'] ?? json['image']['small'] ?? '') : (json['image']?.toString() ?? ''),
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt() ?? 0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0.0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0.0,
      priceChange24h: (json['price_change_24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h: (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage7d: (json['price_change_percentage_7d_in_currency'] as num?)?.toDouble() ?? 0.0,
      circulatingSupply: (json['circulating_supply'] as num?)?.toDouble() ?? 0.0,
      totalSupply: (json['total_supply'] as num?)?.toDouble() ?? 0.0,
      maxSupply: (json['max_supply'] as num?)?.toDouble() ?? 0.0,
      ath: (json['ath'] as num?)?.toDouble() ?? 0.0,
      athChangePercentage: (json['ath_change_percentage'] as num?)?.toDouble() ?? 0.0,
      athDate: json['ath_date']?.toString() ?? '',
      sparklineIn7d: sparkline,
      description: desc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'total_volume': totalVolume,
      'high_24h': high24h,
      'low_24h': low24h,
      'price_change_24h': priceChange24h,
      'price_change_percentage_24h': priceChangePercentage24h,
      'price_change_percentage_7d_in_currency': priceChangePercentage7d,
      'circulating_supply': circulatingSupply,
      'total_supply': totalSupply,
      'max_supply': maxSupply,
      'ath': ath,
      'ath_change_percentage': athChangePercentage,
      'ath_date': athDate,
      'sparkline_in_7d': {'price': sparklineIn7d},
      'description': description,
    };
  }

  CoinModel copyWith({
    String? description,
    List<double>? sparklineIn7d,
    double? ath,
    double? athChangePercentage,
    String? athDate,
  }) {
    return CoinModel(
      id: id,
      symbol: symbol,
      name: name,
      image: image,
      currentPrice: currentPrice,
      marketCap: marketCap,
      marketCapRank: marketCapRank,
      totalVolume: totalVolume,
      high24h: high24h,
      low24h: low24h,
      priceChange24h: priceChange24h,
      priceChangePercentage24h: priceChangePercentage24h,
      priceChangePercentage7d: priceChangePercentage7d,
      circulatingSupply: circulatingSupply,
      totalSupply: totalSupply,
      maxSupply: maxSupply,
      ath: ath ?? this.ath,
      athChangePercentage: athChangePercentage ?? this.athChangePercentage,
      athDate: athDate ?? this.athDate,
      sparklineIn7d: sparklineIn7d ?? this.sparklineIn7d,
      description: description ?? this.description,
    );
  }
}

