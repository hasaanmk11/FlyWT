import 'package:flutter/material.dart';
import 'package:flightdeck/core/theme/app_colors.dart';

/// Floating pill bar at the bottom with Sort and Filter action triggers.
class SortFilterBar extends StatelessWidget {
  final VoidCallback onSortTap;
  final VoidCallback onFilterTap;
  final bool isFilterActive;
  final bool isSortActive;

  const SortFilterBar({
    super.key,
    required this.onSortTap,
    required this.onFilterTap,
    this.isFilterActive = false,
    this.isSortActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sort Button
              InkWell(
                onTap: onSortTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.swap_vert_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Sort',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (isSortActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // White Vertical Divider
              Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.white.withValues(alpha: 0.5),
              ),

              // Filter Button
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (isFilterActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
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
