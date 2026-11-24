import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'application/core/theme/app_theme.dart';
import 'application/features/auth/auth_bloc/auth_bloc.dart';
import 'application/features/auth/auth_bloc/auth_event.dart';
import 'application/features/market/market_bloc/market_bloc.dart';
import 'application/features/market/market_bloc/market_event.dart';
import 'application/features/market/ui/homePage.dart';
import 'application/features/watchlist/watchlist_bloc/watchlist_bloc.dart';
import 'application/features/watchlist/watchlist_bloc/watchlist_event.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/crypto_repository_impl.dart';
import 'data/repositories/watchlist_repository_impl.dart';
import 'domain/usecases/auth_usecases.dart';
import 'domain/usecases/get_coins_usecase.dart';
import 'domain/usecases/get_global_market_usecase.dart';
import 'domain/usecases/get_watchlist_usecase.dart';
import 'domain/usecases/toggle_watchlist_usecase.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated DefaultFirebaseOptions
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Domain & Data layer dependency setup
  final cryptoRepository = CryptoRepositoryImpl();
  final watchlistRepository = WatchlistRepositoryImpl();
  final authRepository = AuthRepositoryImpl();

  final getCoinsUseCase = GetCoinsUseCase(cryptoRepository);
  final getGlobalMarketUseCase = GetGlobalMarketUseCase(cryptoRepository);
  final getWatchlistUseCase = GetWatchlistUseCase(watchlistRepository);
  final toggleWatchlistUseCase = ToggleWatchlistUseCase(watchlistRepository);
  final authUseCases = AuthUseCases(authRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(authUseCases: authUseCases)..add(AuthCheckRequested()),
        ),
        BlocProvider<MarketBloc>(
          create: (_) => MarketBloc(
            getCoinsUseCase: getCoinsUseCase,
            getGlobalMarketUseCase: getGlobalMarketUseCase,
          )..add(FetchMarketDataEvent()),
        ),
        BlocProvider<WatchlistBloc>(
          create: (_) => WatchlistBloc(
            getWatchlistUseCase: getWatchlistUseCase,
            toggleWatchlistUseCase: toggleWatchlistUseCase,
          )..add(FetchWatchlistEvent()),
        ),
      ],
      child: const CryptoPulseApp(),
    ),
  );
}

class CryptoPulseApp extends StatelessWidget {
  const CryptoPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryptoPulse - Market Research',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
