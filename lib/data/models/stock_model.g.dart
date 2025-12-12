// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StocksListResponse _$StocksListResponseFromJson(Map<String, dynamic> json) =>
    StocksListResponse(
      data: StocksDataWrapper.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StocksListResponseToJson(StocksListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

StocksDataWrapper _$StocksDataWrapperFromJson(Map<String, dynamic> json) =>
    StocksDataWrapper(
      stocks: (json['stocks'] as List<dynamic>)
          .map((e) => StockModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StocksDataWrapperToJson(StocksDataWrapper instance) =>
    <String, dynamic>{
      'stocks': instance.stocks,
    };

StockModel _$StockModelFromJson(Map<String, dynamic> json) => StockModel(
      id: StockModel._idFromJson(json['id']),
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: StockModel._priceFromJson(json['current_price']),
      changePercent: json['change_percentage'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['change_percentage']),
      change: json['change'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['change']),
      volume: json['volume'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['volume']),
      sector: json['sector'] as String?,
      marketCap: StockModel._nullableDoubleFromJson(json['market_cap']),
      lastUpdated: json['last_update'] as String?,
    );

Map<String, dynamic> _$StockModelToJson(StockModel instance) =>
    <String, dynamic>{
      'id': StockModel._idToJson(instance.id),
      'symbol': instance.symbol,
      'name': instance.name,
      'current_price': StockModel._priceToJson(instance.currentPrice),
      'change_percentage': instance.changePercent,
      'change': instance.change,
      'volume': instance.volume,
      'sector': instance.sector,
      'market_cap': instance.marketCap,
      'last_update': instance.lastUpdated,
    };

DashboardResponse _$DashboardResponseFromJson(Map<String, dynamic> json) =>
    DashboardResponse(
      data: json['data'] == null
          ? null
          : DashboardModel.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$DashboardResponseToJson(DashboardResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'success': instance.success,
      'message': instance.message,
    };

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    DashboardModel(
      totalStocks: (json['total_stocks'] as num?)?.toInt() ?? 0,
      watchlistCount: (json['watchlist_count'] as num?)?.toInt() ?? 0,
      topGainer: json['top_gainer'] == null
          ? null
          : StockModel.fromJson(json['top_gainer'] as Map<String, dynamic>),
      topLoser: json['top_loser'] == null
          ? null
          : StockModel.fromJson(json['top_loser'] as Map<String, dynamic>),
      marketSummary: json['market_summary'] == null
          ? null
          : MarketSummaryModel.fromJson(
              json['market_summary'] as Map<String, dynamic>),
      marketOverview: (json['market_overview'] as List<dynamic>?)
              ?.map((e) => StockModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentActivity: (json['recent_activity'] as List<dynamic>?)
              ?.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      dseIndex: json['dse_index'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['dse_index']),
      marketCap: json['market_cap'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['market_cap']),
      totalVolume: json['total_volume'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['total_volume']),
      gainers: (json['gainers'] as num?)?.toInt() ?? 0,
      losers: (json['losers'] as num?)?.toInt() ?? 0,
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

AnalysisResponse _$AnalysisResponseFromJson(Map<String, dynamic> json) =>
    AnalysisResponse(
      data: json['data'] == null
          ? null
          : AnalysisModel.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AnalysisResponseToJson(AnalysisResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'success': instance.success,
      'message': instance.message,
    };

AnalysisModel _$AnalysisModelFromJson(Map<String, dynamic> json) =>
    AnalysisModel(
      stock: StockModel.fromJson(json['stock'] as Map<String, dynamic>),
      recommendation: json['recommendation'] as String,
      score: (json['score'] as num?)?.toInt() ?? 0,
      valuation: json['valuation'] == null
          ? null
          : ValuationModel.fromJson(json['valuation'] as Map<String, dynamic>),
      prediction: json['prediction'] == null
          ? null
          : PredictionModel.fromJson(
              json['prediction'] as Map<String, dynamic>),
      financialMetrics:
          json['financial_metrics'] as Map<String, dynamic>? ?? {},
      positiveSignals: (json['positive_signals'] as List<dynamic>?)
              ?.map((e) => SignalModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      warningSignals: (json['warning_signals'] as List<dynamic>?)
              ?.map((e) => SignalModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      marketPrice: json['market_price'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['market_price']),
      bookValue: json['book_value'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['book_value']),
      grahamNumber: json['graham_number'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['graham_number']),
      intrinsicValue: json['intrinsic_value'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['intrinsic_value']),
      marginOfSafety: json['margin_of_safety'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['margin_of_safety']),
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
      expectedPrice: json['expected_price'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['expected_price']),
      conservativePrice: json['conservative_price'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['conservative_price']),
      optimisticPrice: json['optimistic_price'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['optimistic_price']),
      expectedChange: json['expected_change'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['expected_change']),
      confidence: json['confidence'] as String? ?? 'Low',
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
      data: json['data'] == null
          ? null
          : CompareDataModel.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$CompareResponseToJson(CompareResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'success': instance.success,
      'message': instance.message,
    };

CompareDataModel _$CompareDataModelFromJson(Map<String, dynamic> json) =>
    CompareDataModel(
      stocks: (json['stocks'] as List<dynamic>?)
              ?.map((e) => StockModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      comparison: json['comparison'] as Map<String, dynamic>?,
      period: json['period'] as String?,
    );

Map<String, dynamic> _$CompareDataModelToJson(CompareDataModel instance) =>
    <String, dynamic>{
      'stocks': instance.stocks,
      'comparison': instance.comparison,
      'period': instance.period,
    };

StockDetailsResponse _$StockDetailsResponseFromJson(
        Map<String, dynamic> json) =>
    StockDetailsResponse(
      data: json['data'] == null
          ? null
          : StockDetailsModel.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$StockDetailsResponseToJson(
        StockDetailsResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'success': instance.success,
      'message': instance.message,
    };

StockDetailsModel _$StockDetailsModelFromJson(Map<String, dynamic> json) =>
    StockDetailsModel(
      stock: StockModel.fromJson(json['stock'] as Map<String, dynamic>),
      priceHistory: (json['price_history'] as List<dynamic>?)
              ?.map(
                  (e) => PriceHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      financialData: json['financial_data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$StockDetailsModelToJson(StockDetailsModel instance) =>
    <String, dynamic>{
      'stock': instance.stock,
      'price_history': instance.priceHistory,
      'financial_data': instance.financialData,
    };

PriceHistoryModel _$PriceHistoryModelFromJson(Map<String, dynamic> json) =>
    PriceHistoryModel(
      date: json['date'] as String,
      open:
          json['open'] == null ? 0.0 : StockModel._doubleFromJson(json['open']),
      high:
          json['high'] == null ? 0.0 : StockModel._doubleFromJson(json['high']),
      low: json['low'] == null ? 0.0 : StockModel._doubleFromJson(json['low']),
      close: json['close'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['close']),
      volume: json['volume'] == null
          ? 0.0
          : StockModel._doubleFromJson(json['volume']),
    );

Map<String, dynamic> _$PriceHistoryModelToJson(PriceHistoryModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': instance.volume,
    };

MarketSummaryResponse _$MarketSummaryResponseFromJson(
        Map<String, dynamic> json) =>
    MarketSummaryResponse(
      data: json['data'] == null
          ? null
          : MarketSummaryModel.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MarketSummaryResponseToJson(
        MarketSummaryResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'success': instance.success,
      'message': instance.message,
    };
