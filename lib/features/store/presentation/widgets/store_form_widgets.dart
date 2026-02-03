import 'package:flutter/material.dart';

class StoreFormSectionTitle extends StatelessWidget {
  final String title;
  const StoreFormSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: theme.colorScheme.primary, // Teal from AppTheme
        ),
      ),
    );
  }
}

class StoreInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const StoreInputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.number,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tealColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: theme.hintColor),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: tealColor,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () => controller.text = "0",
              color: tealColor.withOpacity(0.5),
            ),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: tealColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class StoreProductSelector extends StatelessWidget {
  final dynamic selectedValue;
  final ValueChanged<dynamic> onChanged;
  final List<dynamic> products;

  const StoreProductSelector({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tealColor = theme.colorScheme.primary;

    return RawAutocomplete<Object>(
      // 🔍 Filters the list or returns empty if the store is empty
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<Object>.empty();

        return products.where((p) {
          try {
            // p is likely your StoreStock or Product model
            final String name = (p as dynamic).name.toString().toLowerCase();
            return name.contains(textEditingValue.text.toLowerCase());
          } catch (e) {
            return false;
          }
        }).cast<Object>();
      },

      displayStringForOption: (option) => (option as dynamic).name ?? "",

      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Sync controller with current state if needed
        if (selectedValue is String && controller.text != selectedValue) {
          controller.text = selectedValue;
        }

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          cursorColor: tealColor,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: "Enter new name or select existing...",
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
            prefixIcon: Icon(Icons.shopping_bag_outlined, color: tealColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: tealColor, width: 1.5),
            ),
          ),
          // ✅ CRITICAL: Capture the manual typing for "new" products
          onChanged: (value) => onChanged(value),
        );
      },

      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: theme.cardColor,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: 200,
                  maxWidth: MediaQuery.of(context).size.width - 40
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index) as dynamic;
                  return ListTile(
                    title: Text(
                        option.name ?? "Unnamed Product",
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color)
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
      // ✅ When an existing product is found and clicked, send the object
      onSelected: (option) => onChanged(option),
    );
  }
}