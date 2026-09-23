import 'package:flutter/material.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/modules/deals/controllers/deals_controller.dart';
import 'package:foodiepos/modules/deals/models/deal_model.dart';
import 'package:get/get.dart';

class DealsListSection extends GetView<DealsController> {
  const DealsListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================================
        // 1. TOP SEARCH & FILTER BAR
        // =====================================================================
        Row(
          children: [
            // Search Input
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222B) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20, color: colors.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        decoration: InputDecoration(
                          hintText: 'Search deals...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 13, color: colors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Dropdown Filter
            Obx(() {
              return Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222B) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCategoryDropdown.value,
                    icon: Icon(Icons.keyboard_arrow_down, size: 18, color: colors.onSurfaceVariant),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    dropdownColor: isDark ? const Color(0xFF1E222B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: ['All Deals', 'Meal Combos', 'Family Deals', 'Limited Time']
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedCategoryDropdown.value = val;
                    },
                  ),
                ),
              );
            }),
            const SizedBox(width: 10),

            // Filter Icon Button
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E222B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  controller.selectedFilter.value = 'All';
                  controller.selectedCategoryDropdown.value = 'All Deals';
                  controller.searchQuery.value = '';
                },
                icon: Icon(Icons.tune_rounded, size: 18, color: colors.onSurfaceVariant),
                tooltip: 'Reset Filters',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // =====================================================================
        // 2. FILTER PILLS ROW
        // =====================================================================
        Obx(() {
          final total = controller.totalCount;
          final active = controller.activeCount;
          final inactive = controller.inactiveCount;

          final pills = [
            {'id': 'All', 'label': 'All ($total)'},
            {'id': 'Active', 'label': 'Active ($active)'},
            {'id': 'Inactive', 'label': 'Inactive ($inactive)'},
            {'id': 'Meal Combos', 'label': 'Meal Combos'},
            {'id': 'Family Deals', 'label': 'Family Deals'},
            {'id': 'Limited Time', 'label': 'Limited Time'},
          ];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: pills.map((p) {
                final isSelected = controller.selectedFilter.value == p['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => controller.selectedFilter.value = p['id']!,
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF6B35)
                            : (isDark ? const Color(0xFF1E222B) : const Color(0xFFF2F4F7)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF6B35)
                              : (isDark ? const Color(0xFF2A313F) : Colors.transparent),
                        ),
                      ),
                      child: Text(
                        p['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? colors.onSurface : const Color(0xFF344054)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),

        const SizedBox(height: 16),

        // =====================================================================
        // 3. VERTICAL DEALS LIST
        // =====================================================================
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.deals.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = controller.filteredDeals;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard_outlined, size: 48, color: colors.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      'No deals found matching criteria',
                      style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final deal = list[index];
                final isSelected = controller.isEditorOpen.value &&
                    controller.selectedDeal.value?.id == deal.id &&
                    !controller.isCreatingNew.value;

                return _DealCard(
                  deal: deal,
                  isSelected: isSelected,
                  onSelect: () => controller.selectDeal(deal),
                  onEdit: () => controller.selectDeal(deal),
                  onToggleStatus: () => controller.toggleDealStatus(deal),
                  onDelete: () => _confirmDeleteDeal(context, deal),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _confirmDeleteDeal(BuildContext context, DealModel deal) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Deal?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${deal.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteDeal(deal);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF04438),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final DealModel deal;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _DealCard({
    required this.deal,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2A231C) : const Color(0xFFFFF9F5))
              : (isDark ? const Color(0xFF1E222B) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6B35)
                : (isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0)),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.04 : 0.015),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail Image Box
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF13171F) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: _buildImage(deal.image),
              ),
            ),
            const SizedBox(width: 14),

            // Deal Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    deal.description ?? 'Combo deal',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Price in Bold Orange
            Text(
              'Rs ${deal.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF6B35),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 12),

            // Status Pill (Active / Inactive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: deal.isActive
                    ? const Color(0xFFE8FDF2)
                    : const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                deal.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: deal.isActive ? const Color(0xFF12B76A) : const Color(0xFFF04438),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Edit Button Pill
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13171F) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A313F) : const Color(0xFFD0D5DD),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 13, color: colors.onSurface),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),

            // 3-Dots Menu
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18, color: colors.onSurfaceVariant),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (val) {
                if (val == 'toggle') {
                  onToggleStatus();
                } else if (val == 'edit') {
                  onEdit();
                } else if (val == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 16),
                      const SizedBox(width: 8),
                      const Text('Edit Deal', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        deal.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        deal.isActive ? 'Set Inactive' : 'Set Active',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Color(0xFFF04438),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delete Deal',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFF04438),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    return AppImageWidget(
      imagePath: path,
      width: 58,
      height: 58,
      fit: BoxFit.cover,
      fallbackIcon: Icons.local_offer_outlined,
    );
  }
}
