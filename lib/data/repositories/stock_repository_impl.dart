import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/stock_entity.dart';
import '../../domain/repositories/stock_repository.dart';
import '../models/stock_model.dart';
import '../sources/remote/stock_api_service.dart';
import '../sources/local/local_storage.dart';

class StockRepositoryImpl implements StockRepository {
  final StockApiService _apiService;
  final LocalStorage _localStorage;

  StockRepositoryImpl(this._apiService, this._localStorage);

  @override
  Future<Either<String, DashboardEntity>> getDashboard() async {
    try {
      // Check cache first
      final cached = _localStorage.getCache('dashboard');
      if (cached != null) {
        final model = DashboardModel.fromJson(cached);
        return Right(model.toEntity());
      }

      // Fetch from API - now returns DashboardResponse
      final response = await _apiService.getDashboard();
      
      if (response.data != null) {
        // Save to cache
        await _localStorage.saveCache('dashboard', response.data!.toJson());
        return Right(response.data!.toEntity());
      } else {
        return Left(response.message ?? 'Failed to load dashboard');
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<StockEntity>>> getStocksList({
    String? sector,
    int? page,
    int? limit,
  }) async {
    try {
      // Check cache
      final cacheKey = 'stocks_${sector ?? 'all'}_${page ?? 1}';
      final cached = _localStorage.getCache(cacheKey);
      if (cached != null && cached['items'] != null) {
        final items = (cached['items'] as List)
            .map((json) => StockModel.fromJson(json).toEntity())
            .toList();
        return Right(items);
      }

      // Fetch from API - now returns StocksListResponse
      final response = await _apiService.getStocksList(
        sector: sector,
        page: page,
        limit: limit,
      );

      // Extract stocks from the wrapper
      final stocks = response.stocks;

      // Save to cache
      await _localStorage.saveCache(
        cacheKey,
        {'items': stocks.map((s) => s.toJson()).toList()},
      );

      return Right(stocks.map((s) => s.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e, stack) {
      // Add stack trace for debugging
      print('Error in getStocksList: $e');
      print('Stack trace: $stack');
      return Left('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, StockDetailsEntity>> getStockDetails(String symbol) async {
    try {
      final response = await _apiService.getStockDetails(symbol);
      
      if (response.data != null) {
        return Right(response.data!.toEntity());
      } else {
        return Left(response.message ?? 'Failed to load stock details');
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ComparisonEntity>> compareStocks(
    List<String> symbols,
    String period,
  ) async {
    try {
      final response = await _apiService.compareStocks({
        'symbols': symbols,
        'period': period,
      });

      if (response.data != null) {
        final data = response.data!;
        
        final entity = ComparisonEntity(
          stocks: data.stocks.map((s) => s.toEntity()).toList(),
          comparison: data.comparison ?? {},
          period: data.period ?? period,
        );

        return Right(entity);
      } else {
        return Left(response.message ?? 'Failed to compare stocks');
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AnalysisEntity>> getStockAnalysis(
    String symbol,
    String period,
  ) async {
    try {
      final response = await _apiService.getStockAnalysis(symbol, period);
      
      if (response.data != null) {
        return Right(response.data!.toEntity());
      } else {
        return Left(response.message ?? 'Failed to load analysis');
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, MarketSummaryEntity>> getMarketSummary() async {
    try {
      final response = await _apiService.getMarketSummary();
      
      if (response.data != null) {
        return Right(response.data!.toEntity());
      } else {
        return Left(response.message ?? 'Failed to load market summary');
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<bool> addToWatchlist(String symbol) async {
    return await _localStorage.addToWatchlist(symbol);
  }

  @override
  Future<bool> removeFromWatchlist(String symbol) async {
    return await _localStorage.removeFromWatchlist(symbol);
  }

  @override
  List<String> getWatchlist() {
    return _localStorage.getWatchlist();
  }

  @override
  bool isInWatchlist(String symbol) {
    return _localStorage.isInWatchlist(symbol);
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'An unexpected error occurred';
    }
  }
}