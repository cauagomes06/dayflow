import 'package:flutter/material.dart';
import 'routine_model.dart'; 

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.onDelete,
  });

  // --- NOVA FUNÇÃO MÁGICA ---
  String _formatTimeRange(String startTime, String durationStr) {
    try {
      // 1. Ler a Hora Inicial (ex: "14:30")
      final parts = startTime.split(':');
      if (parts.length != 2) return "$startTime • $durationStr";
      
      int startHour = int.parse(parts[0]);
      int startMin = int.parse(parts[1]);

      // 2. Ler a Duração (ex: "1h 30 min" ou "45 min")
      int durationMinutes = 0;
      final d = durationStr.toLowerCase();
      
      // Regex simples para pegar números
      final numbers = d.split(RegExp(r'[^0-9]')).where((e) => e.isNotEmpty).map(int.parse).toList();

      if (d.contains(':')) {
        // Se o usuário digitou "01:30" na duração
        if (numbers.isNotEmpty) durationMinutes += numbers[0] * 60;
        if (numbers.length > 1) durationMinutes += numbers[1];
      } else {
        // Formato texto "1h 30min"
        if (d.contains('h')) {
           if (numbers.isNotEmpty) durationMinutes += numbers[0] * 60;
           if (numbers.length > 1) durationMinutes += numbers[1]; // minutos depois do h
        } else {
           // Só minutos (ex: "30 min")
           if (numbers.isNotEmpty) durationMinutes += numbers[0];
        }
      }

      // 3. Somar e Calcular Hora Final
      final totalMinutesInitial = (startHour * 60) + startMin;
      final totalMinutesFinal = totalMinutesInitial + durationMinutes;

      final endHour = (totalMinutesFinal ~/ 60) % 24; // % 24 para virar 00 se passar de 23h
      final endMin = totalMinutesFinal % 60;

      final endHourStr = endHour.toString().padLeft(2, '0');
      final endMinStr = endMin.toString().padLeft(2, '0');

      // Retorna bonitinho: "14:00 - 15:30"
      return "$startTime - $endHourStr:$endMinStr";

    } catch (e) {
      // Se der qualquer erro na conta, mostra o antigo por segurança
      return "$startTime • $durationStr";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white, 
        borderRadius: BorderRadius.circular(16), 
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
            padding: const EdgeInsets.all(16), 
            child: Row(
              children: [
                // Ícone Indicador
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule_rounded, 
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 16),
                
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      // AQUI ESTÁ A MUDANÇA NO TEXTO
                      Text(
                        _formatTimeRange(routine.time, routine.duration),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500, // Um pouco mais forte para destaque
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
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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