import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muta_manager/theme/theme_provider.dart';
import 'package:muta_manager/theme/app_theme.dart';

class CeroSelector extends StatelessWidget {
  final bool showAsPopup;
  final bool showFullName;
  final Function(CeroType)? onCeroChanged;

  const CeroSelector({
    super.key,
    this.showAsPopup = false,
    this.showFullName = true,
    this.onCeroChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (showAsPopup) {
          return _buildPopupSelector(context, themeProvider);
        } else {
          return _buildInlineSelector(context, themeProvider);
        }
      },
    );
  }

  Widget _buildPopupSelector(BuildContext context, ThemeProvider themeProvider) {
    return PopupMenuButton<CeroType>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(themeProvider.currentCeroIcon),
          const SizedBox(width: 4),
          if (showFullName) Text(themeProvider.currentCeroName),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      onSelected: (CeroType cero) {
        themeProvider.changeCero(cero);
        if (onCeroChanged != null) {
          onCeroChanged!(cero);
        }
      },
      itemBuilder: (BuildContext context) => [
        _buildPopupMenuItem(CeroType.santUbaldo, "Sant'Ubaldo", Icons.star, Colors.yellow.shade700),
        _buildPopupMenuItem(CeroType.sanGiorgio, "San Giorgio", Icons.shield, Colors.blue.shade700),
        _buildPopupMenuItem(CeroType.santAntonio, "Sant'Antonio", Icons.local_fire_department, Colors.black),
      ],
    );
  }

  PopupMenuItem<CeroType> _buildPopupMenuItem(CeroType cero, String name, IconData icon, Color color) {
    return PopupMenuItem<CeroType>(
      value: cero,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(name),
        ],
      ),
    );
  }

  Widget _buildInlineSelector(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max, // Changed to max to fill available width
        children: CeroType.values.map((cero) {
          final isSelected = themeProvider.currentCero == cero;
          return Expanded( // Wrap each item in Expanded
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  themeProvider.changeCero(cero);
                  if (onCeroChanged != null) {
                    onCeroChanged!(cero);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _getCeroColor(cero) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCeroIcon(cero),
                      color: isSelected ? Colors.white : _getCeroColor(cero),
                      size: 16,
                    ),
                    if (showFullName) ...[
                      const SizedBox(width: 4),
                      // Wrap Text in FittedBox
                      Flexible( // Still need Flexible to constrain FittedBox within the Row
                        child: FittedBox(
                          fit: BoxFit.scaleDown, // Scale down, but don't scale up
                          child: Text(
                            _getCeroName(cero),
                            style: TextStyle(
                              color: isSelected ? Colors.white : _getCeroColor(cero),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12, // This will be the max size
                            ),
                            maxLines: 1, // Ensure it stays on one line
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCeroName(CeroType cero) {
    switch (cero) {
      case CeroType.santUbaldo:
        return "Sant'Ubaldo";
      case CeroType.sanGiorgio:
        return "San Giorgio";
      case CeroType.santAntonio:
        return "Sant'Antonio";
    }
  }

  IconData _getCeroIcon(CeroType cero) {
    switch (cero) {
      case CeroType.santUbaldo:
        return Icons.star;
      case CeroType.sanGiorgio:
        return Icons.shield;
      case CeroType.santAntonio:
        return Icons.local_fire_department;
    }
  }

  Color _getCeroColor(CeroType cero) {
    switch (cero) {
      case CeroType.santUbaldo:
        return Colors.yellow.shade700;
      case CeroType.sanGiorgio:
        return Colors.blue.shade700;
      case CeroType.santAntonio:
        return Colors.black;
    }
  }
}