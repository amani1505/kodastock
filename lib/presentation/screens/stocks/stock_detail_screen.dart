import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/config/dio_client.dart';
import '../../../core/config/constants/app_constants.dart';
import 'package:fl_chart/fl_chart.dart';

class StockDetailScreen extends ConsumerStatefulWidget {
  final String symbol;

  const StockDetailScreen({
    super.key,
    required this.symbol,
  });

  @override
  ConsumerState<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends ConsumerState<StockDetailScreen> {
  Map<String, dynamic>? stockData;
  List<Map<String, dynamic>> priceData = [];
  Map<String, dynamic>? simulationData;

  bool _isLoadingStock = true;
  bool _isLoadingPrices = true;
  bool _isLoadingSimulation = false;

  String _selectedPeriod = '1 Month';
  int _selectedDays = 30;

  final TextEditingController _capitalController = TextEditingController(text: '100000');
  final TextEditingController _dateController = TextEditingController();
  String _selectedStrategy = 'Balanced';

  @override
  void initState() {
    super.initState();
    _fetchStockDetails();
    _fetchPriceData();
    _setDefaultDate();
  }

  @override
  void dispose() {
    _capitalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _setDefaultDate() {
    final now = DateTime.now();
    _dateController.text = '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
  }

  Future<void> _fetchStockDetails() async {
    setState(() => _isLoadingStock = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('${AppConstants.baseUrl}/stocks/${widget.symbol}');

      debugPrint('Stock response: ${response.data}');

      if (mounted) {
        setState(() {
          // API returns data under response.data['data']['stock']
          stockData = response.data['data']?['stock'] ?? response.data['stock'];
          _isLoadingStock = false;
        });
        debugPrint('Stock data loaded: $stockData');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStock = false);
      }
      debugPrint('Error fetching stock details: $e');
    }
  }

  Future<void> _fetchPriceData() async {
    setState(() => _isLoadingPrices = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '${AppConstants.baseUrl}/stocks/${widget.symbol}/prices',
        queryParameters: {'days': _selectedDays},
      );

      if (mounted) {
        setState(() {
          priceData = (response.data['data']['prices'] as List<dynamic>)
              .map((p) => p as Map<String, dynamic>)
              .toList();
          _isLoadingPrices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPrices = false);
      }
      debugPrint('Error fetching price data: $e');
    }
  }

  Future<void> _runSimulation() async {
    if (stockData == null || stockData!['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock data not loaded yet')),
      );
      return;
    }

    // Validate capital input
    if (_capitalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter investment capital')),
      );
      return;
    }

    final capital = int.tryParse(_capitalController.text);
    if (capital == null || capital <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid investment amount')),
      );
      return;
    }

    setState(() => _isLoadingSimulation = true);
    try {
      final dio = ref.read(dioProvider);

      final requestData = {
        'stock_id': stockData!['id'],
        'capital': capital,
        'strategy': _selectedStrategy.toLowerCase(),
      };

      // Only add buy_date if it's provided
      if (_dateController.text.isNotEmpty) {
        requestData['buy_date'] = _formatDateForApi(_dateController.text);
      }

      debugPrint('Sending simulation request: $requestData');

      final response = await dio.post(
        '${AppConstants.baseUrl}/simulate-investment',
        data: requestData,
      );

      debugPrint('Simulation response: ${response.data}');

      if (mounted) {
        setState(() {
          simulationData = response.data['data'];
          _isLoadingSimulation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Simulation completed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSimulation = false);
      }
      debugPrint('Error running simulation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  String _formatDateForApi(String displayDate) {
    // Convert MM/DD/YYYY to YYYY-MM-DD
    final parts = displayDate.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}';
    }
    return displayDate;
  }

  void _changePeriod(String period, int days) {
    setState(() {
      _selectedPeriod = period;
      _selectedDays = days;
    });
    _fetchPriceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoadingStock
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock Header
                  _buildStockHeader(),
                  const SizedBox(height: 24),

                  // Period Selector
                  _buildPeriodSelector(),
                  const SizedBox(height: 16),

                  // Price Chart
                  _buildPriceChart(),
                  const SizedBox(height: 32),

                  // Trading Simulator
                  _buildTradingSimulator(),
                  const SizedBox(height: 32),

                  // Simulation Results
                  if (simulationData != null) ...[
                    _buildSimulationResults(),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStockHeader() {
    if (stockData == null) return const SizedBox();

    final changePercent = stockData!['change_percent'] ?? 0.0;
    final isPositive = changePercent >= 0;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stockData!['name'] ?? widget.symbol,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'TZS ${stockData!['current_price']}',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive
                            ? const Color(AppColors.successColor)
                            : const Color(AppColors.errorColor))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${stockData!['change']} (${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%)',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isPositive
                          ? const Color(AppColors.successColor)
                          : const Color(AppColors.errorColor),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Period:',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPeriodButton('7 Days', 7),
            _buildPeriodButton('1 Month', 30),
            _buildPeriodButton('3 Months', 90),
            _buildPeriodButton('6 Months', 180),
            _buildPeriodButton('1 Year', 365),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Current View: $_selectedPeriod',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String label, int days) {
    final isSelected = _selectedPeriod == label;
    return ElevatedButton(
      onPressed: () => _changePeriod(label, days),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? context.colorScheme.primary
            : context.colorScheme.surface,
        foregroundColor: isSelected
            ? Colors.white
            : context.colorScheme.onSurface,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.primary.withValues(alpha: 0.4),
            width: isSelected ? 0 : 1.5,
          ),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildPriceChart() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Movement',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _isLoadingPrices
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : priceData.isEmpty
                    ? const SizedBox(
                        height: 200,
                        child: Center(child: Text('No data available')),
                      )
                    : SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: 10,
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: (priceData.length / 6).ceilToDouble(),
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 && value.toInt() < priceData.length) {
                                      final date = priceData[value.toInt()]['date'] as String;
                                      final parts = date.split('-');
                                      if (parts.length == 3) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            '${parts[1]}/${parts[2]}',
                                            style: context.textTheme.bodySmall,
                                          ),
                                        );
                                      }
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 20,
                                  reservedSize: 42,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: context.textTheme.bodySmall,
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                              ),
                            ),
                            minX: 0,
                            maxX: (priceData.length - 1).toDouble(),
                            minY: _getMinPrice() - 10,
                            maxY: _getMaxPrice() + 10,
                            lineBarsData: [
                              LineChartBarData(
                                spots: priceData.asMap().entries.map((entry) {
                                  return FlSpot(
                                    entry.key.toDouble(),
                                    (entry.value['close'] as num).toDouble(),
                                  );
                                }).toList(),
                                isCurved: true,
                                color: const Color(AppColors.primaryColor),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
                                ),
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

  double _getMinPrice() {
    if (priceData.isEmpty) return 0;
    return priceData
        .map((p) => (p['close'] as num).toDouble())
        .reduce((a, b) => a < b ? a : b);
  }

  double _getMaxPrice() {
    if (priceData.isEmpty) return 100;
    return priceData
        .map((p) => (p['close'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  Widget _buildTradingSimulator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gps_fixed, color: Color(AppColors.errorColor)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Professional Trading Simulator',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                // Use column layout for small screens, row for larger screens
                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCapitalField(),
                      const SizedBox(height: 16),
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildStrategyField(),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: _buildCapitalField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDateField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStrategyField()),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingSimulation ? null : _runSimulation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: context.colorScheme.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
                child: _isLoadingSimulation
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Run Simulation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapitalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Capital (TZS)',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _capitalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '100000',
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buy Date (Optional)',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _dateController,
          decoration: const InputDecoration(
            hintText: 'mm/dd/yyyy',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              _dateController.text = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
            }
          },
        ),
      ],
    );
  }

  Widget _buildStrategyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strategy',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedStrategy,
          isExpanded: true,
          items: ['Balanced', 'Aggressive', 'Conservative']
              .map((strategy) => DropdownMenuItem(
                    value: strategy,
                    child: Text(strategy),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedStrategy = value);
            }
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationResults() {
    if (simulationData == null) return const SizedBox();

    final investment = simulationData!['investment'];
    final currentStatus = simulationData!['current_status'];
    final marketSentiment = simulationData!['market_sentiment'];
    final bestStrategy = simulationData!['best_strategy'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Investment Summary Cards - 2x2 Grid
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'INVESTMENT',
                    'TZS ${_formatNumber(investment['actual_investment'])}',
                    '${investment['shares']} shares',
                    const Color(AppColors.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'CURRENT VALUE',
                    'TZS ${_formatNumber(currentStatus['current_value'])}',
                    '${currentStatus['profit_loss_percent'] >= 0 ? '+' : ''}${currentStatus['profit_loss_percent'].toStringAsFixed(2)}%',
                    const Color(AppColors.successColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'RECOMMENDED ACTION',
                    bestStrategy['primary_recommendation']['action'],
                    bestStrategy['primary_recommendation']['holding_period'],
                    const Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'MARKET SENTIMENT',
                    marketSentiment['sentiment'],
                    'Score: ${marketSentiment['sentiment_score'].toStringAsFixed(2)}%',
                    const Color(0xFFFFA726),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Predictions Tabs
        _buildPredictionsTabs(),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsTabs() {
    if (simulationData == null) return const SizedBox();

    final predictions = simulationData!['predictions'];

    return DefaultTabController(
      length: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            isScrollable: true,
            labelColor: context.colorScheme.primary,
            unselectedLabelColor: context.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: context.colorScheme.primary,
            tabs: const [
              Tab(text: 'Predictions'),
              Tab(text: 'Technical'),
              Tab(text: 'Signals'),
              Tab(text: 'Best Strategy'),
            ],
          ),
          const SizedBox(height: 16),
          // Use intrinsic height for tab content instead of fixed height
          Builder(
            builder: (context) {
              final tabController = DefaultTabController.of(context);
              return AnimatedBuilder(
                animation: tabController,
                builder: (context, child) {
                  final index = tabController.index;
                  switch (index) {
                    case 0:
                      return _buildPredictionsTab(predictions);
                    case 1:
                      return _buildTechnicalTab();
                    case 2:
                      return _buildSignalsTab();
                    case 3:
                      return _buildBestStrategyTab();
                    default:
                      return _buildPredictionsTab(predictions);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsTab(Map<String, dynamic> predictions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            'Price Predictions & Scenarios',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPredictionCard('2d', predictions['2d']),
              _buildPredictionCard('1w', predictions['1w']),
              _buildPredictionCard('2w', predictions['2w']),
              _buildPredictionCard('1m', predictions['1m']),
              _buildPredictionCard('3m', predictions['3m']),
              _buildPredictionCard('6m', predictions['6m']),
            ],
          ),
        ],
    );
  }

  Widget _buildPredictionCard(String key, Map<String, dynamic> prediction) {
    final scenarios = prediction['scenarios'];
    final confidence = prediction['confidence'];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth < 600
              ? constraints.maxWidth
              : (constraints.maxWidth - 12) / 2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getConfidenceColor(confidence['score']).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getConfidenceColor(confidence['score']).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  prediction['period'],
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(confidence['score']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${confidence['score']}%',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${prediction['days']} days',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Divider(height: 24),
          _buildScenarioRow('Best Case:', scenarios['best']['price'], scenarios['best']['return_percent'], true),
          const SizedBox(height: 8),
          _buildScenarioRow('Expected:', scenarios['expected']['price'], scenarios['expected']['return_percent'], null),
          const SizedBox(height: 8),
          _buildScenarioRow('Worst Case:', scenarios['worst']['price'], scenarios['worst']['return_percent'], false),
          const Divider(height: 24),
          Text(
            'Your Return:',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'TZS ${_formatNumber(scenarios['expected']['profit'])}',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scenarios['expected']['profit'] >= 0
                  ? const Color(AppColors.successColor)
                  : const Color(AppColors.errorColor),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(AppColors.warningColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              prediction['recommendation'],
              style: context.textTheme.bodySmall?.copyWith(
                color: const Color(AppColors.warningColor),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Risk/Reward: ${prediction['risk_reward_ratio']}:1',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScenarioRow(String label, dynamic price, dynamic percent, bool? isPositive) {
    Color color = context.colorScheme.onSurface;
    if (isPositive != null) {
      color = isPositive ? const Color(AppColors.successColor) : const Color(AppColors.errorColor);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${price.toStringAsFixed(2)}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%',
              style: context.textTheme.bodySmall?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getConfidenceColor(int score) {
    if (score >= 75) return const Color(0xFF4CAF50);
    if (score >= 65) return const Color(0xFF8BC34A);
    if (score >= 50) return const Color(0xFFFFA726);
    return const Color(0xFFFF5722);
  }

  Widget _buildTechnicalTab() {
    if (simulationData == null) return const SizedBox();

    final technical = simulationData!['technical_analysis'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            'Technical Analysis',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Moving Averages
          Card(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moving Averages',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTechnicalRow('SMA 20', technical['moving_averages']['sma_20'].toString()),
                  _buildTechnicalRow('SMA 50', technical['moving_averages']['sma_50'].toString()),
                  _buildTechnicalRow('EMA 12', technical['moving_averages']['ema_12'].toString()),
                  _buildTechnicalRow('EMA 26', technical['moving_averages']['ema_26'].toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Momentum
          Card(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Momentum Indicators',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTechnicalRow('RSI', '${technical['momentum']['rsi'].toStringAsFixed(2)} (${technical['momentum']['rsi_signal']})'),
                  _buildTechnicalRow('MACD', '${technical['momentum']['macd'].toStringAsFixed(2)} (${technical['momentum']['macd_signal']})'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Support & Resistance
          Card(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support & Resistance',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTechnicalRow('Resistance 3', technical['support_resistance']['resistance_3'].toString(), Colors.red),
                  _buildTechnicalRow('Resistance 2', technical['support_resistance']['resistance_2'].toString(), Colors.red),
                  _buildTechnicalRow('Resistance 1', technical['support_resistance']['resistance_1'].toString(), Colors.red),
                  _buildTechnicalRow('Pivot', technical['support_resistance']['pivot'].toString(), Colors.blue),
                  _buildTechnicalRow('Support 1', technical['support_resistance']['support_1'].toString(), Colors.green),
                  _buildTechnicalRow('Support 2', technical['support_resistance']['support_2'].toString(), Colors.green),
                  _buildTechnicalRow('Support 3', technical['support_resistance']['support_3'].toString(), Colors.green),
                ],
              ),
            ),
          ),
        ],
    );
  }

  Widget _buildTechnicalRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalsTab() {
    if (simulationData == null) return const SizedBox();

    final signals = simulationData!['trading_signals'];
    final signalsList = signals['signals'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            'Trading Signals',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Overall Signal
          Card(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Signal:',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSignalColor(signals['summary']['overall']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getSignalColor(signals['summary']['overall'])),
                    ),
                    child: Text(
                      signals['summary']['overall'].toString().toUpperCase(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getSignalColor(signals['summary']['overall']),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Signal List
          ...signalsList.map((signal) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: ListTile(
              leading: Icon(
                signal['type'] == 'bullish' ? Icons.trending_up : Icons.trending_down,
                color: signal['type'] == 'bullish'
                    ? const Color(AppColors.successColor)
                    : const Color(AppColors.errorColor),
              ),
              title: Text(
                signal['indicator'],
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(signal['message']),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStrengthColor(signal['strength']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  signal['strength'],
                  style: context.textTheme.bodySmall?.copyWith(
                    color: _getStrengthColor(signal['strength']),
                  ),
                ),
              ),
            ),
          )),
        ],
    );
  }

  Widget _buildBestStrategyTab() {
    if (simulationData == null) return const SizedBox();

    final strategy = simulationData!['best_strategy'];
    final primaryRec = strategy['primary_recommendation'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            'Recommended Strategy',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Primary Recommendation
          Card(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      primaryRec['action'],
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStrategyRow('Holding Period', primaryRec['holding_period']),
                  _buildStrategyRow('Expected Return', '${primaryRec['expected_return'].toStringAsFixed(2)}%'),
                  _buildStrategyRow('Confidence', '${primaryRec['confidence']}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Key Factors
          Text(
            'Key Factors',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...(strategy['key_factors'] as List).map((factor) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Color(AppColors.successColor)),
              title: Text(factor.toString()),
            ),
          )),
          const SizedBox(height: 16),

          // Risk Warnings
          if (strategy['risk_warnings'] != null && (strategy['risk_warnings'] as List).isNotEmpty) ...[
            Text(
              'Risk Warnings',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...(strategy['risk_warnings'] as List).map((warning) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: context.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.warning, color: Color(AppColors.warningColor)),
                title: Text(warning.toString()),
              ),
            )),
          ],
        ],
    );
  }

  Widget _buildStrategyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(String signal) {
    switch (signal.toLowerCase()) {
      case 'bullish':
        return const Color(AppColors.successColor);
      case 'bearish':
        return const Color(AppColors.errorColor);
      default:
        return const Color(AppColors.warningColor);
    }
  }

  Color _getStrengthColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'strong':
        return const Color(AppColors.errorColor);
      case 'moderate':
        return const Color(AppColors.warningColor);
      default:
        return const Color(AppColors.successColor);
    }
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final double parsedNum = (number is int || number is double)
        ? number.toDouble()
        : double.tryParse(number.toString()) ?? 0;
    return parsedNum.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
