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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Fundo do cartão: Slate 700 customizado no dark mode ou Branco
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
                          // CORRIGIDO AQUI: blueGrey em vez de slate
                          color: isDark ? Colors.white : Colors.blueGrey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${routine.time} • ${routine.duration}",
                        style: TextStyle(
                          fontSize: 14,
                          // CORRIGIDO AQUI: blueGrey em vez de slate
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