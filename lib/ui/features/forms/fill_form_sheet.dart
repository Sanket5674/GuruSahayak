import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/dynamic_form.dart';
import '../../../data/services/local_database_service.dart';

class FillFormSheet extends StatefulWidget {
  final DynamicForm form;

  const FillFormSheet({super.key, required this.form});

  @override
  State<FillFormSheet> createState() => _FillFormSheetState();
}

class _FillFormSheetState extends State<FillFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    // Prefill if previously submitted or drafted
    if (widget.form.responses.isNotEmpty) {
      _answers.addAll(widget.form.responses);
    }
  }

  void _saveResponse() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final db = Provider.of<LocalDatabaseService>(context, listen: false);

    // Convert all answers to String map
    final Map<String, String> stringResponses = {};
    _answers.forEach((key, value) {
      stringResponses[key] = value?.toString() ?? '';
    });

    db.submitFormResponse(widget.form.id, stringResponses);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successGreen,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '✓ Survey "${widget.form.title}" submitted offline successfully!',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primaryNavy, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.form.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Issued by: ${widget.form.createdBy} • Due: ${widget.form.deadline}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.form.description,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textMedium, height: 1.3),
              ),
              const Divider(height: 28),
              ...widget.form.questions.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final q = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$idx. ${q.label}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildQuestionInput(q),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _saveResponse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.cloud_done_rounded, size: 20),
                label: Text(
                  widget.form.isSubmitted ? 'Update Saved Response' : 'Submit Survey Report (Offline Saved)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionInput(FormQuestion q) {
    switch (q.type) {
      case FormFieldType.text:
        return TextFormField(
          initialValue: _answers[q.id]?.toString() ?? '',
          decoration: InputDecoration(
            hintText: 'Enter response here...',
            fillColor: AppColors.backgroundLight,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          validator: (v) {
            if (q.isRequired && (v == null || v.trim().isEmpty)) {
              return 'This question requires an answer';
            }
            return null;
          },
          onSaved: (v) => _answers[q.id] = v?.trim() ?? '',
        );

      case FormFieldType.number:
        return TextFormField(
          initialValue: _answers[q.id]?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g. 15',
            fillColor: AppColors.backgroundLight,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          validator: (v) {
            if (q.isRequired && (v == null || v.trim().isEmpty)) {
              return 'Please enter a count or number';
            }
            return null;
          },
          onSaved: (v) => _answers[q.id] = v?.trim() ?? '',
        );

      case FormFieldType.dropdown:
        final options = q.options.isNotEmpty
            ? q.options
            : ['Yes / होय', 'No / नाही', 'Not Applicable / लागू नाही'];
        return DropdownButtonFormField<String>(
          value: _answers[q.id]?.toString(),
          decoration: InputDecoration(
            fillColor: AppColors.backgroundLight,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          hint: const Text('Select applicable option', style: TextStyle(fontSize: 13)),
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text(opt, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          validator: (v) {
            if (q.isRequired && (v == null || v.isEmpty)) {
              return 'Please select an option';
            }
            return null;
          },
          onChanged: (v) => setState(() => _answers[q.id] = v),
          onSaved: (v) => _answers[q.id] = v ?? '',
        );

      case FormFieldType.boolean:
        final currentVal = _answers[q.id] == 'true' || _answers[q.id] == true;
        return Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 16),
                    SizedBox(width: 6),
                    Text('होय (Yes)'),
                  ],
                ),
                selected: currentVal,
                selectedColor: AppColors.successGreen.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: currentVal ? AppColors.successGreen : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  setState(() => _answers[q.id] = 'true');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, size: 16),
                    SizedBox(width: 6),
                    Text('नाही (No)'),
                  ],
                ),
                selected: !currentVal && _answers.containsKey(q.id),
                selectedColor: AppColors.dangerRed.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: (!currentVal && _answers.containsKey(q.id)) ? AppColors.dangerRed : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  setState(() => _answers[q.id] = 'false');
                },
              ),
            ),
          ],
        );
    }
  }
}
