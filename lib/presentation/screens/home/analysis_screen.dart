import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/config/dio_client.dart';
import '../../../core/config/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../../domain/entities/stock_entity.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  StockEntity? selectedStock;
  Map<String, dynamic>? selectedPeriod;
  List<Map<String, dynamic>> availablePeriods = [];
  bool _isLoadingPeriods = false;
  bool _isAnalyzing = false;
  dynamic _analysisData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock Investment Analysis'),
            Text(
              'Get actionable insights and predictions to make informed investment decisions',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelectionSection(context),
            const SizedBox(height: 24),
            _buildAnalyzeButton(context),
            const SizedBox(height: 32),
            if (_analysisData != null) ...[
              _buildAnalysisResults(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection(BuildContext context) {
    final stocksAsync = ref.watch(stocksListProvider(null));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Stock to Analyze',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            stocksAsync.when(
              data: (stocks) {
                return DropdownButtonFormField<StockEntity>(
                  initialValue: selectedStock,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    hintText: 'Choose a stock',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: stocks.map((stock) {
                    return DropdownMenuItem(
                      value: stock,
                      child: Text('${stock.symbol} - ${stock.name}'),
                    );
                  }).toList(),
                  onChanged: (stock) {
                    setState(() {
                      selectedStock = stock;
                      selectedPeriod = null;
                      availablePeriods = [];
                      _analysisData = null;
                    });
                    if (stock != null && stock.id != null) {
                      _fetchAvailablePeriods(stock.id!);
                    }
                  },
                );
              },
              loading: () => DropdownButtonFormField<StockEntity>(
                decoration: InputDecoration(
                  labelText: 'Stock',
                  hintText: 'Loading stocks...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [],
                onChanged: null,
              ),
              error: (error, _) => DropdownButtonFormField<StockEntity>(
                decoration: InputDecoration(
                  labelText: 'Stock',
                  hintText: 'Error loading stocks',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [],
                onChanged: null,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingPeriods)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (availablePeriods.isNotEmpty)
              DropdownButtonFormField<Map<String, dynamic>>(
                initialValue: selectedPeriod,
                decoration: InputDecoration(
                  labelText: 'Period',
                  hintText: 'Select a period',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: availablePeriods.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period['label'] ?? ''),
                  );
                }).toList(),
                onChanged: (period) {
                  setState(() => selectedPeriod = period);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAvailablePeriods(int stockId) async {
    setState(() {
      _isLoadingPeriods = true;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        ApiEndpoints.periods(stockId),
      );

      if (mounted) {
        final periods = (response.data['data']['periods'] as List<dynamic>)
            .map((p) => p as Map<String, dynamic>)
            .toList();

        setState(() {
          availablePeriods = periods;
          selectedPeriod = periods.isNotEmpty ? periods.first : null;
          _isLoadingPeriods = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPeriods = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load periods: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAnalyzeButton(BuildContext context) {
    final isEnabled = selectedStock != null && selectedPeriod != null && !_isAnalyzing;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleAnalyzeStock : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isAnalyzing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics),
                  const SizedBox(width: 8),
                  Text('Analyze'),
                ],
              ),
      ),
    );
  }

  Future<void> _handleAnalyzeStock() async {
    if (selectedStock == null || selectedPeriod == null || selectedStock!.id == null) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisData = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        ApiEndpoints.analysis(selectedStock!.id!),
        queryParameters: {
          'year': selectedPeriod!['year'],
          'period': selectedPeriod!['period'],
        },
      );

      if (mounted) {
        setState(() {
          _analysisData = response.data['data'];
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze stock: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAnalysisResults(BuildContext context) {
    if (_analysisData == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecommendationCard(context),
        const SizedBox(height: 20),
        _buildValuationCard(context),
        const SizedBox(height: 20),
        _buildPredictionCard(context),
        const SizedBox(height: 20),
        _buildFinancialMetrics(context),
        const SizedBox(height: 20),
        _buildAnalysisBreakdown(context),
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    final recommendation = _analysisData['analysis']['recommendation'];
    final action = recommendation['action'] ?? 'N/A';
    final score = recommendation['score'] ?? 0;
    final maxScore = recommendation['max_score'] ?? 100;
    final summary = recommendation['summary'] ?? '';

    // Determine color based on action
    Color gradientStart;
    Color gradientEnd;
    switch (action.toLowerCase()) {
      case 'strong buy':
        gradientStart = Colors.green[700]!;
        gradientEnd = Colors.green[400]!;
        break;
      case 'buy':
        gradientStart = Colors.green[600]!;
        gradientEnd = Colors.green[300]!;
        break;
      case 'hold':
        gradientStart = Colors.orange[600]!;
        gradientEnd = Colors.orange[300]!;
        break;
      case 'sell':
      case 'avoid':
        gradientStart = Colors.red[600]!;
        gradientEnd = Colors.red[300]!;
        break;
      default:
        gradientStart = Colors.grey[600]!;
        gradientEnd = Colors.grey[300]!;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVESTMENT RECOMMENDATION',
            style: context.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            action,
            style: context.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: context.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Score: $score/$maxScore',
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuationCard(BuildContext context) {
    final valuation = _analysisData['analysis']['valuation'];
    final marketPrice = valuation['market_price'] ?? 0;
    final bookValue = valuation['book_value_per_share'] ?? 0;
    final grahamNumber = valuation['graham_number'] ?? 0;
    final intrinsicValue = valuation['intrinsic_value'] ?? 0;
    final marginOfSafety = valuation['margin_of_safety'] ?? 0;
    final valuationStatus = valuation['valuation_status'] ?? 'Unknown';

    // Format valuation status
    String formatStatus(String status) {
      return status.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: context.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Stock Valuation',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valuation Status',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatStatus(valuationStatus),
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(context, 'Market Price', '$marketPrice TZS'),
            Divider(),
            _buildMetricRow(context, 'Book Value Per Share', '${bookValue.toStringAsFixed(2)} TZS'),
            Divider(),
            _buildMetricRow(context, 'Graham Number (Max. Safe Value)', '${grahamNumber.toStringAsFixed(2)} TZS'),
            Divider(),
            _buildMetricRow(context, 'Intrinsic Value (True Value)', '${intrinsicValue.toStringAsFixed(2)} TZS'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Margin of safety for value investing',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '$marginOfSafety%',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context) {
    final prediction = _analysisData['analysis']['prediction'];
    final predictedPrice = prediction['predicted_price'] ?? 0;
    final conservativePrice = prediction['conservative_price'] ?? 0;
    final optimisticPrice = prediction['optimistic_price'] ?? 0;
    final expectedChangePercent = prediction['expected_change_percent'] ?? 0;
    final expectedChange = prediction['expected_change'] ?? 0;
    final confidence = prediction['confidence'] ?? 'Unknown';
    final timeframe = prediction['timeframe'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: context.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  '$timeframe Price Prediction',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPredictionItem(context, 'Conservative', '${conservativePrice.toStringAsFixed(2)}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPredictionItem(context, 'Expected', '${predictedPrice.toStringAsFixed(2)}', isPrimary: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPredictionItem(context, 'Optimistic', '${optimisticPrice.toStringAsFixed(2)}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: expectedChangePercent >= 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Expected Change',
                    style: context.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${expectedChangePercent >= 0 ? '+' : ''}${expectedChangePercent.toStringAsFixed(1)}%',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: expectedChangePercent >= 0 ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '(${expectedChange >= 0 ? '+' : ''}${expectedChange.toStringAsFixed(2)} TZS)',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prediction Confidence',
                  style: context.textTheme.bodyMedium,
                ),
                Chip(
                  label: Text(confidence[0].toUpperCase() + confidence.substring(1)),
                  backgroundColor: Colors.green.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(BuildContext context, String label, String value, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary
            ? context.colorScheme.primary.withValues(alpha: 0.1)
            : context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? Border.all(color: context.colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPrimary ? context.colorScheme.primary : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetrics(BuildContext context) {
    final metrics = _analysisData['analysis']['metrics'];
    final perShare = metrics['per_share'];
    final valuation = metrics['valuation'];
    final profitability = metrics['profitability'];
    final financialHealth = metrics['financial_health'];
    final healthScore = _analysisData['analysis']['health_score'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: context.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Key Financial Metrics',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMetricChip(context, 'EPS', '${perShare['eps']?.toStringAsFixed(2) ?? 'N/A'}', Colors.blue),
                _buildMetricChip(context, 'P/B', '${valuation['pb_ratio']?.toStringAsFixed(2) ?? 'N/A'}', Colors.green),
                _buildMetricChip(context, 'PEG', valuation['peg_ratio']?.toString() ?? 'N/A', Colors.grey),
                _buildMetricChip(context, 'DY', '${valuation['dividend_yield']?.toStringAsFixed(2) ?? 'N/A'}%', Colors.teal),
                _buildMetricChip(context, 'ROE', '${profitability['roe']?.toStringAsFixed(2) ?? 'N/A'}%', Colors.orange),
                _buildMetricChip(context, 'ROA', '${profitability['roa']?.toStringAsFixed(2) ?? 'N/A'}%', Colors.amber),
                _buildMetricChip(context, 'NPM', '${profitability['net_profit_margin']?.toStringAsFixed(2) ?? 'N/A'}%', Colors.yellow),
                _buildMetricChip(context, 'GPM', '${profitability['gross_profit_margin']?.toStringAsFixed(2) ?? 'N/A'}%', Colors.lime),
                _buildMetricChip(context, 'D/E', '${financialHealth['debt_to_equity']?.toStringAsFixed(2) ?? 'N/A'}', Colors.pink),
                _buildMetricChip(context, 'CR', '${financialHealth['current_ratio']?.toStringAsFixed(2) ?? 'N/A'}', Colors.red),
                _buildMetricChip(context, 'ICR', '${financialHealth['interest_coverage']?.toStringAsFixed(2) ?? 'N/A'}', Colors.orange),
                _buildMetricChip(context, 'Score', '$healthScore', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisBreakdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis Breakdown',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSignalsSection(context),
      ],
    );
  }

  Widget _buildSignalsSection(BuildContext context) {
    final signals = _analysisData['analysis']['signals'];
    final greenFlags = signals['green_flags'] as List<dynamic>? ?? [];
    final redFlags = signals['red_flags'] as List<dynamic>? ?? [];

    return Column(
      children: [
        Card(
          color: Colors.green.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Text(
                      'Positive Signals (${greenFlags.length})',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...greenFlags.map((flag) => _buildSignalItem(
                  context,
                  flag['title'] ?? '',
                  flag['description'] ?? '',
                  true,
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.red.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Text(
                      'Warning Signals (${redFlags.length})',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...redFlags.map((flag) => _buildSignalItem(
                  context,
                  flag['title'] ?? '',
                  flag['description'] ?? '',
                  false,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignalItem(BuildContext context, String title, String description, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
