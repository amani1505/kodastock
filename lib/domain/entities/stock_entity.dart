import 'package:equatable/equatable.dart';

class StockEntity extends Equatable {
  final String symbol;
  final String name;
  final double currentPrice;
  final double changePercent;
  final double change;
  final double volume;
  final String? sector;
  final double? marketCap;
  final DateTime? lastUpdated;

  const StockEntity({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.changePercent,
    required this.change,
    required this.volume,
    this.sector,
    this.marketCap,
    this.lastUpdated,
  });

  bool get isGainer => changePercent > 0;
  bool get isLoser => changePercent < 0;

  @override
  List<Object?> get props => [
        symbol,
        name,
        currentPrice,
        changePercent,
        change,
        volume,
        sector,
        marketCap,
        lastUpdated,
      ];
}

class DashboardEntity extends Equatable {
  final int totalStocks;
  final int watchlistCount;
  final StockEntity? topGainer;
  final StockEntity? topLoser;
  final MarketSummaryEntity marketSummary;
  final List<StockEntity> marketOverview;
  final List<ActivityEntity> recentActivity;

  const DashboardEntity({
    required this.totalStocks,
    required this.watchlistCount,
    this.topGainer,
    this.topLoser,
    required this.marketSummary,
    required this.marketOverview,
    required this.recentActivity,
  });

  @override
  List<Object?> get props => [
        totalStocks,
        watchlistCount,
        topGainer,
        topLoser,
        marketSummary,
        marketOverview,
        recentActivity,
      ];
}

class MarketSummaryEntity extends Equatable {
  final double dseIndex;
  final double marketCap;
  final double totalVolume;
  final int gainers;
  final int losers;

  const MarketSummaryEntity({
    required this.dseIndex,
    required this.marketCap,
    required this.totalVolume,
    required this.gainers,
    required this.losers,
  });

  @override
  List<Object?> get props => [dseIndex, marketCap, totalVolume, gainers, losers];
}

class ActivityEntity extends Equatable {
  final String type;
  final String message;
  final DateTime timestamp;
  final String? stockSymbol;

  const ActivityEntity({
    required this.type,
    required this.message,
    required this.timestamp,
    this.stockSymbol,
  });

  @override
  List<Object?> get props => [type, message, timestamp, stockSymbol];
}

class StockDetailsEntity extends Equatable {
  final StockEntity stock;
  final Map<String, dynamic> metrics;
  final List<PricePoint> priceHistory;
  final String? description;
  final String? ceo;
  final int? employees;

  const StockDetailsEntity({
    required this.stock,
    required this.metrics,
    required this.priceHistory,
    this.description,
    this.ceo,
    this.employees,
  });

  @override
  List<Object?> get props => [stock, metrics, priceHistory, description, ceo, employees];
}

class PricePoint extends Equatable {
  final DateTime date;
  final double price;
  final double volume;

  const PricePoint({
    required this.date,
    required this.price,
    required this.volume,
  });

  @override
  List<Object?> get props => [date, price, volume];
}

class ComparisonEntity extends Equatable {
  final List<StockEntity> stocks;
  final Map<String, dynamic> metrics;
  final String? recommendation;
  final String? bestOverall;
  final String? bestValue;
  final String? bestGrowth;
  final String? safestPick;

  const ComparisonEntity({
    required this.stocks,
    required this.metrics,
    this.recommendation,
    this.bestOverall,
    this.bestValue,
    this.bestGrowth,
    this.safestPick,
  });

  @override
  List<Object?> get props => [
        stocks,
        metrics,
        recommendation,
        bestOverall,
        bestValue,
        bestGrowth,
        safestPick,
      ];
}

class AnalysisEntity extends Equatable {
  final StockEntity stock;
  final String recommendation;
  final int score;
  final ValuationEntity valuation;
  final PredictionEntity prediction;
  final Map<String, dynamic> financialMetrics;
  final List<SignalEntity> positiveSignals;
  final List<SignalEntity> warningSignals;

  const AnalysisEntity({
    required this.stock,
    required this.recommendation,
    required this.score,
    required this.valuation,
    required this.prediction,
    required this.financialMetrics,
    required this.positiveSignals,
    required this.warningSignals,
  });

  @override
  List<Object?> get props => [
        stock,
        recommendation,
        score,
        valuation,
        prediction,
        financialMetrics,
        positiveSignals,
        warningSignals,
      ];
}

class ValuationEntity extends Equatable {
  final String status;
  final double marketPrice;
  final double bookValue;
  final double grahamNumber;
  final double intrinsicValue;
  final double marginOfSafety;

  const ValuationEntity({
    required this.status,
    required this.marketPrice,
    required this.bookValue,
    required this.grahamNumber,
    required this.intrinsicValue,
    required this.marginOfSafety,
  });

  @override
  List<Object?> get props => [
        status,
        marketPrice,
        bookValue,
        grahamNumber,
        intrinsicValue,
        marginOfSafety,
      ];
}

class PredictionEntity extends Equatable {
  final double expectedPrice;
  final double conservativePrice;
  final double optimisticPrice;
  final double expectedChange;
  final String confidence;

  const PredictionEntity({
    required this.expectedPrice,
    required this.conservativePrice,
    required this.optimisticPrice,
    required this.expectedChange,
    required this.confidence,
  });

  @override
  List<Object?> get props => [
        expectedPrice,
        conservativePrice,
        optimisticPrice,
        expectedChange,
        confidence,
      ];
}

class SignalEntity extends Equatable {
  final String title;
  final String description;
  final String type; // 'positive' or 'warning'

  const SignalEntity({
    required this.title,
    required this.description,
    required this.type,
  });

  @override
  List<Object?> get props => [title, description, type];
}
