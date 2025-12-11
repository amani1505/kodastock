import 'package:dartz/dartz.dart';
import '../entities/stock_entity.dart';
import '../repositories/stock_repository.dart';

class GetDashboard {
  final StockRepository repository;

  GetDashboard(this.repository);

  Future<Either<String, DashboardEntity>> call() async {
    return await repository.getDashboard();
  }
}

class GetAllStocks {
  final StockRepository repository;

  GetAllStocks(this.repository);

  Future<Either<String, List<StockEntity>>> call({
    String? sector,
    int? page,
    int? limit,
  }) async {
    return await repository.getStocksList(
      sector: sector,
      page: page,
      limit: limit,
    );
  }
}

class GetStockDetails {
  final StockRepository repository;

  GetStockDetails(this.repository);

  Future<Either<String, StockDetailsEntity>> call(String symbol) async {
    return await repository.getStockDetails(symbol);
  }
}

class CompareStocks {
  final StockRepository repository;

  CompareStocks(this.repository);

  Future<Either<String, ComparisonEntity>> call(
    List<String> symbols,
    String period,
  ) async {
    return await repository.compareStocks(symbols, period);
  }
}

class GetStockAnalysis {
  final StockRepository repository;

  GetStockAnalysis(this.repository);

  Future<Either<String, AnalysisEntity>> call(
    String symbol,
    String period,
  ) async {
    return await repository.getStockAnalysis(symbol, period);
  }
}

class ManageWatchlist {
  final StockRepository repository;

  ManageWatchlist(this.repository);

  Future<bool> addToWatchlist(String symbol) async {
    return await repository.addToWatchlist(symbol);
  }

  Future<bool> removeFromWatchlist(String symbol) async {
    return await repository.removeFromWatchlist(symbol);
  }

  List<String> getWatchlist() {
    return repository.getWatchlist();
  }

  bool isInWatchlist(String symbol) {
    return repository.isInWatchlist(symbol);
  }
}
