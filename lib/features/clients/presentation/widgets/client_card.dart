import 'package:flutter/material.dart';
import '../../domain/client.dart';
import '../../../../core/theme/app_colors.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final initials = client.name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();
    final avatarColor = _parseColor(client.avatarColor);

    return Dismissible(
      key: Key(client.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (client.company != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          client.company!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.lightTextSecondary),
                        ),
                      ],
                      if (client.email != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          client.email!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                if (client.country != null)
                  Text(
                    _getFlag(client.country!),
                    style: const TextStyle(fontSize: 24),
                  ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary500;
    }
  }

  String _getFlag(String country) {
    final flags = {
      'US': '🇺🇸',
      'GB': '🇬🇧',
      'CA': '🇨🇦',
      'AU': '🇦🇺',
      'DE': '🇩🇪',
      'FR': '🇫🇷',
      'ES': '🇪🇸',
      'IT': '🇮🇹',
      'JP': '🇯🇵',
      'CN': '🇨🇳',
      'IN': '🇮🇳',
      'KH': '🇰🇭',
      'TH': '🇹🇭',
      'SG': '🇸🇬',
      'MY': '🇲🇾',
      'VN': '🇻🇳',
    };
    return flags[country.toUpperCase()] ?? '🌍';
  }
}
