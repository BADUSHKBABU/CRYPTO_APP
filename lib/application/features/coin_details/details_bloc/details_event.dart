abstract class DetailsEvent {}

class FetchCoinDetailsEvent extends DetailsEvent {
  final String coinId;
  final int days;
  FetchCoinDetailsEvent({required this.coinId, this.days = 7});
}

class ChangeChartTimeframeEvent extends DetailsEvent {
  final String coinId;
  final int days;
  ChangeChartTimeframeEvent({required this.coinId, required this.days});
}

