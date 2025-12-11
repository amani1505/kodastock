
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/sources/remote/stock_api_service.dart';
import '../../data/sources/local/local_storage.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/usecases/stock_usecases.dart';
import '../../domain/entities/stock_entity.dart';

// Local Storage Provider
final localStorageProvider = FutureProvider<LocalStorage>((ref) async {
  return await LocalStorageProvider.create();
});

// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return DioClient.createDio();
});

// API Service Provider
final apiServiceProvider = Provider<StockApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return StockApiService(dio);
});

// Repository Provider
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final localStorage = ref.watch(localStorageProvider).value!;
  return StockRepositoryImpl(apiService, localStorage);
});

// Use Cases Providers
final getDashboardProvider = Provider<GetDashboard>((ref) {
  return GetDashboard(ref.watch(stockRepositoryProvider));
});

final getAllStocksProvider = Provider<GetAllStocks>((ref) {
  return GetAllStocks(ref.watch(stockRepositoryProvider));
});

final getStockDetailsProvider = Provider<GetStockDetails>((ref) {
  return GetStockDetails(ref.watch(stockRepositoryProvider));
});

final compareStocksProvider = Provider<CompareStocks>((ref) {
  return CompareStocks(ref.watch(stockRepositoryProvider));
});

final getStockAnalysisProvider = Provider<GetStockAnalysis>((ref) {
  return GetStockAnalysis(ref.watch(stockRepositoryProvider));
});

final manageWatchlistProvider = Provider<ManageWatchlist>((ref) {
  return ManageWatchlist(ref.watch(stockRepositoryProvider));
});

// State Providers for Dashboard
final dashboardProvider = FutureProvider<DashboardEntity>((ref) async {
  final getDashboard = ref.watch(getDashboardProvider);
  final result = await getDashboard();
  return result.fold(
    (error) => throw Exception(error),
    (dashboard) => dashboard,
  );
});

// State Provider for Stocks List
final stocksListProvider = FutureProvider.family<List<StockEntity>, String?>((
  ref,
  sector,
) async {
  final getAllStocks = ref.watch(getAllStocksProvider);
  final result = await getAllStocks(sector: sector);
  return result.fold(
    (error) => throw Exception(error),
    (stocks) => stocks,
  );
});

// State Provider for Stock Analysis
final stockAnalysisProvider = FutureProvider.family<AnalysisEntity, Map<String, String>>((
  ref,
  params,
) async {
  final getAnalysis = ref.watch(getStockAnalysisProvider);
  final result = await getAnalysis(params['symbol']!, params['period']!);
  return result.fold(
    (error) => throw Exception(error),
    (analysis) => analysis,
  );
});

// State Provider for Comparison
final comparisonProvider = FutureProvider.family<ComparisonEntity, Map<String, dynamic>>((
  ref,
  params,
) async {
  final compareStocks = ref.watch(compareStocksProvider);
  final result = await compareStocks(
    params['symbols'] as List<String>,
    params['period'] as String,
  );
  return result.fold(
    (error) => throw Exception(error),
    (comparison) => comparison,
  );
});

// Watchlist Provider
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<String>>((ref) {
  final manageWatchlist = ref.watch(manageWatchlistProvider);
  return WatchlistNotifier(manageWatchlist);
});

class WatchlistNotifier extends StateNotifier<List<String>> {
  final ManageWatchlist _manageWatchlist;

  WatchlistNotifier(this._manageWatchlist) : super([]) {
    _loadWatchlist();
  }

  void _loadWatchlist() {
    state = _manageWatchlist.getWatchlist();
  }

  Future<void> addToWatchlist(String symbol) async {
    final success = await _manageWatchlist.addToWatchlist(symbol);
    if (success) {
      state = [...state, symbol];
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    final success = await _manageWatchlist.removeFromWatchlist(symbol);
    if (success) {
      state = state.where((s) => s != symbol).toList();
    }
  }

  bool isInWatchlist(String symbol) {
    return state.contains(symbol);
  }
}

// Onboarding Provider
final onboardingProvider = FutureProvider<bool>((ref) async {
  final localStorage = await ref.watch(localStorageProvider.future);
  return localStorage.getOnboardingCompleted();
});

class OnboardingNotifier extends StateNotifier<bool> {
  final LocalStorage _localStorage;

  OnboardingNotifier(this._localStorage) : super(false) {
    _loadOnboardingStatus();
  }

  void _loadOnboardingStatus() {
    state = _localStorage.getOnboardingCompleted();
  }

  Future<void> completeOnboarding() async {
    await _localStorage.setOnboardingCompleted(true);
    state = true;
  }
}

final onboardingNotifierProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final localStorage = ref.watch(localStorageProvider).value!;
  return OnboardingNotifier(localStorage);
});
