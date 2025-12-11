import 'package:dartz/dartz.dart';
import '../entities/stock_entity.dart';

abstract class StockRepository {
  Future<Either<String, DashboardEntity>> getDashboard();
  Future<Either<String, List<StockEntity>>> getStocksList({
    String? sector,
    int? page,
    int? limit,
  });
  Future<Either<String, StockDetailsEntity>> getStockDetails(String symbol);
  Future<Either<String, ComparisonEntity>> compareStocks(
    List<String> symbols,
    String period,
  );
  Future<Either<String, AnalysisEntity>> getStockAnalysis(
    String symbol,
    String period,
  );
  Future<Either<String, MarketSummaryEntity>> getMarketSummary();
  
  // Watchlist operations
  Future<bool> addToWatchlist(String symbol);
  Future<bool> removeFromWatchlist(String symbol);
  List<String> getWatchlist();
  bool isInWatchlist(String symbol);
}
