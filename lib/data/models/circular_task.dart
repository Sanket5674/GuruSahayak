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
  String assignedTo;
  String status; // 'Pending', 'In Progress', 'Completed'

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
    this.assignedTo = 'All Staff',
    this.status = 'Pending',
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
      'assignedTo': assignedTo,
      'status': status,
    };
  }

  factory CircularTask.fromMap(Map<String, dynamic> map) {
    final completed = map['isCompleted'] == 1 || map['isCompleted'] == true;
    return CircularTask(
      id: map['id'] ?? '',
      grNumber: map['grNumber'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      issuedBy: map['issuedBy'] ?? '',
      deadline: map['deadline'] ?? '',
      priority: map['priority'] ?? 'normal',
      checklist: (map['checklist'] as String?)?.split('|') ?? [],
      isCompleted: completed,
      proofRemarks: map['proofRemarks'],
      assignedTo: map['assignedTo'] ?? 'All Staff',
      status: map['status'] ?? (completed ? 'Completed' : 'Pending'),
    );
  }
}
