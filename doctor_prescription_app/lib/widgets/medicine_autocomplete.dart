import 'package:flutter/material.dart';
import '../data/medicine_list.dart';
import '../theme/app_colors.dart';

class MedicineAutocomplete extends StatefulWidget {
  final String initialValue;
  final Function(String) onSelected;

  const MedicineAutocomplete({
    super.key,
    this.initialValue = '',
    required this.onSelected,
  });

  @override
  State<MedicineAutocomplete> createState() => _MedicineAutocompleteState();
}

class _MedicineAutocompleteState extends State<MedicineAutocomplete> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<Map<String, String>> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _showSuggestions = false);
        }
      });
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final results = MedicineData.search(query);

    setState(() {
      _suggestions = results.take(10).toList(); // Limit to 10 results
      _showSuggestions = results.isNotEmpty;
    });
  }

  void _selectMedicine(Map<String, String> medicine) {
    _controller.text = medicine['name']!;
    widget.onSelected(medicine['name']!);
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input Field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Medicine Name',
            hintText: 'Type to search...',
            prefixIcon: const Icon(Icons.medication_rounded),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _controller.clear();
                      widget.onSelected('');
                      setState(() {
                        _suggestions = [];
                        _showSuggestions = false;
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            widget.onSelected(value);
            _search(value);
          },
        ),

        // Suggestions Dropdown
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final medicine = _suggestions[index];
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.medication,
                            size: 16, color: AppColors.primary),
                      ),
                      title: Text(
                        medicine['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        medicine['category']!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      onTap: () => _selectMedicine(medicine),
                      tileColor: _controller.text == medicine['name']
                          ? AppColors.primary.withOpacity(0.05)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
