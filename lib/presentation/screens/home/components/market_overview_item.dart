import 'package:flutter/material.dart';
import 'package:kodastock/core/utils/extensions.dart';
import 'package:kodastock/core/utils/formatters.dart';


class MarketOverviewItem extends StatelessWidget {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double volume;

  const MarketOverviewItem({
    Key? key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.volume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final changeColor = change == 0
        ? context.colorScheme.onSurface.withOpacity(0.5)
        : (isPositive ? Colors.green : Colors.red);

    return InkWell(
      onTap: () {
        // Handle tap to show details
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _getColorForSymbol(symbol).withOpacity(0.2),
                    child: Text(
                      symbol.substring(0, 2).toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: _getColorForSymbol(symbol),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symbol,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          name,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                Formatters.formatCurrency(price).split(' ')[0],
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change == 0 ? '-' : Formatters.formatPercentage(change),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                Formatters.formatVolume(volume),
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSymbol(String symbol) {
    // Generate a color based on the symbol
    final hash = symbol.hashCode;
    final colors = [
      Colors.purple,
      Colors.amber,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];
    return colors[hash.abs() % colors.length];
  }
}
