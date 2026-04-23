import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';

class RouteCard extends StatelessWidget {
  final SavedRoute route;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final Function(String) onRename;
  final VoidCallback onDelete;

  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final distanceKm = (route.distance / 1000).toStringAsFixed(1);
    final durationMin = (route.duration / 60).round();
    final dateStr = DateFormat.yMMMd().add_Hm().format(route.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      route.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      route.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: route.isFavorite ? Colors.red : null,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameDialog(context);
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'rename', child: Text('Rename')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatItem(icon: Icons.straighten, label: '$distanceKm km'),
                  const SizedBox(width: 16),
                  _StatItem(icon: Icons.timer_outlined, label: '$durationMin min'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dateStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: route.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Route'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onRename(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
