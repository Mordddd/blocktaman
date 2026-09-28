import 'package:flutter/material.dart';

import '../garden/garden_grid.dart';
import 'catalog.dart';

const _canvas = Color(0xFFF6F4EA);
const _ink = Color(0xFF23372D);
const _mutedInk = Color(0xFF526258);
const _primary = Color(0xFF285B42);
const _terracotta = Color(0xFFB95735);

class CollectionItemCard extends StatelessWidget {
  const CollectionItemCard({
    super.key,
    required this.item,
    required this.owned,
    this.equipped = false,
    this.onTap,
  });

  final DecorationItem item;
  final bool owned;
  final bool equipped;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = equipped
        ? 'Dipakai'
        : owned
        ? 'Dimiliki'
        : '${item.priceLeaves} Daun';
    return Semantics(
      button: onTap != null,
      label: '${item.name}, $status',
      child: ExcludeSemantics(
        child: Material(
          color: _canvas,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(minHeight: 132),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: equipped ? _primary : _primary.withValues(alpha: .22),
                  width: equipped ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: GardenItemPreview(item: item, compact: true),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: owned ? _primary : _terracotta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BoardThemeCard extends StatelessWidget {
  const BoardThemeCard({
    super.key,
    required this.theme,
    required this.owned,
    required this.selected,
    this.onTap,
  });

  final BoardTheme theme;
  final bool owned;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = selected
        ? 'Dipakai'
        : owned
        ? 'Dimiliki'
        : '${theme.priceLeaves} Daun';
    return Semantics(
      button: onTap != null,
      label: '${theme.name}, $status',
      child: ExcludeSemantics(
        child: Material(
          color: _canvas,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? _primary : _primary.withValues(alpha: .22),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  _ThemeSwatch(theme: theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: TextStyle(
                            color: owned ? _primary : _terracotta,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.theme});

  final BoardTheme theme;

  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(
      color: _swatchColor(theme.id),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.grid_4x4_outlined, color: Colors.white),
  );
}

Color _swatchColor(String id) => switch (id) {
  'morning' => _primary,
  'sunset' => _terracotta,
  'night' => const Color(0xFF33465B),
  _ => _mutedInk,
};
