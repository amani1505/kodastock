// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockModel _$StockModelFromJson(Map<String, dynamic> json) => StockModel(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      changePercent: (json['change_percent'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      sector: json['sector'] as String?,
      marketCap: (json['market_cap'] as num?)?.toDouble(),
      lastUpdated: json['last_updated'] as String?,
    );

Map<String, dynamic> _$StockModelToJson(StockModel instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'current_price': instance.currentPrice,
      'change_percent': instance.changePercent,
      'change': instance.change,
      'volume': instance.volume,
      'sector': instance.sector,
      'market_cap': instance.marketCap,
      'last_updated': instance.lastUpdated,
    };

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    DashboardModel(
      totalStocks: (json['total_stocks'] as num).toInt(),
      watchlistCount: (json['watchlist_count'] as num).toInt(),
      topGainer: json['top_gainer'] == null
          ? null
          : StockModel.fromJson(json['top_gainer'] as Map<String, dynamic>),
      topLoser: json['top_loser'] == null
          ? null
          : StockModel.fromJson(json['top_loser'] as Map<String, dynamic>),
      marketSummary: MarketSummaryModel.fromJson(
          json['market_summary'] as Map<String, dynamic>),
      marketOverview: (json['market_overview'] as List<dynamic>)
          .map((e) => StockModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivity: (json['recent_activity'] as List<dynamic>)
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardModelToJson(DashboardModel instance) =>
    <String, dynamic>{
      'total_stocks': instance.totalStocks,
      'watchlist_count': instance.watchlistCount,
      'top_gainer': instance.topGainer,
      'top_loser': instance.topLoser,
      'market_summary': instance.marketSummary,
      'market_overview': instance.marketOverview,
      'recent_activity': instance.recentActivity,
    };

MarketSummaryModel _$MarketSummaryModelFromJson(Map<String, dynamic> json) =>
    MarketSummaryModel(
      dseIndex: (json['dse_index'] as num).toDouble(),
      marketCap: (json['market_cap'] as num).toDouble(),
      totalVolume: (json['total_volume'] as num).toDouble(),
      gainers: (json['gainers'] as num).toInt(),
      losers: (json['losers'] as num).toInt(),
    );

Map<String, dynamic> _$MarketSummaryModelToJson(MarketSummaryModel instance) =>
    <String, dynamic>{
      'dse_index': instance.dseIndex,
      'market_cap': instance.marketCap,
      'total_volume': instance.totalVolume,
      'gainers': instance.gainers,
      'losers': instance.losers,
    };

ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) =>
    ActivityModel(
      type: json['type'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      stockSymbol: json['stock_symbol'] as String?,
    );

Map<String, dynamic> _$ActivityModelToJson(ActivityModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'timestamp': instance.timestamp,
      'stock_symbol': instance.stockSymbol,
    };

AnalysisModel _$AnalysisModelFromJson(Map<String, dynamic> json) =>
    AnalysisModel(
      stock: StockModel.fromJson(json['stock'] as Map<String, dynamic>),
      recommendation: json['recommendation'] as String,
      score: (json['score'] as num).toInt(),
      valuation:
          ValuationModel.fromJson(json['valuation'] as Map<String, dynamic>),
      prediction:
          PredictionModel.fromJson(json['prediction'] as Map<String, dynamic>),
      financialMetrics: json['financial_metrics'] as Map<String, dynamic>,
      positiveSignals: (json['positive_signals'] as List<dynamic>)
          .map((e) => SignalModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      warningSignals: (json['warning_signals'] as List<dynamic>)
          .map((e) => SignalModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalysisModelToJson(AnalysisModel instance) =>
    <String, dynamic>{
      'stock': instance.stock,
      'recommendation': instance.recommendation,
      'score': instance.score,
      'valuation': instance.valuation,
      'prediction': instance.prediction,
      'financial_metrics': instance.financialMetrics,
      'positive_signals': instance.positiveSignals,
      'warning_signals': instance.warningSignals,
    };

ValuationModel _$ValuationModelFromJson(Map<String, dynamic> json) =>
    ValuationModel(
      status: json['status'] as String,
      marketPrice: (json['market_price'] as num).toDouble(),
      bookValue: (json['book_value'] as num).toDouble(),
      grahamNumber: (json['graham_number'] as num).toDouble(),
      intrinsicValue: (json['intrinsic_value'] as num).toDouble(),
      marginOfSafety: (json['margin_of_safety'] as num).toDouble(),
    );

Map<String, dynamic> _$ValuationModelToJson(ValuationModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'market_price': instance.marketPrice,
      'book_value': instance.bookValue,
      'graham_number': instance.grahamNumber,
      'intrinsic_value': instance.intrinsicValue,
      'margin_of_safety': instance.marginOfSafety,
    };

PredictionModel _$PredictionModelFromJson(Map<String, dynamic> json) =>
    PredictionModel(
      expectedPrice: (json['expected_price'] as num).toDouble(),
      conservativePrice: (json['conservative_price'] as num).toDouble(),
      optimisticPrice: (json['optimistic_price'] as num).toDouble(),
      expectedChange: (json['expected_change'] as num).toDouble(),
      confidence: json['confidence'] as String,
    );

Map<String, dynamic> _$PredictionModelToJson(PredictionModel instance) =>
    <String, dynamic>{
      'expected_price': instance.expectedPrice,
      'conservative_price': instance.conservativePrice,
      'optimistic_price': instance.optimisticPrice,
      'expected_change': instance.expectedChange,
      'confidence': instance.confidence,
    };

SignalModel _$SignalModelFromJson(Map<String, dynamic> json) => SignalModel(
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$SignalModelToJson(SignalModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
    };

CompareResponse _$CompareResponseFromJson(Map<String, dynamic> json) =>
    CompareResponse(
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CompareResponseToJson(CompareResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
