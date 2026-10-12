class ProfileCompletionModel {
  final int percentage;
  final int completed;
  final int total;
  final List<String> completedFields;
  final List<String> remainingFields;

  const ProfileCompletionModel({
    this.percentage = 0,
    this.completed = 0,
    this.total = 0,
    this.completedFields = const [],
    this.remainingFields = const [],
  });

  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionModel(
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      completedFields: (json['completedFields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      remainingFields: (json['remainingFields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'completed': completed,
      'total': total,
      'completedFields': completedFields,
      'remainingFields': remainingFields,
    };
  }
}
