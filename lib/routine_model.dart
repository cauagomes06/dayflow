import 'activity_model.dart';

class Routine {
  final int? id;
  final Activity activity;
  final String days;
  final String time;
  final String duration;
  final String? notes;

  Routine({
    this.id,
    required this.activity,
    required this.days,
    required this.time,
    required this.duration,
    this.notes,
  });

  // Salva no banco "achatando" os dados (Activity vira colunas aqui)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_name': activity.name,
      'activity_category': activity.category,
      'days': days,
      'time': time,
      'duration': duration,
      'notes': notes,
    };
  }

  // Reconstrói a Atividade ao ler do banco
  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      activity: Activity(
        name: map['activity_name'],
        category: map['activity_category'],
      ),
      days: map['days'],
      time: map['time'],
      duration: map['duration'],
      notes: map['notes'],
    );
  }
}