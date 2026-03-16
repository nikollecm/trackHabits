class Habit {
  String name;
  bool isCompleted;

  Habit({required this.name, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {'name': name, 'isCompleted': isCompleted};
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(name: map['name'], isCompleted: map['isCompleted'] ?? false);
  }
}
