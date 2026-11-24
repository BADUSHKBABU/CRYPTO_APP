import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/chart_point_entity.dart';
import '../../../../domain/entities/coin_entity.dart';
import '../../../../domain/usecases/get_coin_details_usecase.dart';
import '../../../../domain/usecases/get_market_chart_usecase.dart';
import 'details_event.dart';
import 'details_state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final GetCoinDetailsUseCase getCoinDetailsUseCase;
  final GetMarketChartUseCase getMarketChartUseCase;

  DetailsBloc({
    required this.getCoinDetailsUseCase,
    required this.getMarketChartUseCase,
  }) : super(DetailsInitialState()) {
    on<FetchCoinDetailsEvent>(_onFetchCoinDetails);
    on<ChangeChartTimeframeEvent>(_onChangeChartTimeframe);
  }

  Future<void> _onFetchCoinDetails(
    FetchCoinDetailsEvent event,
    Emitter<DetailsState> emit,
  ) async {
    emit(DetailsLoadingState());
    try {
      final results = await Future.wait([
        getCoinDetailsUseCase.execute(event.coinId),
        getMarketChartUseCase.execute(event.coinId, days: event.days),
      ]);

      final coin = results[0] as CoinEntity;
      final points = results[1] as List<ChartPointEntity>;

      emit(DetailsLoadedState(
        coin: coin,
        chartPoints: points,
        selectedDays: event.days,
      ));
    } catch (e) {
      emit(DetailsErrorState(message: e.toString()));
    }
  }

  Future<void> _onChangeChartTimeframe(
    ChangeChartTimeframeEvent event,
    Emitter<DetailsState> emit,
  ) async {
    if (state is DetailsLoadedState) {
      final current = state as DetailsLoadedState;
      emit(current.copyWith(isChartLoading: true, selectedDays: event.days));
      try {
        final points = await getMarketChartUseCase.execute(event.coinId, days: event.days);
        emit(current.copyWith(
          chartPoints: points,
          selectedDays: event.days,
          isChartLoading: false,
        ));
      } catch (e) {
        emit(current.copyWith(isChartLoading: false));
      }
    }
  }
}

