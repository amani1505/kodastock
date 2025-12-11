import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/stock_entity.dart';

part 'stock_model.g.dart';

@JsonSerializable()
class StockModel {
  final String symbol;
  final String name;
  @JsonKey(name: 'current_price')
  final double currentPrice;
  @JsonKey(name: 'change_percent')
  final double changePercent;
  final double change;
  final double volume;
  final String? sector;
  @JsonKey(name: 'market_cap')
  final double? marketCap;
  @JsonKey(name: 'last_updated')
  final String? lastUpdated;

  StockModel({
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

  factory StockModel.fromJson(Map<String, dynamic> json) =>
      _$StockModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockModelToJson(this);

  StockEntity toEntity() {
    return StockEntity(
      symbol: symbol,
      name: name,
      currentPrice: currentPrice,
      changePercent: changePercent,
      change: change,
      volume: volume,
      sector: sector,
      marketCap: marketCap,
      lastUpdated: lastUpdated != null ? DateTime.parse(lastUpdated!) : null,
    );
  }

  factory StockModel.fromEntity(StockEntity entity) {
    return StockModel(
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

@JsonSerializable()
class DashboardModel {
  @JsonKey(name: 'total_stocks')
  final int totalStocks;
  @JsonKey(name: 'watchlist_count')
  final int watchlistCount;
  @JsonKey(name: 'top_gainer')
  final StockModel? topGainer;
  @JsonKey(name: 'top_loser')
  final StockModel? topLoser;
  @JsonKey(name: 'market_summary')
  final MarketSummaryModel marketSummary;
  @JsonKey(name: 'market_overview')
  final List<StockModel> marketOverview;
  @JsonKey(name: 'recent_activity')
  final List<ActivityModel> recentActivity;

  DashboardModel({
    required this.totalStocks,
    required this.watchlistCount,
    this.topGainer,
    this.topLoser,
    required this.marketSummary,
    required this.marketOverview,
    required this.recentActivity,
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
      marketSummary: marketSummary.toEntity(),
      marketOverview: marketOverview.map((s) => s.toEntity()).toList(),
      recentActivity: recentActivity.map((a) => a.toEntity()).toList(),
    );
  }
}

@JsonSerializable()
class MarketSummaryModel {
  @JsonKey(name: 'dse_index')
  final double dseIndex;
  @JsonKey(name: 'market_cap')
  final double marketCap;
  @JsonKey(name: 'total_volume')
  final double totalVolume;
  final int gainers;
  final int losers;

  MarketSummaryModel({
    required this.dseIndex,
    required this.marketCap,
    required this.totalVolume,
    required this.gainers,
    required this.losers,
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
      timestamp: DateTime.parse(timestamp),
      stockSymbol: stockSymbol,
    );
  }
}

@JsonSerializable()
class AnalysisModel {
  final StockModel stock;
  final String recommendation;
  final int score;
  final ValuationModel valuation;
  final PredictionModel prediction;
  @JsonKey(name: 'financial_metrics')
  final Map<String, dynamic> financialMetrics;
  @JsonKey(name: 'positive_signals')
  final List<SignalModel> positiveSignals;
  @JsonKey(name: 'warning_signals')
  final List<SignalModel> warningSignals;

  AnalysisModel({
    required this.stock,
    required this.recommendation,
    required this.score,
    required this.valuation,
    required this.prediction,
    required this.financialMetrics,
    required this.positiveSignals,
    required this.warningSignals,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$AnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisModelToJson(this);

  AnalysisEntity toEntity() {
    return AnalysisEntity(
      stock: stock.toEntity(),
      recommendation: recommendation,
      score: score,
      valuation: valuation.toEntity(),
      prediction: prediction.toEntity(),
      financialMetrics: financialMetrics,
      positiveSignals: positiveSignals.map((s) => s.toEntity()).toList(),
      warningSignals: warningSignals.map((s) => s.toEntity()).toList(),
    );
  }
}

@JsonSerializable()
class ValuationModel {
  final String status;
  @JsonKey(name: 'market_price')
  final double marketPrice;
  @JsonKey(name: 'book_value')
  final double bookValue;
  @JsonKey(name: 'graham_number')
  final double grahamNumber;
  @JsonKey(name: 'intrinsic_value')
  final double intrinsicValue;
  @JsonKey(name: 'margin_of_safety')
  final double marginOfSafety;

  ValuationModel({
    required this.status,
    required this.marketPrice,
    required this.bookValue,
    required this.grahamNumber,
    required this.intrinsicValue,
    required this.marginOfSafety,
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

@JsonSerializable()
class PredictionModel {
  @JsonKey(name: 'expected_price')
  final double expectedPrice;
  @JsonKey(name: 'conservative_price')
  final double conservativePrice;
  @JsonKey(name: 'optimistic_price')
  final double optimisticPrice;
  @JsonKey(name: 'expected_change')
  final double expectedChange;
  final String confidence;

  PredictionModel({
    required this.expectedPrice,
    required this.conservativePrice,
    required this.optimisticPrice,
    required this.expectedChange,
    required this.confidence,
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

@JsonSerializable()
class CompareResponse {
  final Map<String, dynamic> data;

  CompareResponse({required this.data});

  factory CompareResponse.fromJson(Map<String, dynamic> json) =>
      _$CompareResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CompareResponseToJson(this);
}
