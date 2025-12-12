// lib/data/models/stock_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/stock_entity.dart';

part 'stock_model.g.dart';


@JsonSerializable()
class StocksListResponse {
  final StocksDataWrapper data;

  StocksListResponse({required this.data});

  factory StocksListResponse.fromJson(Map<String, dynamic> json) =>
      _$StocksListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StocksListResponseToJson(this);

  List<StockModel> get stocks => data.stocks;
}

@JsonSerializable()
class StocksDataWrapper {
  final List<StockModel> stocks;

  StocksDataWrapper({required this.stocks});

  factory StocksDataWrapper.fromJson(Map<String, dynamic> json) =>
      _$StocksDataWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$StocksDataWrapperToJson(this);
}

// ==================== STOCK MODEL ====================

@JsonSerializable()
class StockModel {
  // ID can be int or String
  @JsonKey(fromJson: _idFromJson, toJson: _idToJson)
  final int? id;
  
  final String symbol;
  final String name;
  
  // API returns current_price as String like "445.00"
  @JsonKey(name: 'current_price', fromJson: _priceFromJson, toJson: _priceToJson)
  final double currentPrice;
  
  // API uses change_percentage, not change_percent
  @JsonKey(name: 'change_percentage', fromJson: _doubleFromJson, defaultValue: 0.0)
  final double changePercent;
  
  @JsonKey(fromJson: _doubleFromJson, defaultValue: 0.0)
  final double change;
  
  @JsonKey(fromJson: _doubleFromJson, defaultValue: 0.0)
  final double volume;
  
  final String? sector;
  
  @JsonKey(name: 'market_cap', fromJson: _nullableDoubleFromJson)
  final double? marketCap;
  
  // API uses last_update, not last_updated
  @JsonKey(name: 'last_update')
  final String? lastUpdated;

  StockModel({
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

  // Custom JSON converters
  static int? _idFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static dynamic _idToJson(int? value) => value;

  static double _priceFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _priceToJson(double value) => value.toString();

  static double _doubleFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _nullableDoubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory StockModel.fromJson(Map<String, dynamic> json) =>
      _$StockModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockModelToJson(this);

  StockEntity toEntity() {
    return StockEntity(
      id: id,
      symbol: symbol,
      name: name,
      currentPrice: currentPrice,
      changePercent: changePercent,
      change: change,
      volume: volume,
      sector: sector,
      marketCap: marketCap,
      lastUpdated: lastUpdated != null ? DateTime.tryParse(lastUpdated!) : null,
    );
  }

  factory StockModel.fromEntity(StockEntity entity) {
    return StockModel(
      id: entity.id,
      symbol: entity.symbol,
      name: entity.name,
      currentPrice: entity.currentPrice,
      changePercent: entity.changePercent,
      change: entity.change,
      volume: entity.volume,
      sector: entity.sector,
      marketCap: entity.marketCap,
      lastUpdated: entity.lastUpdated?.toIso8601String(),
    );
  }
}

// ==================== DASHBOARD MODEL ====================

/// Wrapper for dashboard API response
@JsonSerializable()
class DashboardResponse {
  final DashboardModel? data;
  final bool? success;
  final String? message;

  DashboardResponse({this.data, this.success, this.message});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);
}

@JsonSerializable()
class DashboardModel {
  @JsonKey(name: 'total_stocks', defaultValue: 0)
  final int totalStocks;
  
  @JsonKey(name: 'watchlist_count', defaultValue: 0)
  final int watchlistCount;
  
  @JsonKey(name: 'top_gainer')
  final StockModel? topGainer;
  
  @JsonKey(name: 'top_loser')
  final StockModel? topLoser;
  
  @JsonKey(name: 'market_summary')
  final MarketSummaryModel? marketSummary;
  
  @JsonKey(name: 'market_overview', defaultValue: [])
  final List<StockModel> marketOverview;
  
  @JsonKey(name: 'recent_activity', defaultValue: [])
  final List<ActivityModel> recentActivity;

  DashboardModel({
    this.totalStocks = 0,
    this.watchlistCount = 0,
    this.topGainer,
    this.topLoser,
    this.marketSummary,
    this.marketOverview = const [],
    this.recentActivity = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardModelToJson(this);

  DashboardEntity toEntity() {
    return DashboardEntity(
      totalStocks: totalStocks,
      watchlistCount: watchlistCount,
      topGainer: topGainer?.toEntity(),
      topLoser: topLoser?.toEntity(),
      marketSummary: marketSummary?.toEntity(),
      marketOverview: marketOverview.map((s) => s.toEntity()).toList(),
      recentActivity: recentActivity.map((a) => a.toEntity()).toList(),
    );
  }
}

// ==================== MARKET SUMMARY MODEL ====================

@JsonSerializable()
class MarketSummaryModel {
  @JsonKey(name: 'dse_index', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double dseIndex;
  
  @JsonKey(name: 'market_cap', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double marketCap;
  
  @JsonKey(name: 'total_volume', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double totalVolume;
  
  @JsonKey(defaultValue: 0)
  final int gainers;
  
  @JsonKey(defaultValue: 0)
  final int losers;

  MarketSummaryModel({
    this.dseIndex = 0.0,
    this.marketCap = 0.0,
    this.totalVolume = 0.0,
    this.gainers = 0,
    this.losers = 0,
  });

  factory MarketSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$MarketSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketSummaryModelToJson(this);

  MarketSummaryEntity toEntity() {
    return MarketSummaryEntity(
      dseIndex: dseIndex,
      marketCap: marketCap,
      totalVolume: totalVolume,
      gainers: gainers,
      losers: losers,
    );
  }
}

// ==================== ACTIVITY MODEL ====================

@JsonSerializable()
class ActivityModel {
  final String type;
  final String message;
  final String timestamp;
  
  @JsonKey(name: 'stock_symbol')
  final String? stockSymbol;

  ActivityModel({
    required this.type,
    required this.message,
    required this.timestamp,
    this.stockSymbol,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityModelToJson(this);

  ActivityEntity toEntity() {
    return ActivityEntity(
      type: type,
      message: message,
      timestamp: DateTime.tryParse(timestamp) ?? DateTime.now(),
      stockSymbol: stockSymbol,
    );
  }
}

// ==================== ANALYSIS MODEL ====================

/// Wrapper for analysis API response
@JsonSerializable()
class AnalysisResponse {
  final AnalysisModel? data;
  final bool? success;
  final String? message;

  AnalysisResponse({this.data, this.success, this.message});

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResponseToJson(this);
}

@JsonSerializable()
class AnalysisModel {
  final StockModel stock;
  final String recommendation;
  
  @JsonKey(defaultValue: 0)
  final int score;
  
  final ValuationModel? valuation;
  final PredictionModel? prediction;
  
  @JsonKey(name: 'financial_metrics', defaultValue: {})
  final Map<String, dynamic> financialMetrics;
  
  @JsonKey(name: 'positive_signals', defaultValue: [])
  final List<SignalModel> positiveSignals;
  
  @JsonKey(name: 'warning_signals', defaultValue: [])
  final List<SignalModel> warningSignals;

  AnalysisModel({
    required this.stock,
    required this.recommendation,
    this.score = 0,
    this.valuation,
    this.prediction,
    this.financialMetrics = const {},
    this.positiveSignals = const [],
    this.warningSignals = const [],
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$AnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisModelToJson(this);

  AnalysisEntity toEntity() {
    return AnalysisEntity(
      stock: stock.toEntity(),
      recommendation: recommendation,
      score: score,
      valuation: valuation?.toEntity(),
      prediction: prediction?.toEntity(),
      financialMetrics: financialMetrics,
      positiveSignals: positiveSignals.map((s) => s.toEntity()).toList(),
      warningSignals: warningSignals.map((s) => s.toEntity()).toList(),
    );
  }
}

// ==================== VALUATION MODEL ====================

@JsonSerializable()
class ValuationModel {
  final String status;
  
  @JsonKey(name: 'market_price', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double marketPrice;
  
  @JsonKey(name: 'book_value', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double bookValue;
  
  @JsonKey(name: 'graham_number', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double grahamNumber;
  
  @JsonKey(name: 'intrinsic_value', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double intrinsicValue;
  
  @JsonKey(name: 'margin_of_safety', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double marginOfSafety;

  ValuationModel({
    required this.status,
    this.marketPrice = 0.0,
    this.bookValue = 0.0,
    this.grahamNumber = 0.0,
    this.intrinsicValue = 0.0,
    this.marginOfSafety = 0.0,
  });

  factory ValuationModel.fromJson(Map<String, dynamic> json) =>
      _$ValuationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ValuationModelToJson(this);

  ValuationEntity toEntity() {
    return ValuationEntity(
      status: status,
      marketPrice: marketPrice,
      bookValue: bookValue,
      grahamNumber: grahamNumber,
      intrinsicValue: intrinsicValue,
      marginOfSafety: marginOfSafety,
    );
  }
}

// ==================== PREDICTION MODEL ====================

@JsonSerializable()
class PredictionModel {
  @JsonKey(name: 'expected_price', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double expectedPrice;
  
  @JsonKey(name: 'conservative_price', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double conservativePrice;
  
  @JsonKey(name: 'optimistic_price', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double optimisticPrice;
  
  @JsonKey(name: 'expected_change', fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double expectedChange;
  
  @JsonKey(defaultValue: 'Low')
  final String confidence;

  PredictionModel({
    this.expectedPrice = 0.0,
    this.conservativePrice = 0.0,
    this.optimisticPrice = 0.0,
    this.expectedChange = 0.0,
    this.confidence = 'Low',
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionModelToJson(this);

  PredictionEntity toEntity() {
    return PredictionEntity(
      expectedPrice: expectedPrice,
      conservativePrice: conservativePrice,
      optimisticPrice: optimisticPrice,
      expectedChange: expectedChange,
      confidence: confidence,
    );
  }
}

// ==================== SIGNAL MODEL ====================

@JsonSerializable()
class SignalModel {
  final String title;
  final String description;
  final String type;

  SignalModel({
    required this.title,
    required this.description,
    required this.type,
  });

  factory SignalModel.fromJson(Map<String, dynamic> json) =>
      _$SignalModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignalModelToJson(this);

  SignalEntity toEntity() {
    return SignalEntity(
      title: title,
      description: description,
      type: type,
    );
  }
}

// ==================== COMPARE RESPONSE ====================

@JsonSerializable()
class CompareResponse {
  final CompareDataModel? data;
  final bool? success;
  final String? message;

  CompareResponse({this.data, this.success, this.message});

  factory CompareResponse.fromJson(Map<String, dynamic> json) =>
      _$CompareResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CompareResponseToJson(this);
}

@JsonSerializable()
class CompareDataModel {
  final List<StockModel> stocks;
  final Map<String, dynamic>? comparison;
  final String? period;

  CompareDataModel({
    this.stocks = const [],
    this.comparison,
    this.period,
  });

  factory CompareDataModel.fromJson(Map<String, dynamic> json) =>
      _$CompareDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompareDataModelToJson(this);
}

// ==================== STOCK DETAILS RESPONSE ====================

@JsonSerializable()
class StockDetailsResponse {
  final StockDetailsModel? data;
  final bool? success;
  final String? message;

  StockDetailsResponse({this.data, this.success, this.message});

  factory StockDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$StockDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StockDetailsResponseToJson(this);
}

@JsonSerializable()
class StockDetailsModel {
  final StockModel stock;
  
  @JsonKey(name: 'price_history', defaultValue: [])
  final List<PriceHistoryModel> priceHistory;
  
  @JsonKey(name: 'financial_data')
  final Map<String, dynamic>? financialData;

  StockDetailsModel({
    required this.stock,
    this.priceHistory = const [],
    this.financialData,
  });

  factory StockDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$StockDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockDetailsModelToJson(this);

  StockDetailsEntity toEntity() {
    return StockDetailsEntity(
      stock: stock.toEntity(),
      priceHistory: priceHistory.map((p) => p.toEntity()).toList(),
      financialData: financialData ?? {},
    );
  }
}

@JsonSerializable()
class PriceHistoryModel {
  final String date;
  
  @JsonKey(fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double open;
  
  @JsonKey(fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double high;
  
  @JsonKey(fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double low;
  
  @JsonKey(fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double close;
  
  @JsonKey(fromJson: StockModel._doubleFromJson, defaultValue: 0.0)
  final double volume;

  PriceHistoryModel({
    required this.date,
    this.open = 0.0,
    this.high = 0.0,
    this.low = 0.0,
    this.close = 0.0,
    this.volume = 0.0,
  });

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PriceHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceHistoryModelToJson(this);

  PriceHistoryEntity toEntity() {
    return PriceHistoryEntity(
      date: DateTime.tryParse(date) ?? DateTime.now(),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}

// Add this to handle market summary response wrapper
@JsonSerializable()
class MarketSummaryResponse {
  final MarketSummaryModel? data;
  final bool? success;
  final String? message;

  MarketSummaryResponse({this.data, this.success, this.message});

  factory MarketSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$MarketSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MarketSummaryResponseToJson(this);
}