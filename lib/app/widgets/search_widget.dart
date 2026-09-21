import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
    required this.textEditingController,
    this.onChanged,
    this.onFilterTap,
    this.maxHeight = 46,
    this.isClearShow = false,
    this.hintText = 'Search...',
  });

  final TextEditingController textEditingController;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final double maxHeight;
  final bool isClearShow;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxHeight,
      child: ListenableBuilder(
        listenable: textEditingController,
        builder: (context, child) {
          final bool showClearButton =
              isClearShow && textEditingController.text.isNotEmpty;

          return TextFormField(
            controller: textEditingController,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _buildSuffix(showClearButton),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? _buildSuffix(bool showClearButton) {
    if (showClearButton) {
      return IconButton(
        tooltip: 'Clear search',
        onPressed: () {
          textEditingController.clear();
          onChanged?.call('');
        },
        icon: const Icon(Icons.close, size: 18),
      );
    }

    if (onFilterTap != null) {
      return IconButton(
        tooltip: 'Filter',
        onPressed: onFilterTap,
        icon: const Icon(Icons.filter_list, size: 20),
      );
    }

    return null;
  }
}
