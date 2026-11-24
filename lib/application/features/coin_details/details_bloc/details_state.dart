import '../../../../domain/entities/chart_point_entity.dart';
import '../../../../domain/entities/coin_entity.dart';

abstract class DetailsState {}

class DetailsInitialState extends DetailsState {}

class DetailsLoadingState extends DetailsState {}

class DetailsLoadedState extends DetailsState {
  final CoinEntity coin;
  final List<ChartPointEntity> chartPoints;
  final int selectedDays;
  final bool isChartLoading;

  DetailsLoadedState({
    required this.coin,
    required this.chartPoints,
    required this.selectedDays,
    this.isChartLoading = false,
  });

  DetailsLoadedState copyWith({
    CoinEntity? coin,
    List<ChartPointEntity>? chartPoints,
    int? selectedDays,
    bool? isChartLoading,
  }) {
    return DetailsLoadedState(
      coin: coin ?? this.coin,
      chartPoints: chartPoints ?? this.chartPoints,
      selectedDays: selectedDays ?? this.selectedDays,
      isChartLoading: isChartLoading ?? this.isChartLoading,
    );
  }
}

class DetailsErrorState extends DetailsState {
  final String message;
  DetailsErrorState({required this.message});
}

