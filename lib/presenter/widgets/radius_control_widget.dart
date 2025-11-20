import 'package:flutter/material.dart';
import 'package:rpa/l10n/app_localizations.dart';

class RadiusControlWidget extends StatelessWidget {
  final int currentRadius;
  final Function(int) onRadiusChanged;

  const RadiusControlWidget({
    Key? key,
    required this.currentRadius,
    required this.onRadiusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.searchRadius ?? 'Search Radius',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatRadius(currentRadius),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _radiusToSliderValue(currentRadius),
            min: 0,
            max: 4,
            divisions: 4,
            label: _formatRadius(currentRadius),
            onChanged: (value) {
              final newRadius = _sliderValueToRadius(value);
              onRadiusChanged(newRadius);
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickButton(context, '1km', 1000),
              _buildQuickButton(context, '2km', 2000),
              _buildQuickButton(context, '5km', 5000),
              _buildQuickButton(context, '10km', 10000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(BuildContext context, String label, int radius) {
    final isSelected = currentRadius == radius;
    return GestureDetector(
      onTap: () => onRadiusChanged(radius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  String _formatRadius(int meters) {
    if (meters < 1000) {
      return '${meters}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(meters % 1000 == 0 ? 0 : 1)}km';
    }
  }

  double _radiusToSliderValue(int radius) {
    switch (radius) {
      case 500:
        return 0;
      case 1000:
        return 1;
      case 2000:
        return 2;
      case 5000:
        return 3;
      case 10000:
        return 4;
      default:
        return 1; // Default to 1km
    }
  }

  int _sliderValueToRadius(double value) {
    switch (value.round()) {
      case 0:
        return 500;
      case 1:
        return 1000;
      case 2:
        return 2000;
      case 3:
        return 5000;
      case 4:
        return 10000;
      default:
        return 1000;
    }
  }
}
