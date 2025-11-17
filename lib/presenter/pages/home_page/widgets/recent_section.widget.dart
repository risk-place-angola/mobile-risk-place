import 'package:flutter/material.dart';
import 'package:rpa/presenter/controllers/home_panel.controller.dart';

class RecentSection extends StatelessWidget {
  final List<RecentItem> recentItems;
  final Function(RecentItem) onItemTap;

  const RecentSection({
    Key? key,
    required this.recentItems,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recentItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Recent',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentItems.length > 5 ? 5 : recentItems.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 72,
            color: Colors.grey[300],
          ),
          itemBuilder: (context, index) {
            final item = recentItems[index];
            return RecentItemTile(
              item: item,
              onTap: () => onItemTap(item),
            );
          },
        ),
      ],
    );
  }
}

class RecentItemTile extends StatelessWidget {
  final RecentItem item;
  final VoidCallback onTap;

  const RecentItemTile({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  Color _getIconColor(RecentItemType type) {
    switch (type) {
      case RecentItemType.neighborhood:
        return Colors.blue;
      case RecentItemType.incident:
        return Colors.red;
      case RecentItemType.safeRoute:
        return Colors.green;
      case RecentItemType.location:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor(item.type);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
