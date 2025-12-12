import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/config/constants/app_constants.dart';
import '../../models/stock_model.dart';

part 'stock_api_service.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class StockApiService {
  factory StockApiService(Dio dio, {String baseUrl}) = _StockApiService;

  @GET(ApiEndpoints.dashboard)
  Future<DashboardResponse> getDashboard();  // Changed to DashboardResponse

  @GET(ApiEndpoints.stocksList)
  Future<StocksListResponse> getStocksList({  // Changed to StocksListResponse
    @Query('sector') String? sector,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/stocks/{symbol}')
  Future<StockDetailsResponse> getStockDetails(@Path('symbol') String symbol);  // Changed

  @POST(ApiEndpoints.compare)
  Future<CompareResponse> compareStocks(
    @Body() Map<String, dynamic> body,
  );

  @GET('/analysis/{symbol}')
  Future<AnalysisResponse> getStockAnalysis(  // Changed to AnalysisResponse
    @Path('symbol') String symbol,
    @Query('period') String? period,
  );

  @GET(ApiEndpoints.marketSummary)
  Future<MarketSummaryResponse> getMarketSummary();  // Changed
}