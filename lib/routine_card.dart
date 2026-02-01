import 'package:flutter/material.dart';
import 'routine_model.dart'; 

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final bool isCompleted; 
  final Function(bool?) onCheckChanged; 
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.isCompleted, 
    required this.onCheckChanged,
    required this.onTap,
    required this.onDelete,
  });

  // --- NOVA FUNÇÃO MÁGICA ---
  String _formatTimeRange(String startTime, String durationStr) {
    try {
      final parts = startTime.split(':');
      if (parts.length != 2) return "$startTime • $durationStr";
      
      int startHour = int.parse(parts[0]);
      int startMin = int.parse(parts[1]);

      int durationMinutes = 0;
      final d = durationStr.toLowerCase();
      final numbers = d.split(RegExp(r'[^0-9]')).where((e) => e.isNotEmpty).map(int.parse).toList();

      if (d.contains(':')) {
        if (numbers.isNotEmpty) durationMinutes += numbers[0] * 60;
        if (numbers.length > 1) durationMinutes += numbers[1];
      } else {
        if (d.contains('h')) {
           if (numbers.isNotEmpty) durationMinutes += numbers[0] * 60;
           if (numbers.length > 1) durationMinutes += numbers[1];
        } else {
           if (numbers.isNotEmpty) durationMinutes += numbers[0];
        }
      }

      final totalMinutesInitial = (startHour * 60) + startMin;
      final totalMinutesFinal = totalMinutesInitial + durationMinutes;

      final endHour = (totalMinutesFinal ~/ 60) % 24;
      final endMin = totalMinutesFinal % 60;

      final endHourStr = endHour.toString().padLeft(2, '0');
      final endMinStr = endMin.toString().padLeft(2, '0');

      return "$startTime - $endHourStr:$endMinStr";

    } catch (e) {
      return "$startTime • $durationStr";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define cor baseada no status (Verde claro se feito)
    final cardColor = isCompleted 
        ? (isDark ? Colors.green.withOpacity(0.15) : Colors.green.withOpacity(0.1))
        : (isDark ? const Color(0xFF334155) : Colors.white);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(16), 
        border: isCompleted ? Border.all(color: Colors.green.withOpacity(0.5)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12), // Ajuste de padding para caber o checkbox
            child: Row(
              children: [
                // --- CHECKBOX (Substitui o ícone fixo) ---
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                    value: isCompleted,
                    onChanged: onCheckChanged,
                    activeColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(
                      color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      width: 1.5
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Informações da Rotina
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.activity.name, 
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.blueGrey[900],
                          // Risco se estiver completo
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeRange(routine.time, routine.duration),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.blueGrey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Botão de Deletar
                IconButton(
                  icon: Icon(Icons.delete_outline, color: isCompleted ? Colors.green[700] : Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}