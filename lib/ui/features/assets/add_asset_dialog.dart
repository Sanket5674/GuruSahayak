import 'package:flutter/material.dart';
import '../../../data/models/school_asset.dart';

class AddAssetDialog extends StatefulWidget {
  final Function(SchoolAsset) onAdd;

  const AddAssetDialog({super.key, required this.onAdd});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _locationController = TextEditingController(text: 'Main Building');
  final _yearController = TextEditingController(text: '2024');
  final _remarksController = TextEditingController();

  String _category = 'Furniture';
  AssetCondition _condition = AssetCondition.working;
  String _funding = 'Samagra Shiksha Abhiyan';

  final List<String> _categories = [
    'Furniture',
    'Electronics / Smart TV',
    'Drinking Water & Sanitation',
    'Sports & Lab',
  ];

  final List<String> _fundingSources = [
    'Samagra Shiksha Abhiyan',
    'CSR Grant',
    'Zilla Parishad District Fund',
    'Gram Panchayat Fund',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _locationController.dispose();
    _yearController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter asset item name')),
      );
      return;
    }

    final newAsset = SchoolAsset(
      id: 'AST_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _category,
      quantity: int.tryParse(_qtyController.text.trim()) ?? 1,
      condition: _condition,
      fundingScheme: _funding,
      location: _locationController.text.trim(),
      purchaseYear: _yearController.text.trim(),
      remarks: _remarksController.text.trim(),
    );

    widget.onAdd(newAsset);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add School Asset (नवीन साहित्य नोंद)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name (साहित्याचे नाव)', hintText: 'e.g. Science Lab Microscope'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Year of Grant'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<AssetCondition>(
              value: _condition,
              decoration: const InputDecoration(labelText: 'Condition Status'),
              items: AssetCondition.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _condition = val);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _funding,
              decoration: const InputDecoration(labelText: 'Funding Scheme'),
              items: _fundingSources.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _funding = val);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Room / Location'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Save Asset')),
      ],
    );
  }
}
