class Activity {
  final String name;
  final String category;

  Activity({
    required this.name, 
    required this.category
  });

  // Métodos auxiliares para converter de/para JSON (usado no banco)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      name: map['name'] ?? '',
      category: map['category'] ?? 'Geral',
    );
  }
}