enum FormFieldType {
  text,
  number,
  dropdown,
  boolean,
}

class FormQuestion {
  final String id;
  final String label;
  final FormFieldType type;
  final List<String> options;
  final bool isRequired;

  FormQuestion({
    required this.id,
    required this.label,
    required this.type,
    this.options = const [],
    this.isRequired = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'type': type.name,
      'options': options.join('|'),
      'isRequired': isRequired ? 1 : 0,
    };
  }

  factory FormQuestion.fromMap(Map<String, dynamic> map) {
    return FormQuestion(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      type: FormFieldType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FormFieldType.text,
      ),
      options: (map['options'] as String?)?.split('|') ?? [],
      isRequired: map['isRequired'] == 1 || map['isRequired'] == true,
    );
  }
}

class DynamicForm {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String deadline;
  final List<FormQuestion> questions;
  bool isSubmitted;
  Map<String, String> responses;

  DynamicForm({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.deadline,
    required this.questions,
    this.isSubmitted = false,
    this.responses = const {},
  });
}
