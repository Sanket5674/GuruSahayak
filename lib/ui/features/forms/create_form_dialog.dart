import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/dynamic_form.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/services/auth_service.dart';

class CreateFormDialog extends StatefulWidget {
  const CreateFormDialog({super.key});

  @override
  State<CreateFormDialog> createState() => _CreateFormDialogState();
}

class _CreateFormDialogState extends State<CreateFormDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _deadlineController = TextEditingController(text: '25 Oct 2026');

  final List<FormQuestion> _questions = [
    FormQuestion(id: 'Q1', label: 'Sample Question 1', type: FormFieldType.text),
  ];

  final _newQuestionController = TextEditingController();
  FormFieldType _newQuestionType = FormFieldType.text;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _deadlineController.dispose();
    _newQuestionController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    if (_newQuestionController.text.trim().isEmpty) return;
    setState(() {
      _questions.add(FormQuestion(
        id: 'Q_${DateTime.now().millisecondsSinceEpoch}',
        label: _newQuestionController.text.trim(),
        type: _newQuestionType,
      ));
      _newQuestionController.clear();
    });
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a survey title and at least 1 question')),
      );
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    final db = Provider.of<LocalDatabaseService>(context, listen: false);

    final form = DynamicForm(
      id: 'FRM_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? 'Ad-hoc field survey from education office' : _descController.text.trim(),
      createdBy: auth.currentUser.name,
      deadline: _deadlineController.text.trim(),
      questions: List.from(_questions),
    );

    db.addDynamicForm(form);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ Survey form created and dispatched to all teachers!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.dynamic_form_rounded, color: AppColors.primaryNavy),
          SizedBox(width: 8),
          Text('Build Ad-Hoc Survey Form', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Survey Title (e.g. Science Kit Audit)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Short Description / Purpose'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _deadlineController,
              decoration: const InputDecoration(labelText: 'Submission Deadline'),
            ),
            const SizedBox(height: 16),
            const Text('Form Questions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            ..._questions.map((q) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(_getIconForType(q.type), size: 16, color: AppColors.primaryNavy),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${q.label} (${q.type.name})', style: const TextStyle(fontSize: 11.5)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 16, color: AppColors.dangerRed),
                        onPressed: () => setState(() => _questions.remove(q)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newQuestionController,
                    decoration: const InputDecoration(labelText: 'Add question text...'),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<FormFieldType>(
                  value: _newQuestionType,
                  items: FormFieldType.values.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t.name, style: const TextStyle(fontSize: 11)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _newQuestionType = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Question to Form', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Publish Survey Form')),
      ],
    );
  }

  IconData _getIconForType(FormFieldType type) {
    switch (type) {
      case FormFieldType.text:
        return Icons.short_text_rounded;
      case FormFieldType.number:
        return Icons.numbers_rounded;
      case FormFieldType.dropdown:
        return Icons.arrow_drop_down_circle_outlined;
      case FormFieldType.boolean:
        return Icons.check_circle_outline_rounded;
    }
  }
}
