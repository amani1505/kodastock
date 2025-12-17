import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/config/dio_client.dart';
import '../../../core/config/constants/app_constants.dart';
import '../../providers/app_providers.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> with SingleTickerProviderStateMixin {
  String? stock1;
  String? stock2;
  String? stock3;
  int period = 30; // Default to 30 days
  late TabController _tabController;
  bool _showResults = false;
  bool _isComparing = false;
  dynamic _comparisonData;

  final Map<String, int> periods = {
    '1 Week': 7,
    '1 Month': 30,
    '3 Months': 90,
    '6 Months': 180,
    '1 Year': 365,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compare Stocks'),
            Text(
              'Comprehensive technical and fundamental analysis side by side',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Header section (selection and compare button)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectionSection(context),
                  const SizedBox(height: 24),
                  _buildCompareButton(context),
                ],
              ),
            ),
          ),
          // Results section
          if (_showResults && stock1 != null && stock2 != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildComparisonResults(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionSection(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Stocks to Compare',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildStockDropdown(
              context,
              'Stock 1',
              stock1,
              (value) {
                setState(() => stock1 = value);
              },
              excludeStocks: [stock2, stock3],
            ),
            const SizedBox(height: 16),
            _buildStockDropdown(
              context,
              'Stock 2',
              stock2,
              (value) {
                setState(() => stock2 = value);
              },
              excludeStocks: [stock1, stock3],
            ),
            const SizedBox(height: 16),
            _buildStockDropdown(
              context,
              'Stock 3 (Optional)',
              stock3,
              (value) {
                setState(() => stock3 = value);
              },
              excludeStocks: [stock1, stock2],
            ),
            const SizedBox(height: 16),
            _buildPeriodDropdown(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStockDropdown(
    BuildContext context,
    String label,
    String? value,
    Function(String?) onChanged, {
    List<String?>? excludeStocks,
  }) {
    final stocksAsync = ref.watch(stocksListProvider(null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        stocksAsync.when(
          data: (stocks) {
            // Filter out already selected stocks from other dropdowns
            final filteredStocks = stocks.where((stock) {
              return excludeStocks == null || !excludeStocks.contains(stock.symbol);
            }).toList();

            // Ensure the current value is valid for this dropdown
            final validValue = (value != null && filteredStocks.any((s) => s.symbol == value)) ? value : null;

            return DropdownButtonFormField<String>(
              key: ValueKey('$label-${excludeStocks?.join(',') ?? ''}'),
              initialValue: validValue,
              decoration: InputDecoration(
                hintText: 'Select a stock',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: filteredStocks.map((stock) {
                return DropdownMenuItem(
                  value: stock.symbol,
                  child: Text('${stock.symbol} - ${stock.name}'),
                );
              }).toList(),
              onChanged: onChanged,
            );
          },
          loading: () => DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Loading stocks...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [],
            onChanged: null,
          ),
          error: (error, _) => DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Error loading stocks',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [],
            onChanged: null,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: period,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: periods.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.value,
              child: Text(entry.key),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => period = value!);
          },
        ),
      ],
    );
  }

  Widget _buildCompareButton(BuildContext context) {
    final isEnabled = stock1 != null && stock2 != null && !_isComparing;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleCompareStocks : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isComparing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.compare_arrows),
                  const SizedBox(width: 8),
                  const Text('Compare Stocks'),
                ],
              ),
      ),
    );
  }

  Future<void> _handleCompareStocks() async {
    setState(() {
      _isComparing = true;
      _showResults = false;
    });

    try {
      final dio = ref.read(dioProvider);
      final symbols = [stock1!, stock2!, if (stock3 != null) stock3!];

      final response = await dio.post(
        ApiEndpoints.compare,
        data: {
          'symbols': symbols,
          'period': period,
        },
      );

      if (mounted) {
        setState(() {
          _comparisonData = response.data['data'];
          _showResults = true;
          _isComparing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isComparing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to compare stocks: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildComparisonResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badges section
        _buildResultBadges(context),
        const SizedBox(height: 16),
        // Fixed tab bar
        _buildTabBar(context),
        const SizedBox(height: 16),
        // Tab content
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: _buildTabContent(context),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).primaryColor,
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Technical Analysis'),
        Tab(text: 'Fundamental Analysis'),
        Tab(text: 'Predictions'),
        Tab(text: 'Signals & Flags'),
      ],
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(context),
        _buildTechnicalAnalysisTab(context),
        _buildFundamentalAnalysisTab(context),
        _buildPredictionsTab(context),
        _buildSignalsFlagsTab(context),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _buildStockCards(context),
        const SizedBox(height: 24),
        _buildKeyMetricsTable(context),
        const SizedBox(height: 20),
        _buildMarketCautionCard(context),
        const SizedBox(height: 20),
        _buildDetailedAnalysisSection(context),
      ],
    );
  }

  Widget _buildTechnicalAnalysisTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _buildPriceMovementChart(context),
        const SizedBox(height: 24),
        _buildTechnicalMetricsTable(context),
        const SizedBox(height: 20),
        _buildMarketCautionCard(context),
      ],
    );
  }

  Widget _buildFundamentalAnalysisTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _buildFundamentalMetricsTable(context),
        const SizedBox(height: 20),
        _buildMarketCautionCard(context),
      ],
    );
  }

  Widget _buildPredictionsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _buildPredictionCards(context),
        const SizedBox(height: 20),
        _buildMarketCautionCard(context),
        const SizedBox(height: 20),
        _buildDetailedAnalysisSection(context),
      ],
    );
  }

  Widget _buildSignalsFlagsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _buildSignalsForStock(context, 'CRDB', 'CRDB'),
        const SizedBox(height: 24),
        _buildSignalsForStock(context, 'DSE', 'DSE'),
        const SizedBox(height: 24),
        if (stock3 != null) _buildSignalsForStock(context, stock3!, stock3!),
      ],
    );
  }

  Widget _buildResultBadges(BuildContext context) {
    if (_comparisonData == null) return const SizedBox.shrink();

    final bestPicks = _comparisonData['best_picks'];
    if (bestPicks == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (bestPicks['best_overall'] != null)
          _buildBadge(
            context,
            'BEST OVERALL',
            bestPicks['best_overall']['symbol'] ?? '',
            Colors.amber,
            Icons.emoji_events,
          ),
        if (bestPicks['best_value'] != null)
          _buildBadge(
            context,
            'BEST VALUE',
            bestPicks['best_value']['symbol'] ?? '',
            Colors.blue,
            Icons.diamond,
          ),
        if (bestPicks['best_growth'] != null)
          _buildBadge(
            context,
            'BEST GROWTH',
            bestPicks['best_growth']['symbol'] ?? '',
            Colors.purple,
            Icons.rocket_launch,
          ),
        if (bestPicks['safest_pick'] != null)
          _buildBadge(
            context,
            'SAFEST PICK',
            bestPicks['safest_pick']['symbol'] ?? '',
            Colors.green,
            Icons.shield,
          ),
      ],
    );
  }

  Widget _buildStockCards(BuildContext context) {
    if (_comparisonData == null) return const SizedBox.shrink();

    final stocksList = _comparisonData['stocks'] as List<dynamic>?;
    if (stocksList == null || stocksList.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use column layout for small screens, row for larger screens
        if (constraints.maxWidth < 600) {
          return Column(
            children: stocksList.map<Widget>((stockData) {
              return _buildStockCard(context, stockData);
            }).toList(),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: stocksList.map<Widget>((stockData) {
              return SizedBox(
                width: constraints.maxWidth / stocksList.length - 16,
                child: _buildStockCard(context, stockData),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStockCard(BuildContext context, dynamic stockData) {
    final stock = stockData['stock'];
    final symbol = stock['symbol'] ?? '';
    final name = stock['name'] ?? '';
    final recommendation = stockData['recommendation'];
    final action = recommendation['action'] ?? 'N/A';
    final score = recommendation['score'] ?? 0;
    final breakdown = recommendation['breakdown'];
    final technicalScore = breakdown?['technical_score'] ?? 0;
    final fundamentalScore = breakdown?['fundamental_score'] ?? 0;
    final summary = recommendation['summary'] ?? 'No data available';

    // Determine status color based on action
    Color statusColor;
    switch (action.toLowerCase()) {
      case 'buy':
      case 'strong buy':
        statusColor = Colors.green;
        break;
      case 'hold':
      case 'caution':
        statusColor = Colors.orange;
        break;
      case 'sell':
      case 'avoid':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        name,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.bookmark_border, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                action,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildScoreRow(context, 'Overall Score', score, 100),
            const SizedBox(height: 8),
            _buildScoreRow(context, 'Technical', technicalScore, 50),
            const SizedBox(height: 8),
            _buildScoreRow(context, 'Fundamental', fundamentalScore, 50),
            const SizedBox(height: 16),
            Text(
              summary,
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(BuildContext context, String label, int score, int maxScore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textTheme.bodySmall),
        Text(
          '$score/$maxScore',
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsTable(BuildContext context) {
    if (_comparisonData == null) return const SizedBox.shrink();

    final stocksList = _comparisonData['stocks'] as List<dynamic>?;
    if (stocksList == null || stocksList.isEmpty) return const SizedBox.shrink();

    // Extract values for each stock
    final values = stocksList.map((stockData) {
      final technical = stockData['technical'];
      final fundamental = stockData['fundamental'];

      final currentPrice = technical?['current_price']?.toString() ?? 'N/A';
      final periodChange = technical?['period_change'];
      final changePercent = periodChange?['percent']?.toString() ?? '0';
      final healthScore = fundamental?['health_score']?.toString() ?? 'N/A';
      final healthRating = fundamental?['health_rating'] ?? 'Unknown';

      final changeValue = double.tryParse(changePercent) ?? 0;
      final changeColor = changeValue >= 0 ? Colors.green : Colors.red;

      return {
        'price': '$currentPrice TZS',
        'change': '$changePercent%',
        'changeColor': changeColor,
        'health': healthScore != 'N/A' ? '$healthScore%\n$healthRating' : 'N/A',
      };
    }).toList();

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KEY METRICS',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _buildMetricTableRow(
              context,
              'Current Price',
              values[0]['price'] as String,
              values.length > 1 ? values[1]['price'] as String : '',
              values.length > 2 ? values[2]['price'] as String : '',
            ),
            const Divider(),
            _buildMetricTableRow(
              context,
              '$period-Day Change',
              values[0]['change'] as String,
              values.length > 1 ? values[1]['change'] as String : '',
              values.length > 2 ? values[2]['change'] as String : '',
              valueColors: [
                values[0]['changeColor'] as Color,
                if (values.length > 1) values[1]['changeColor'] as Color else null,
                if (values.length > 2) values[2]['changeColor'] as Color else null,
              ],
            ),
            const Divider(),
            _buildMetricTableRow(
              context,
              'Financial Health',
              values[0]['health'] as String,
              values.length > 1 ? values[1]['health'] as String : '',
              values.length > 2 ? values[2]['health'] as String : '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTableRow(BuildContext context, String label, String value1, String value2, String value3, {List<Color?>? valueColors}) {
    valueColors ??= [null, null, null];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value1,
              style: context.textTheme.bodyMedium?.copyWith(
                color: valueColors[0],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              value2,
              style: context.textTheme.bodyMedium?.copyWith(
                color: valueColors[1],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              value3,
              style: context.textTheme.bodyMedium?.copyWith(
                color: valueColors[2],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysisSection(BuildContext context) {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Detailed Analysis',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAnalysisItem(
              context,
              icon: Icons.shield,
              iconColor: Colors.green,
              title: 'Risk Analysis',
              description: 'CRDB is safest with 0.8% volatility',
            ),
            const SizedBox(height: 16),
            _buildAnalysisItem(
              context,
              icon: Icons.monetization_on,
              iconColor: Colors.amber,
              title: 'Profitability Leader',
              description: 'CRDB leads profitability with 27.89% ROE',
            ),
            const SizedBox(height: 16),
            _buildAnalysisItem(
              context,
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange,
              title: 'Avoid',
              description: 'AFRIPRISE shows weakness: -5.3% price decline',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(BuildContext context, {required IconData icon, required Color iconColor, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
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
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceMovementChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Movement Comparison',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Price Movement Chart',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Integrate fl_chart or similar library for line chart',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalMetricsTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TECHNICAL METRICS',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _buildTechnicalMetricRow(context, 'Volatility', '0.81%\nLow', '3.65%\nMedium', '4.14%\nMedium'),
            const Divider(),
            _buildTechnicalMetricRow(context, '52-Week Range', '630 - 1,640\nCurrent: 52%', '2,180 - 6,700\nCurrent: 82%', '200 - 585\nCurrent: 64%'),
            const Divider(),
            _buildTechnicalMetricRow(context, '1-Week Pattern', '-0.66%\nSuccess: 30%', '-0.69%\nSuccess: 41.38%', '-1.86%\nSuccess: 31.03%'),
            const Divider(),
            _buildTechnicalMetricRow(context, 'Avg Daily Volume', '577.02K', '7.74K', '195.66K'),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalMetricRow(BuildContext context, String label, String value1, String value2, String value3) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value1,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              value2,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              value3,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundamentalMetricsTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FUNDAMENTAL METRICS',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _buildMetricTableRow(context, 'P/E Ratio', '5.5', 'N/A', 'N/A'),
            const Divider(),
            _buildMetricTableRow(context, 'ROE', '27.89%', 'N/A', 'N/A'),
            const Divider(),
            _buildMetricTableRow(context, 'Debt-to-Equity', '6.68', 'N/A', 'N/A'),
            const Divider(),
            _buildMetricTableRow(context, 'Profit Margin', '27%', 'N/A', 'N/A'),
            const Divider(),
            _buildMetricTableRow(context, 'Dividend Yield', '5.6%', 'N/A', 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use column layout for small screens
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildPredictionCard(
                context,
                'CRDB',
                currentPrice: '1,160',
                target: '1,176.51',
                expectedChange: '+1.4%',
                conservative: '1,058.86',
                optimistic: '1,294.16',
                confidence: 'high',
              ),
              const SizedBox(height: 16),
              _buildPredictionCard(
                context,
                'DSE',
                currentPrice: null,
                target: null,
                expectedChange: null,
                conservative: null,
                optimistic: null,
                confidence: null,
              ),
              const SizedBox(height: 16),
              _buildPredictionCard(
                context,
                'AFRIPRISE',
                currentPrice: null,
                target: null,
                expectedChange: null,
                conservative: null,
                optimistic: null,
                confidence: null,
              ),
            ],
          );
        }

        // Use row layout for larger screens
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPredictionCard(
                context,
                'CRDB',
                currentPrice: '1,160',
                target: '1,176.51',
                expectedChange: '+1.4%',
                conservative: '1,058.86',
                optimistic: '1,294.16',
                confidence: 'high',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPredictionCard(
                context,
                'DSE',
                currentPrice: null,
                target: null,
                expectedChange: null,
                conservative: null,
                optimistic: null,
                confidence: null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPredictionCard(
                context,
                'AFRIPRISE',
                currentPrice: null,
                target: null,
                expectedChange: null,
                conservative: null,
                optimistic: null,
                confidence: null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPredictionCard(
    BuildContext context,
    String stock, {
    String? currentPrice,
    String? target,
    String? expectedChange,
    String? conservative,
    String? optimistic,
    String? confidence,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (currentPrice != null) ...[
              Text(
                'Current Price',
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                currentPrice,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '3-Month Target',
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                target!,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Expected Change',
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                expectedChange!,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Conservative', style: context.textTheme.bodySmall),
                  Text(conservative!, style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Optimistic', style: context.textTheme.bodySmall),
                  Text(optimistic!, style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Confidence', style: context.textTheme.bodySmall),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      confidence!,
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No prediction data available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignalsForStock(BuildContext context, String stockName, String stockCode) {
    final signals = _getSignalsData(stockCode);
    final positiveSignals = signals['positive'] ?? [];
    final warningSignals = signals['warning'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$stockName - $stockCode',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (positiveSignals.isEmpty && warningSignals.isEmpty) ...[
              Text(
                'No signal data available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ] else ...[
              if (positiveSignals.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Positive Signals (${positiveSignals.length})',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...positiveSignals.map((signal) => _buildSignalCard(context, signal, Colors.green)),
                const SizedBox(height: 20),
              ],
              if (warningSignals.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Warning Signals (${warningSignals.length})',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...warningSignals.map((signal) => _buildSignalCard(context, signal, Colors.red)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Map<String, List<Map<String, String>>> _getSignalsData(String stockCode) {
    final data = <String, Map<String, List<Map<String, String>>>>{
      'CRDB': {
        'positive': <Map<String, String>>[
          {'title': 'Strong Margin of Safety', 'description': 'Stock has 41.6% margin of safety, providing downside protection.'},
          {'title': 'Low P/E Ratio', 'description': 'P/E of 5.5 suggests the stock may be undervalued relative to earnings.'},
          {'title': 'High Return on Equity', 'description': 'ROE of 27.89% indicates excellent profitability.'},
          {'title': 'High Profit Margin', 'description': 'Net profit margin of 27% indicates strong pricing power.'},
          {'title': 'Attractive Dividend Yield', 'description': 'Dividend yield of 5.6% provides income while you hold.'},
        ],
        'warning': <Map<String, String>>[
          {'title': 'High Debt Level', 'description': 'Debt-to-equity of 6.68 indicates high financial risk.'},
          {'title': 'Liquidity Concerns', 'description': 'Current ratio below 1 indicates potential short-term payment issues.'},
        ],
      },
      'DSE': {
        'positive': <Map<String, String>>[],
        'warning': <Map<String, String>>[],
      },
      'AFRIPRISE': {
        'positive': <Map<String, String>>[],
        'warning': <Map<String, String>>[],
      },
    };

    return data[stockCode] ?? {'positive': <Map<String, String>>[], 'warning': <Map<String, String>>[]};
  }

  Widget _buildSignalCard(BuildContext context, Map<String, String> signal, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            signal['title']!,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            signal['description']!,
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, String stock, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stock,
            style: context.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketCautionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MARKET CAUTION',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: Colors.amber[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All stocks show weak signals. CRDB is least risky at 36/100 score. Consider waiting for better opportunities.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
