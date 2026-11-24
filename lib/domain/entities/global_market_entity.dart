class GlobalMarketEntity {
  final double totalMarketCapUsd;
  final double total24hVolumeUsd;
  final double marketCapChangePercentage24h;
  final double btcDominance;
  final double ethDominance;
  final int activeCryptocurrencies;
  final int markets;

  const GlobalMarketEntity({
    required this.totalMarketCapUsd,
    required this.total24hVolumeUsd,
    required this.marketCapChangePercentage24h,
    required this.btcDominance,
    required this.ethDominance,
    required this.activeCryptocurrencies,
    required this.markets,
  });
}

