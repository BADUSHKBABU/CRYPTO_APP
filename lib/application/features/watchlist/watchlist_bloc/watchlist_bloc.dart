import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/get_watchlist_usecase.dart';
import '../../../../domain/usecases/toggle_watchlist_usecase.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlistUseCase getWatchlistUseCase;
  final ToggleWatchlistUseCase toggleWatchlistUseCase;

  WatchlistBloc({
    required this.getWatchlistUseCase,
    required this.toggleWatchlistUseCase,
  }) : super(WatchlistInitialState()) {
    on<FetchWatchlistEvent>(_onFetchWatchlist);
    on<ToggleWatchlistCoinEvent>(_onToggleWatchlist);
  }

  Future<void> _onFetchWatchlist(
    FetchWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(WatchlistLoadingState());
    try {
      final ids = await getWatchlistUseCase.execute();
      emit(WatchlistLoadedState(coinIds: ids));
    } catch (e) {
      emit(WatchlistErrorState(message: e.toString()));
    }
  }

  Future<void> _onToggleWatchlist(
    ToggleWatchlistCoinEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await toggleWatchlistUseCase.execute(event.coinId);
      final ids = await getWatchlistUseCase.execute();
      emit(WatchlistLoadedState(coinIds: ids));
    } catch (e) {
      emit(WatchlistErrorState(message: e.toString()));
    }
  }
}

