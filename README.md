# CryptoPulse - Flutter Crypto Market & Research App

A modern, production-ready CoinGecko-style cryptocurrency market and research mobile application built with **Flutter** and **Clean Architecture**, powered by **BLoC State Management** and **CoinGecko REST API** with resilient fallback and Firebase authentication.

---

## 🏛️ Clean Architecture Design (Reference Pattern)

This project strictly follows the Clean Architecture pattern referenced in `D:\clean Archtecture\clean_architecture_simple_post\lib`, split into three decoupled layers:

```
lib/
├── application/                         # Presentation Layer (BLoC + UI)
│   ├── core/                            # Core Design System, Theme, Formatter & Widgets
│   │   ├── constants/api_constants.dart # REST endpoints & query configurations
│   │   ├── theme/app_theme.dart         # Slate-dark modern crypto theme & colors
│   │   ├── utils/currency_formatter.dart# Currency, compact number & % formatters
│   │   └── widgets/                     # Reusable UI states:
│   │       ├── app_loading_widget.dart  # Central loading state
│   │       ├── app_error_widget.dart    # Error state with retry callback
│   │       ├── app_empty_widget.dart    # Empty state with action CTA
│   │       └── price_change_badge.dart  # Color-coded % ticker pill (+/-)
│   └── features/
│       ├── auth/                        # User Authentication Feature
│       │   ├── auth_bloc/               # AuthBloc, AuthEvent, AuthState
│       │   └── ui/                      # LoginPage, RegisterPage, UserProfileDialog
│       ├── market/                      # Market & Coins Exploration Feature
│       │   ├── market_bloc/             # MarketBloc, MarketEvent, MarketState
│       │   ├── ui/                      # MainNavPage, MarketPage
│       │   └── widgets/                 # CoinListTile, SearchAndFilterBar, MarketSummaryHeader
│       ├── coin_details/                # Coin Research & Details Feature
│       │   ├── details_bloc/            # DetailsBloc, DetailsEvent, DetailsState
│       │   ├── ui/                      # CoinDetailsPage
│       │   └── widgets/                 # InteractivePriceChart, MarketStatsGrid
│       ├── market_stats/                # Global Intelligence Feature
│       │   └── ui/                      # MarketStatsPage
│       └── watchlist/                   # Watchlist & Portfolio Feature
│           ├── watchlist_bloc/          # WatchlistBloc, WatchlistEvent, WatchlistState
│           └── ui/                      # WatchlistPage
├── data/                                # Data Layer (Repositories & Data Sources)
│   ├── datasource/
│   │   ├── crypto_remote_data_source.dart # CoinGecko REST client with auto-fallback
│   │   ├── mock_crypto_data.dart        # High-fidelity realistic market data & charts
│   │   ├── watchlist_local_data_source.dart # SharedPreferences persistent storage
│   │   └── auth_remote_data_source.dart # Firebase Auth with demo fallback
│   ├── models/
│   │   ├── coin_model.dart              # Extends CoinEntity with fromJson/toJson
│   │   ├── global_market_model.dart     # Extends GlobalMarketEntity with fromJson
│   │   ├── chart_point_model.dart       # Extends ChartPointEntity
│   │   └── user_model.dart              # Extends UserEntity
│   └── repositories/
│       ├── crypto_repository_impl.dart  # Implements CryptoRepository
│       ├── watchlist_repository_impl.dart# Implements WatchlistRepository
│       └── auth_repository_impl.dart    # Implements AuthRepository
└── domain/                              # Domain Layer (Pure Business Logic)
    ├── entities/
    │   ├── coin_entity.dart             # Pure coin business object
    │   ├── global_market_entity.dart    # Global market metrics object
    │   ├── chart_point_entity.dart      # Time-series chart point object
    │   └── user_entity.dart             # User profile object
    ├── repositories/
    │   ├── crypto_repository.dart       # Abstract crypto contract
    │   ├── watchlist_repository.dart    # Abstract watchlist contract
    │   └── auth_repository.dart         # Abstract auth contract
    └── usecases/
        ├── get_coins_usecase.dart       # Fetch market coins
        ├── get_coin_details_usecase.dart# Fetch deep coin metrics
        ├── get_market_chart_usecase.dart# Fetch price history (24h, 7d, 30d, 1y)
        ├── get_global_market_usecase.dart# Fetch global crypto cap & volume
        ├── get_watchlist_usecase.dart   # Fetch saved coin IDs
        ├── toggle_watchlist_usecase.dart# Add/remove coin from watchlist
        └── auth_usecases.dart           # Login, Register, Guest login, Sign out
```

---

## 📱 Features Delivered

### 1. Coin List Screen
- **Live/Mock Price Data**: Displays real-time prices, 24h percentage changes, market cap ranks, and market caps.
- **Instant Search**: Search by full name (e.g., "Ethereum") or ticker symbol (e.g., "SOL").
- **Filtering**: Quick chips for `All Coins`, `Top 10`, `Top Gainers`, and `Top Losers`.
- **Sorting Modal**: Sort by Market Cap (High to Low / Low to High), Price, 24h Change (Gainers / Losers), and Name (A-Z).
- **Pull-to-Refresh**: Easily reload latest rates on demand.
- **Quick Watchlist Toggle**: Star/unstar directly from the list without opening details.

### 2. Coin Details Screen
- **Header**: High-resolution coin logo, current price, 24h change badge, and global rank badge.
- **Interactive Price Chart**:
  - Built with `fl_chart`.
  - Gradient-filled curve matching trend (green for profit, red for loss).
  - Timeframe selector buttons: **24H**, **7D**, **30D**, **1Y**.
  - **Live Touch Scrubbing**: Slide your finger across the chart to view historical price and exact timestamp dynamically in the header!
- **Market Statistics Grid**:
  - Market Cap, 24h Volume, 24h High, 24h Low.
  - Circulating Supply, Max Supply.
  - All-Time High (ATH), ATH percentage change, and ATH Date.
- **About Section**: Detailed coin background, technology overview, and purpose.

### 3. Market Statistics Screen
- **Global Overview**: Total Market Cap ($2.68T+), 24h Volume ($94B+), Active Cryptos, and Total Exchanges.
- **Market Dominance Visualizer**: Colorful visual proportion bar comparing Bitcoin (BTC), Ethereum (ETH), and Altcoins.
- **Market Sentiment Index**: Fear & Greed indicator with bullish/bearish commentary.
- **Top Movers**: Dedicated list of Top 3 24h Gainers and Top 3 24h Losers.

### 4. Watchlist Screen
- **Local Persistence**: Stores favorite coins persistently in `SharedPreferences`.
- **Aggregate Performance**: Computes total watchlist value and average 24h move.
- **Swipe-to-Remove**: Swipe left on any coin to unwatch with confirmation feedback.
- **Empty State**: Friendly CTA button that guides the user back to the market to explore coins.

### 5. Firebase & User Authentication
- **Clean Architecture Auth**: `AuthRepository` with `Stream<UserEntity?>`.
- **Dual Support**:
  - Firebase Authentication (`FirebaseAuth.instance`) when Firebase credentials are configured.
  - **Resilient Guest / Demo Mode**: Instant 1-click guest login for testing out-of-the-box without requiring initial `google-services.json` setup.
- **Profile Dialog**: View active session type, email, UID, and sign out.

### 6. State Handling (Loading, Error, Empty)
- `AppLoadingWidget`: Non-blocking centered indicator with informative text.
- `AppErrorWidget`: Network failure indicator with a prominent "Try Again" button that retries API fetching.
- `AppEmptyWidget`: Custom empty state for searches with no results or an empty watchlist.

---

## 🚀 How to Run the App

### Prerequisites
- Flutter SDK (3.19+ or 3.35+)
- Dart SDK (3.0+)

### Commands
1. Navigate to the project root:
   ```bash
   cd "d:\cryspto app\crysptoapp"
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run unit tests to verify:
   ```bash
   flutter test
   ```
4. Run the app:
   ```bash
   flutter run
   # Or run in Chrome browser:
   flutter run -d chrome
   ```

---

## 🤖 Handoff Prompt for Next Agent (If Tokens End)

If you need another AI agent to continue or expand this project, copy-paste the exact prompt below:

```text
PROJECT: Flutter Crypto Market & Research App (CryptoPulse)
LOCATION: d:\cryspto app\crysptoapp
ARCHITECTURE: Clean Architecture (domain, data, application) matching D:\clean Archtecture\clean_architecture_simple_post\lib.
STATUS:
- All core layers implemented (domain/entities, domain/repositories, domain/usecases, data/datasource, data/models, data/repositories, application/features).
- Features: Market list (search, filter, sort), Coin Details (fl_chart interactive price chart with 24H/7D/30D/1Y timeframes and scrubbing touch callbacks, market stats grid), Market Statistics (global cap, BTC/ETH dominance, sentiment, top movers), Watchlist (SharedPreferences persistence, swipe to delete), Auth (Firebase Auth + Guest demo mode), and Loading/Error/Empty states.
- All Flutter tests pass ("All tests passed!") and flutter analyze reports "No issues found!".

NEXT STEPS / EXTENSIONS YOU CAN WORK ON:
1. Add biometric authentication (local_auth) for extra security.
2. Add price alerts / push notifications (firebase_messaging or flutter_local_notifications).
3. Connect a WebSocket endpoint (e.g., Binance or CoinCap WebSocket) for live second-by-second ticker updates.
```
