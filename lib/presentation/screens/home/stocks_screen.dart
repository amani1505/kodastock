import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/stock_entity.dart';
import '../../providers/app_providers.dart';
import 'components/stock_card.dart';

class StocksScreen extends ConsumerStatefulWidget {
  const StocksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends ConsumerState<StocksScreen> {
  String? selectedSector;
  String selectedSort = 'Symbol';

  @override
  Widget build(BuildContext context) {
    final stocksAsync = ref.watch(stocksListProvider(selectedSector));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Stocks'),
            Text(
              'Track and analyze DSE listed companies',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search stocks...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      // Implement search
                    },
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list),
                  tooltip: 'Filter by sector',
                  onSelected: (value) {
                    setState(() {
                      selectedSector = value == 'All' ? null : value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'All', child: Text('All Sectors')),
                    PopupMenuItem(value: 'Banking', child: Text('Banking')),
                    PopupMenuItem(value: 'Energy', child: Text('Energy')),
                    PopupMenuItem(value: 'Telecom', child: Text('Telecom')),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort),
                  tooltip: 'Sort by',
                  onSelected: (value) {
                    setState(() {
                      selectedSort = value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'Symbol', child: Text('Symbol')),
                    PopupMenuItem(value: 'Price', child: Text('Price')),
                    PopupMenuItem(value: 'Change', child: Text('Change')),
                    PopupMenuItem(value: 'Volume', child: Text('Volume')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: stocksAsync.when(
        data: (stocks) => _buildStocksList(context, stocks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildStocksList(BuildContext context, List<StockEntity> stocks) {
    if (stocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: context.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No stocks found',
              style: context.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(stocksListProvider(selectedSector));
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL STOCKS',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  stocks.length.toString(),
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'GAINERS',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  stocks.where((s) => s.isGainer).length.toString(),
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'LOSERS',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  stocks.where((s) => s.isLoser).length.toString(),
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                final stock = stocks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: StockCard(
                    stock: stock,
                    onTap: () => _showStockDetails(context, stock),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load stocks',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(stocksListProvider(selectedSector)),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showStockDetails(BuildContext context, StockEntity stock) {
    // Navigate to the detailed stock screen
    context.push('/stock/${stock.symbol}');
  }
}