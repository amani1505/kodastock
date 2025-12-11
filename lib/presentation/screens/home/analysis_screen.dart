import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/extensions.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  String? selectedStock;
  String selectedPeriod = 'Q2';
  String fiscalYear = '2025';

  final List<String> availableStocks = [
    'CRDB',
    'AFRIPRISE',
    'DCB',
    'DSE',
    'EABL',
    'JATU',
  ];

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
            if (selectedStock != null) ...[
              _buildAnalysisResults(context),
            ],
          ],
        ),
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
              'Select Stock to Analyze',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedStock,
              decoration: InputDecoration(
                labelText: 'Stock',
                hintText: 'Choose a stock',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: availableStocks.map((stock) {
                return DropdownMenuItem(
                  value: stock,
                  child: Text('$stock - $stock'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedStock = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: fiscalYear,
                    decoration: InputDecoration(
                      labelText: 'Fiscal Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ['2023', '2024', '2025'].map((year) {
                      return DropdownMenuItem(value: year, child: Text(year));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => fiscalYear = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedPeriod,
                    decoration: InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ['Q1', 'Q2', 'Q3', 'Q4', 'Full Year'].map((period) {
                      return DropdownMenuItem(value: period, child: Text(period));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedPeriod = value!);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context) {
    final isEnabled = selectedStock != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Analyzing ${selectedStock}...')),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
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

  Widget _buildAnalysisResults(BuildContext context) {
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[400]!],
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
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Strong Buy',
            style: context.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This stock shows excellent fundamentals with strong value characteristics. With 4 positive indicators, it appears to be a compelling investment opportunity.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Score: 75/100',
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
                color: Colors.green.withOpacity(0.1),
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
                    'Significantly Undervalued',
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(context, 'Market Price', '1,160'),
            Divider(),
            _buildMetricRow(context, 'Book Value Per Share', '916.27'),
            Divider(),
            _buildMetricRow(context, 'Graham Number (Max. Safe Value)', '1,655.88'),
            Divider(),
            _buildMetricRow(context, 'Intrinsic Value (True Value)', '1,108.33'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Good margin of safety for value investing',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '29.9%',
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
                  '3-Month Price Prediction',
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
                  child: _buildPredictionItem(context, 'Conservative', '1,051.8'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPredictionItem(context, 'Expected', '1,168.67', isPrimary: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPredictionItem(context, 'Optimistic', '1,285.54'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
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
                    '+0.7%',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '(+8.67 TZS)',
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
                  label: Text('High'),
                  backgroundColor: Colors.green.withOpacity(0.2),
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
            ? context.colorScheme.primary.withOpacity(0.1)
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
                _buildMetricChip(context, 'EPS', '133.00', Colors.blue),
                _buildMetricChip(context, 'P/B', '1.27', Colors.green),
                _buildMetricChip(context, 'PEG', 'N/A', Colors.grey),
                _buildMetricChip(context, 'DY', '5.60%', Colors.teal),
                _buildMetricChip(context, 'ROE', '15.22%', Colors.orange),
                _buildMetricChip(context, 'ROA', '1.85%', Colors.amber),
                _buildMetricChip(context, 'NPM', '27.55%', Colors.yellow),
                _buildMetricChip(context, 'GPM', '51.09%', Colors.lime),
                _buildMetricChip(context, 'D/E', '7.26', Colors.pink),
                _buildMetricChip(context, 'CR', '0.40', Colors.red),
                _buildMetricChip(context, 'ICR', '1.91', Colors.orange),
                _buildMetricChip(context, 'Score', '53', Colors.purple),
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
        color: color.withOpacity(0.1),
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
    return Column(
      children: [
        Card(
          color: Colors.green.withOpacity(0.05),
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
                      'Positive Signals (4)',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSignalItem(
                  context,
                  'Strong Margin of Safety',
                  'Stock has 29.9% margin of safety, providing downside protection.',
                  true,
                ),
                _buildSignalItem(
                  context,
                  'Low P/E Ratio',
                  'P/E of 8.72 suggests the stock may be undervalued relative to earnings.',
                  true,
                ),
                _buildSignalItem(
                  context,
                  'High Profit Margin',
                  'Net profit margin of 27.55% indicates strong pricing power.',
                  true,
                ),
                _buildSignalItem(
                  context,
                  'Attractive Dividend Yield',
                  'Dividend yield of 5.6% provides income while you hold.',
                  true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.red.withOpacity(0.05),
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
                      'Warning Signals (2)',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSignalItem(
                  context,
                  'High Debt Level',
                  'Debt-to-equity of 7.26 indicates high financial risk.',
                  false,
                ),
                _buildSignalItem(
                  context,
                  'Liquidity Concerns',
                  'Current ratio below 1 indicates potential short-term payment issues.',
                  false,
                ),
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
              color: context.colorScheme.onSurface.withOpacity(0.7),
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
              color: context.colorScheme.onSurface.withOpacity(0.7),
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
