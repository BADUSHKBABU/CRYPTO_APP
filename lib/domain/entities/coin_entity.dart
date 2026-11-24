class CoinEntity {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double priceChangePercentage7d;
  final double circulatingSupply;
  final double totalSupply;
  final double maxSupply;
  final double ath;
  final double athChangePercentage;
  final String athDate;
  final List<double> sparklineIn7d;
  final String description;

  const CoinEntity({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    this.priceChangePercentage7d = 0.0,
    required this.circulatingSupply,
    this.totalSupply = 0.0,
    this.maxSupply = 0.0,
    this.ath = 0.0,
    this.athChangePercentage = 0.0,
    this.athDate = '',
    this.sparklineIn7d = const [],
    this.description = '',
  });

  bool get isPositiveChange => priceChangePercentage24h >= 0;
}

