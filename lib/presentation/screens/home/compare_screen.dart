import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/extensions.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  String? stock1;
  String? stock2;
  String? stock3;
  String period = '1 Month';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelectionSection(context),
            const SizedBox(height: 24),
            _buildCompareButton(context),
            const SizedBox(height: 32),
            if (stock1 != null && stock2 != null) ...[
              _buildComparisonResults(context),
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
              'Select Stocks to Compare',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildStockDropdown(context, 'Stock 1', stock1, (value) {
              setState(() => stock1 = value);
            }),
            const SizedBox(height: 16),
            _buildStockDropdown(context, 'Stock 2', stock2, (value) {
              setState(() => stock2 = value);
            }),
            const SizedBox(height: 16),
            _buildStockDropdown(context, 'Stock 3 (Optional)', stock3, (value) {
              setState(() => stock3 = value);
            }),
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
    Function(String?) onChanged,
  ) {
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
          value: value,
          decoration: InputDecoration(
            hintText: 'Select a stock',
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
          value: period,
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
                // Trigger comparison
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Comparing stocks...')),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows),
            const SizedBox(width: 8),
            Text('Compare Stocks'),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparison Results',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildResultBadges(context),
        const SizedBox(height: 20),
        _buildComparisonCard(context),
        const SizedBox(height: 20),
        _buildMarketCautionCard(context),
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

  Widget _buildBadge(BuildContext context, String label, String stock, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _buildComparisonCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Metrics Comparison',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(context, 'Current Price', '1,160 TZS', '445 TZS', '2,140 TZS'),
            Divider(),
            _buildMetricRow(context, '30-Day Change', '-0.85%', '-7.29%', '+0%'),
            Divider(),
            _buildMetricRow(context, 'Financial Health', '58% Fair', 'N/A', 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value1, String value2, String value3) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(value1, style: context.textTheme.bodyMedium)),
              Expanded(child: Text(value2, style: context.textTheme.bodyMedium)),
              Expanded(child: Text(value3, style: context.textTheme.bodyMedium)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketCautionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
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
