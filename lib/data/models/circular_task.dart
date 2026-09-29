class CircularTask {
  final String id;
  final String grNumber;
  final String title;
  final String summary;
  final String issuedBy;
  final String deadline;
  final String priority; // 'urgent', 'high', 'normal'
  final List<String> checklist;
  bool isCompleted;
  String? proofRemarks;

  CircularTask({
    required this.id,
    required this.grNumber,
    required this.title,
    required this.summary,
    required this.issuedBy,
    required this.deadline,
    this.priority = 'normal',
    required this.checklist,
    this.isCompleted = false,
    this.proofRemarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grNumber': grNumber,
      'title': title,
      'summary': summary,
      'issuedBy': issuedBy,
      'deadline': deadline,
      'priority': priority,
      'checklist': checklist.join('|'),
      'isCompleted': isCompleted ? 1 : 0,
      'proofRemarks': proofRemarks ?? '',
    };
  }

  factory CircularTask.fromMap(Map<String, dynamic> map) {
    return CircularTask(
      id: map['id'] ?? '',
      grNumber: map['grNumber'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      issuedBy: map['issuedBy'] ?? '',
      deadline: map['deadline'] ?? '',
      priority: map['priority'] ?? 'normal',
      checklist: (map['checklist'] as String?)?.split('|') ?? [],
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
      proofRemarks: map['proofRemarks'],
    );
  }
}
