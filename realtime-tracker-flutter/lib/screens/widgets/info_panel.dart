import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../providers/websocket_provider.dart';
import '../../theme/app_theme.dart';

class InfoPanel extends StatelessWidget {
  final WebSocketProvider wsProvider;
  final Function(String) onMapStyleChanged;

  const InfoPanel({
    Key? key,
    required this.wsProvider,
    required this.onMapStyleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device ID Section
              _InfoItem(
                label: 'Device ID:',
                value: wsProvider.userId,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: wsProvider.userId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User ID copied!')),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Status Section
              _StatusBadge(status: wsProvider.connectionStatus),
              const SizedBox(height: 12),

              // User Count Section
              _InfoItem(
                label: 'Users Online:',
                value: '${wsProvider.userCount}',
              ),
              const SizedBox(height: 16),

              // Map Layer Switcher
              _MapLayerSwitcher(onMapStyleChanged: onMapStyleChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _InfoItem({
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        if (onCopy != null) ...[
          const SizedBox(width: 4),
          InkWell(
            onTap: onCopy,
            child: const Icon(Icons.copy, size: 16, color: AppTheme.primary),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isConnected = status.contains('Connected');
    final backgroundColor = isConnected ? Colors.green[100] : Colors.yellow[100];
    final textColor = isConnected ? Colors.green[800] : Colors.yellow[800];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _MapLayerSwitcher extends StatefulWidget {
  final Function(String) onMapStyleChanged;

  const _MapLayerSwitcher({required this.onMapStyleChanged});

  @override
  State<_MapLayerSwitcher> createState() => _MapLayerSwitcherState();
}

class _MapLayerSwitcherState extends State<_MapLayerSwitcher> {
  String selectedLayer = 'openstreetmap';

  final Map<String, String> mapLayers = {
    'openstreetmap': 'https://demotiles.maplibre.org/style.json',
    'cartodb': 'https://a.basemaps.cartocdn.com/gl/positron/style.json',
    'stamen': 'https://tiles.stadiamaps.com/styles/stamen_terrain.json',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Map Layer:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: mapLayers.entries.map((entry) {
            final isSelected = selectedLayer == entry.key;
            return FilterChip(
              label: Text(
                entry.key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.primary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() => selectedLayer = entry.key);
                widget.onMapStyleChanged(entry.value);
              },
              backgroundColor: Colors.transparent,
              selectedColor: AppTheme.primary,
              side: BorderSide(
                color: isSelected ? AppTheme.primary : Colors.grey[300]!,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String toCapitalized() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
