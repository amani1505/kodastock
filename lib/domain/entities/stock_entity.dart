class StockEntity {
  final int? id;
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
    this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    this.changePercent = 0.0,
    this.change = 0.0,
    this.volume = 0.0,
    this.sector,
    this.marketCap,
    this.lastUpdated,
  });

  // Existing getters
  bool get isPositive => change >= 0;
  bool get isNegative => change < 0;

  // Add these new getters
  bool get isGainer => changePercent > 0;
  bool get isLoser => changePercent < 0;

  StockEntity copyWith({
    int? id,
    String? symbol,
    String? name,
    double? currentPrice,
    double? changePercent,
    double? change,
    double? volume,
    String? sector,
    double? marketCap,
    DateTime? lastUpdated,
  }) {
    return StockEntity(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      changePercent: changePercent ?? this.changePercent,
      change: change ?? this.change,
      volume: volume ?? this.volume,
      sector: sector ?? this.sector,
      marketCap: marketCap ?? this.marketCap,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockEntity && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;

  @override
  String toString() {
    return 'StockEntity(id: $id, symbol: $symbol, name: $name, price: $currentPrice)';
  }
}

class DashboardEntity {
  final int totalStocks;
  final int watchlistCount;
  final int totalGainers;
  final int totalLosers;
  final StockEntity? topGainer;
  final StockEntity? topLoser;
  final MarketSummaryEntity? marketSummary; // Made nullable
  final List<StockEntity> marketOverview;
  final List<ActivityEntity> recentActivity;

  const DashboardEntity({
    this.totalStocks = 0,
    this.watchlistCount = 0,
    this.totalGainers = 0,
    this.totalLosers = 0,
    this.topGainer,
    this.topLoser,
    this.marketSummary, // Now accepts null
    this.marketOverview = const [],
    this.recentActivity = const [],
  });

  DashboardEntity copyWith({
    int? totalStocks,
    int? watchlistCount,
    int? totalGainers,
    int? totalLosers,
    StockEntity? topGainer,
    StockEntity? topLoser,
    MarketSummaryEntity? marketSummary,
    List<StockEntity>? marketOverview,
    List<ActivityEntity>? recentActivity,
  }) {
    return DashboardEntity(
      totalStocks: totalStocks ?? this.totalStocks,
      watchlistCount: watchlistCount ?? this.watchlistCount,
      totalGainers: totalGainers ?? this.totalGainers,
      totalLosers: totalLosers ?? this.totalLosers,
      topGainer: topGainer ?? this.topGainer,
      topLoser: topLoser ?? this.topLoser,
      marketSummary: marketSummary ?? this.marketSummary,
      marketOverview: marketOverview ?? this.marketOverview,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }
}

class MarketSummaryEntity {
  final double dseIndex;
  final double marketCap;
  final double totalVolume;
  final int gainers;
  final int losers;

  const MarketSummaryEntity({
    this.dseIndex = 0.0,
    this.marketCap = 0.0,
    this.totalVolume = 0.0,
    this.gainers = 0,
    this.losers = 0,
  });

  MarketSummaryEntity copyWith({
    double? dseIndex,
    double? marketCap,
    double? totalVolume,
    int? gainers,
    int? losers,
  }) {
    return MarketSummaryEntity(
      dseIndex: dseIndex ?? this.dseIndex,
      marketCap: marketCap ?? this.marketCap,
      totalVolume: totalVolume ?? this.totalVolume,
      gainers: gainers ?? this.gainers,
      losers: losers ?? this.losers,
    );
  }
}

class ActivityEntity {
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

  ActivityEntity copyWith({
    String? type,
    String? message,
    DateTime? timestamp,
    String? stockSymbol,
  }) {
    return ActivityEntity(
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      stockSymbol: stockSymbol ?? this.stockSymbol,
    );
  }
}

class AnalysisEntity {
  final StockEntity stock;
  final String recommendation;
  final int score;
  final ValuationEntity? valuation; // Made nullable
  final PredictionEntity? prediction; // Made nullable
  final Map<String, dynamic> financialMetrics;
  final List<SignalEntity> positiveSignals;
  final List<SignalEntity> warningSignals;

  const AnalysisEntity({
    required this.stock,
    required this.recommendation,
    this.score = 0,
    this.valuation, // Now accepts null
    this.prediction, // Now accepts null
    this.financialMetrics = const {},
    this.positiveSignals = const [],
    this.warningSignals = const [],
  });

  AnalysisEntity copyWith({
    StockEntity? stock,
    String? recommendation,
    int? score,
    ValuationEntity? valuation,
    PredictionEntity? prediction,
    Map<String, dynamic>? financialMetrics,
    List<SignalEntity>? positiveSignals,
    List<SignalEntity>? warningSignals,
  }) {
    return AnalysisEntity(
      stock: stock ?? this.stock,
      recommendation: recommendation ?? this.recommendation,
      score: score ?? this.score,
      valuation: valuation ?? this.valuation,
      prediction: prediction ?? this.prediction,
      financialMetrics: financialMetrics ?? this.financialMetrics,
      positiveSignals: positiveSignals ?? this.positiveSignals,
      warningSignals: warningSignals ?? this.warningSignals,
    );
  }

  // Helper getters
  bool get isStrongBuy => recommendation.toLowerCase() == 'strong buy';
  bool get isBuy => recommendation.toLowerCase() == 'buy';
  bool get isHold => recommendation.toLowerCase() == 'hold';
  bool get isSell => recommendation.toLowerCase() == 'sell';
}

class ValuationEntity {
  final String status;
  final double marketPrice;
  final double bookValue;
  final double grahamNumber;
  final double intrinsicValue;
  final double marginOfSafety;

  const ValuationEntity({
    required this.status,
    this.marketPrice = 0.0,
    this.bookValue = 0.0,
    this.grahamNumber = 0.0,
    this.intrinsicValue = 0.0,
    this.marginOfSafety = 0.0,
  });

  ValuationEntity copyWith({
    String? status,
    double? marketPrice,
    double? bookValue,
    double? grahamNumber,
    double? intrinsicValue,
    double? marginOfSafety,
  }) {
    return ValuationEntity(
      status: status ?? this.status,
      marketPrice: marketPrice ?? this.marketPrice,
      bookValue: bookValue ?? this.bookValue,
      grahamNumber: grahamNumber ?? this.grahamNumber,
      intrinsicValue: intrinsicValue ?? this.intrinsicValue,
      marginOfSafety: marginOfSafety ?? this.marginOfSafety,
    );
  }

  // Helper getters
  bool get isUndervalued => status.toLowerCase() == 'undervalued';
  bool get isOvervalued => status.toLowerCase() == 'overvalued';
  bool get isFairlyValued => status.toLowerCase() == 'fairly valued';
}

class PredictionEntity {
  final double expectedPrice;
  final double conservativePrice;
  final double optimisticPrice;
  final double expectedChange;
  final String confidence;

  const PredictionEntity({
    this.expectedPrice = 0.0,
    this.conservativePrice = 0.0,
    this.optimisticPrice = 0.0,
    this.expectedChange = 0.0,
    this.confidence = 'Low',
  });

  PredictionEntity copyWith({
    double? expectedPrice,
    double? conservativePrice,
    double? optimisticPrice,
    double? expectedChange,
    String? confidence,
  }) {
    return PredictionEntity(
      expectedPrice: expectedPrice ?? this.expectedPrice,
      conservativePrice: conservativePrice ?? this.conservativePrice,
      optimisticPrice: optimisticPrice ?? this.optimisticPrice,
      expectedChange: expectedChange ?? this.expectedChange,
      confidence: confidence ?? this.confidence,
    );
  }

  // Helper getters
  bool get isHighConfidence => confidence.toLowerCase() == 'high';
  bool get isMediumConfidence => confidence.toLowerCase() == 'medium';
  bool get isLowConfidence => confidence.toLowerCase() == 'low';
}

class SignalEntity {
  final String title;
  final String description;
  final String type;

  const SignalEntity({
    required this.title,
    required this.description,
    required this.type,
  });

  SignalEntity copyWith({String? title, String? description, String? type}) {
    return SignalEntity(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }

  // Helper getters
  bool get isPositive => type.toLowerCase() == 'positive';
  bool get isWarning => type.toLowerCase() == 'warning';
  bool get isNegative => type.toLowerCase() == 'negative';
}

class ComparisonEntity {
  final List<StockEntity> stocks;
  final Map<String, dynamic> comparison;
  final String period;

  const ComparisonEntity({
    this.stocks = const [],
    this.comparison = const {},
    this.period = '1M',
  });

  ComparisonEntity copyWith({
    List<StockEntity>? stocks,
    Map<String, dynamic>? comparison,
    String? period,
  }) {
    return ComparisonEntity(
      stocks: stocks ?? this.stocks,
      comparison: comparison ?? this.comparison,
      period: period ?? this.period,
    );
  }
}

class StockDetailsEntity {
  final StockEntity stock;
  final List<PriceHistoryEntity> priceHistory;
  final Map<String, dynamic> financialData;

  const StockDetailsEntity({
    required this.stock,
    this.priceHistory = const [],
    this.financialData = const {},
  });

  StockDetailsEntity copyWith({
    StockEntity? stock,
    List<PriceHistoryEntity>? priceHistory,
    Map<String, dynamic>? financialData,
  }) {
    return StockDetailsEntity(
      stock: stock ?? this.stock,
      priceHistory: priceHistory ?? this.priceHistory,
      financialData: financialData ?? this.financialData,
    );
  }
}

class PriceHistoryEntity {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const PriceHistoryEntity({
    required this.date,
    this.open = 0.0,
    this.high = 0.0,
    this.low = 0.0,
    this.close = 0.0,
    this.volume = 0.0,
  });

  PriceHistoryEntity copyWith({
    DateTime? date,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
  }) {
    return PriceHistoryEntity(
      date: date ?? this.date,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }
}
