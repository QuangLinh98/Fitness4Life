class ExerciseDietSuggestions {
  final int id;
  final String dietPlan;
  final String workoutPlan;

  ExerciseDietSuggestions({
    required this.id,
    required this.dietPlan,
    required this.workoutPlan,
  });

  factory ExerciseDietSuggestions.fromJson(Map<String, dynamic> json) {
    return ExerciseDietSuggestions(
      id: json['id'],
      dietPlan: json['dietPlan'],
      workoutPlan: json['workoutPlan'],
    );
  }
}
