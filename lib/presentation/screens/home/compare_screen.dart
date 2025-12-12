import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/extensions.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> with SingleTickerProviderStateMixin {
  String? stock1;
  String? stock2;
  String? stock3;
  String period = '1 Month';
  late TabController _tabController;
  bool _showResults = false;

  final List<String> availableStocks = [
    'AFRIPRISE',
    'CRDB',
    'DCB',
    'DSE',
    'EABL',
    'JATU',
  ];

  final List<String> periods = [
    '1 Week',
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
  ];

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
      body: Column(
        children: [
          // Fixed header section (not scrollable)
          SingleChildScrollView(
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
          // Expandable results section with independent scrolling
          if (_showResults && stock1 != null && stock2 != null)
            Expanded(
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
    // Filter out already selected stocks from other dropdowns
    final filteredStocks = availableStocks.where((stock) {
      return excludeStocks == null || !excludeStocks.contains(stock);
    }).toList();

    // Ensure the current value is valid for this dropdown
    final validValue = (value != null && filteredStocks.contains(value)) ? value : null;

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
        DropdownButtonFormField<String>(
          key: ValueKey('$label-${excludeStocks?.join(',') ?? ''}'),
          value: validValue,
          decoration: InputDecoration(
            hintText: 'Select a stock',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: filteredStocks.map((stock) {
            return DropdownMenuItem(
              value: stock,
              child: Text('$stock - $stock'),
            );
          }).toList(),
          onChanged: onChanged,
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
        DropdownButtonFormField<String>(
          initialValue: period,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: periods.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Text(p),
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
    final isEnabled = stock1 != null && stock2 != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                setState(() {
                  _showResults = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comparing stocks...')),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
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

  Widget _buildComparisonResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scrollable header with badges
        SingleChildScrollView(
          child: Column(
            children: [
              _buildResultBadges(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
        // Fixed tab bar
        _buildTabBar(context),
        const SizedBox(height: 20),
        // Expanded scrollable tab content
        Expanded(
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildBadge(context, 'BEST OVERALL', 'CRDB', Colors.amber, Icons.emoji_events),
        _buildBadge(context, 'BEST VALUE', 'CRDB', Colors.blue, Icons.diamond),
        _buildBadge(context, 'BEST GROWTH', 'CRDB', Colors.purple, Icons.rocket_launch),
        _buildBadge(context, 'SAFEST PICK', 'CRDB', Colors.green, Icons.shield),
      ],
    );
  }

  Widget _buildStockCards(BuildContext context) {
    final stocks = [
      if (stock1 != null) stock1!,
      if (stock2 != null) stock2!,
      if (stock3 != null) stock3!,
    ];

    final stockData = {
      'CRDB': {'overall': 36, 'technical': 0, 'fundamental': 36, 'status': 'Caution', 'statusColor': Colors.orange, 'note': 'Significant concerns identified. 2 negative indicators suggest caution.'},
      'DSE': {'overall': 0, 'technical': 0, 'fundamental': 0, 'status': 'Avoid', 'statusColor': Colors.red, 'note': 'High risk with 1 concerning factors. Better opportunities likely exist elsewhere.'},
      'AFRIPRISE': {'overall': 0, 'technical': 0, 'fundamental': 0, 'status': 'Avoid', 'statusColor': Colors.red, 'note': 'High risk with 2 concerning factors. Better opportunities likely exist elsewhere.'},
    };

    return Row(
      children: stocks.map((stock) {
        final data = stockData[stock] ?? {'overall': 0, 'technical': 0, 'fundamental': 0, 'status': 'N/A', 'statusColor': Colors.grey, 'note': 'No data available'};
        return Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            stock,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.bookmark_border, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (data['statusColor'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data['status'] as String,
                      style: TextStyle(
                        color: data['statusColor'] as Color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScoreRow(context, 'Overall Score', data['overall'] as int, 100),
                  const SizedBox(height: 8),
                  _buildScoreRow(context, 'Technical', data['technical'] as int, 50),
                  const SizedBox(height: 8),
                  _buildScoreRow(context, 'Fundamental', data['fundamental'] as int, 50),
                  const SizedBox(height: 16),
                  Text(
                    data['note'] as String,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
    return Card(
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
            _buildMetricTableRow(context, 'Current Price', '1,160 TZS', '5,870 TZS', '445 TZS'),
            const Divider(),
            _buildMetricTableRow(context, '30-Day Change', '-0.85%', '-9.69%', '-5.32%',
              valueColors: [Colors.red, Colors.red, Colors.red]),
            const Divider(),
            _buildMetricTableRow(context, 'Financial Health', '58%\nFair', 'N/A', 'N/A'),
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
