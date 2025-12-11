import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/config/constants/app_constants.dart';
import '../../models/stock_model.dart';

part 'stock_api_service.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class StockApiService {
  factory StockApiService(Dio dio, {String baseUrl}) = _StockApiService;

  @GET(ApiEndpoints.dashboard)
  Future<DashboardModel> getDashboard();

  @GET(ApiEndpoints.stocksList)
  Future<List<StockModel>> getStocksList({
    @Query('sector') String? sector,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/stocks/{symbol}')
  Future<StockModel> getStockDetails(@Path('symbol') String symbol);

  @POST(ApiEndpoints.compare)
  Future<CompareResponse> compareStocks(
    @Body() Map<String, dynamic> body,
  );

  @GET('/analysis/{symbol}')
  Future<AnalysisModel> getStockAnalysis(
    @Path('symbol') String symbol,
    @Query('period') String? period,
  );

  @GET(ApiEndpoints.marketSummary)
  Future<MarketSummaryModel> getMarketSummary();
}

// Dio instance provider
class DioClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Add error handling interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle errors globally
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
