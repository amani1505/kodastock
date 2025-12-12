import 'package:flutter/material.dart';
import 'package:kodastock/core/utils/extensions.dart';
import 'package:kodastock/core/utils/formatters.dart';
import 'package:kodastock/domain/entities/stock_entity.dart';

class StockCard extends StatelessWidget {
  final StockEntity stock;
  final VoidCallback? onTap;

  const StockCard({
    Key? key,
    required this.stock,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.changePercent >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with symbol and watchlist icon
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: context.colorScheme.primary.withOpacity(0.1),
                    radius: 20,
                    child: Text(
                      stock.symbol.substring(0, 2).toUpperCase(),
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.primary,
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
                          stock.symbol,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          stock.name,
                          style: context.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.star_border,
                    size: 20,
                    color: context.colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress bar placeholder
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Current price section with change percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CURRENT PRICE',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          size: 16,
                          color: changeColor,
                        ),
                        Text(
                          '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(0)}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Price and Volume row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${stock.currentPrice.toStringAsFixed(0)} TZS',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 14,
                        color: context.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Vol: ${Formatters.formatVolume(stock.volume)}',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Additional info row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: context.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'N/A',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // View Details button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('View Details'),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}