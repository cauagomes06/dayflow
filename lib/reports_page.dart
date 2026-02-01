import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'drawer.dart';
import 'theme_controller.dart';
import 'db_helper.dart';
import 'routine_model.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late DateTime currentWeekStart;
  bool isLoading = true;

  // Estatísticas
  int plannedCount = 0;
  int doneCount = 0; // Concluído "no tempo certo"
  int notDoneCount = 0;
  int partialCount = 0; // Concluído com desvio de tempo
  
  double plannedHours = 0;
  double doneHours = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
    _loadData();
  }

  void _changeWeek(int days) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: days));
      isLoading = true;
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final routines = await DatabaseHelper.instance.readAllRoutines();
      final exceptionsRaw = await DatabaseHelper.instance.getExceptions();
      final completionsRaw = await DatabaseHelper.instance.getCompletions();

      // Sets e Maps para busca rápida
      final exceptionSet = exceptionsRaw.map((e) => "${e['routine_id']}|${e['date']}").toSet();
      
      // Map para pegar o horário exato da conclusão: "ID|DATA" -> "2026-02-01T14:30:00"
      final completionMap = {
        for (var e in completionsRaw) "${e['routine_id']}|${e['date']}": e['completed_at'] as String
      };

      // Zera contadores
      int pCount = 0;
      int dCount = 0;
      int partCount = 0;
      double pHours = 0;
      double dHours = 0;

      // Itera os 7 dias da semana
      for (int i = 0; i < 7; i++) {
        final date = currentWeekStart.add(Duration(days: i));
        final dateStr = _formatDateDb(date);
        final weekDayAbbr = _getWeekDayAbbr(date.weekday);

        for (var r in routines) {
          if (r.days.contains(weekDayAbbr)) {
            final key = "${r.id}|$dateStr";

            // Se for exceção, ignora
            if (exceptionSet.contains(key)) continue;

            // É planejado
            pCount++;
            final durationInHours = _parseDuration(r.duration);
            pHours += durationInHours;

            // Verificando Conclusão
            if (completionMap.containsKey(key)) {
              dHours += durationInHours;

              // --- LÓGICA DE PARCIAL / DESVIO DE TEMPO ---
              final completedAtStr = completionMap[key]!;
              final completedAt = DateTime.parse(completedAtStr);

              // Calcula quando deveria terminar (Dia Atual + Hora Inicio + Duração)
              final plannedEndTime = _calculatePlannedEndTime(date, r.time, r.duration);
              
              if (plannedEndTime != null) {
                // Diferença em minutos entre o Real e o Planejado
                final diffMinutes = completedAt.difference(plannedEndTime).inMinutes;

                // CRITÉRIO: Se o desvio for maior que 30 minutos (para mais ou menos)
                // "Excede o tempo ou muito menos tempo"
                if (diffMinutes.abs() > 30) {
                  partCount++; // Conta como Parcial
                } else {
                  dCount++; // Conta como Concluído (Sucesso)
                }
              } else {
                // Se der erro no calculo, assume concluído normal
                dCount++;
              }

            }
          }
        }
      }

      setState(() {
        plannedCount = pCount;
        doneCount = dCount;
        partialCount = partCount;
        notDoneCount = pCount - (dCount + partCount); // O que sobra é não realizado
        plannedHours = pHours;
        doneHours = dHours;
        isLoading = false;
      });

    } catch (e) {
      print("Erro ao carregar relatório: $e");
      setState(() => isLoading = false);
    }
  }

  // --- MATEMÁTICA DE DATAS ---
  
  // Retorna a Data/Hora que a tarefa deveria acabar neste dia específico
  DateTime? _calculatePlannedEndTime(DateTime date, String startTime, String durationStr) {
    try {
      // 1. Hora de Inicio
      final timeParts = startTime.split(':');
      final startHour = int.parse(timeParts[0]);
      final startMin = int.parse(timeParts[1]);

      // 2. Duração em minutos
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

      // Cria a data base (Dia do loop às 00:00)
      final baseDate = DateTime(date.year, date.month, date.day, startHour, startMin);
      
      // Soma a duração
      return baseDate.add(Duration(minutes: durationMinutes));
    } catch (e) {
      return null;
    }
  }

  String _formatDateDb(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";
  }

  String _getWeekDayAbbr(int weekday) {
    switch (weekday) {
      case 1: return 'Seg';
      case 2: return 'Ter';
      case 3: return 'Qua';
      case 4: return 'Qui';
      case 5: return 'Sex';
      case 6: return 'Sab';
      case 7: return 'Dom';
      default: return '';
    }
  }

  double _parseDuration(String durationStr) {
    try {
      double total = 0;
      String s = durationStr.toLowerCase().replaceAll(':', ' '); 
      final parts = s.split(RegExp(r'[^0-9]'));
      final numbers = parts.where((e) => e.isNotEmpty).map(int.parse).toList();

      if (durationStr.contains(':')) {
        if (numbers.isNotEmpty) total += numbers[0];
        if (numbers.length > 1) total += numbers[1] / 60.0;
      } else {
        if (durationStr.contains('h')) {
             if (numbers.isNotEmpty) total += numbers[0];
             if (numbers.length > 1) total += numbers[1] / 60.0;
        } else if (durationStr.contains('min')) {
             if (numbers.isNotEmpty) total += numbers[0] / 60.0;
        } else {
             if (numbers.isNotEmpty) total += numbers[0] / 60.0;
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF111827) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

    const plannedColor = Color(0xFF90A4AE);
    const doneColor = Color(0xFF00BFA5);
    const notDoneColor = Color(0xFFEF5350);
    const partialColor = Color(0xFFFFA000); // Laranja para Parcial

    final appBarBg = isDark ? const Color(0xFF0B1220) : const Color(0xFF1E3A8A);

    final startStr = DateFormat('dd/MM').format(currentWeekStart);
    final endStr = DateFormat('dd/MM').format(currentWeekStart.add(const Duration(days: 6)));
    final diffHours = (doneHours - plannedHours).toStringAsFixed(1);
    final diffLabel = (doneHours - plannedHours) >= 0 ? "+$diffHours" : diffHours;

    // Insight calculation
    final totalDone = doneCount + partialCount; // Soma os dois tipos de feito
    final percent = plannedCount > 0 ? (totalDone / plannedCount * 100).toInt() : 0;
    
    String insightText = "Você cumpriu $percent%\ndo planejado.";
    if (partialCount > doneCount) insightText = "Muitos horários\ndesviados.";
    else if (percent > 90) insightText = "Excelente semana!\nQuase 100%!";

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: const Text(
          'Relatório',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined, color: Colors.white),
            onPressed: () => ThemeController.instance.toggleTheme(),
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? const Color(0xFF0EA5E9).withOpacity(0.35) : Colors.transparent,
          ),
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          children: [
            // ====== SELETOR DE SEMANA ======
            _WeekSelector(
              isDark: isDark,
              cardBg: cardBg,
              borderColor: cardBorder,
              textColor: textPrimary,
              iconColor: textSecondary,
              label: "Semana $startStr - $endStr",
              onPrev: () => _changeWeek(-7),
              onNext: () => _changeWeek(7),
            ),

            const SizedBox(height: 18),

            // ====== RESUMO DA SEMANA ======
            _SummaryCard(
              isDark: isDark,
              bg: cardBg,
              border: cardBorder,
              titleColor: textPrimary,
              textColor: textPrimary,
              subtleText: textSecondary,
              plannedH: "${plannedHours.toStringAsFixed(1)}h",
              doneH: "${doneHours.toStringAsFixed(1)}h",
              diffH: "${diffLabel}h",
            ),

            const SizedBox(height: 18),

            // ====== 4 CARDS 2x2 ======
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    title: "Planejados",
                    quantity: plannedCount,
                    borderColor: plannedColor,
                    bg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    title: "Concluídos", // Concluído certinho
                    quantity: doneCount,
                    borderColor: doneColor,
                    bg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    title: "Pendentes", // Não checados
                    quantity: notDoneCount,
                    borderColor: notDoneColor,
                    bg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // AGORA MOSTRA OS PARCIAIS REAIS
                  child: _MiniStatCard(
                    title: "Parcial", // Concluído com desvio > 30min
                    quantity: partialCount,
                    borderColor: partialColor,
                    bg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ====== GRÁFICO SEMANAL ======
            _WeeklyChart(
              isDark: isDark,
              bg: cardBg,
              border: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              plannedHours: plannedHours,
              doneHours: doneHours,
            ),

            const SizedBox(height: 16),

            // ====== INSIGHTS ======
            Row(
              children: [
                Expanded(
                  child: _InsightCard(
                    isDark: isDark,
                    bg: cardBg,
                    border: cardBorder,
                    textColor: textPrimary,
                    iconColor: const Color(0xFFFBBF24),
                    text: insightText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightCard(
                    isDark: isDark,
                    bg: cardBg,
                    border: cardBorder,
                    textColor: textPrimary,
                    iconColor: const Color(0xFFFBBF24),
                    text: "Mantenha o\nritmo constante!",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ... WIDGETS AUXILIARES (Pode manter os mesmos de antes: _WeekSelector, _SummaryCard, etc.) ...
// Como são os mesmos que enviei antes, não precisa colar de novo se já tiver, 
// mas para garantir, vou colar apenas os widgets abaixo para o arquivo ficar completo:

class _WeekSelector extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _WeekSelector({
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          splashRadius: 18,
          onPressed: onPrev,
          icon: Icon(Icons.chevron_left, color: iconColor),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          splashRadius: 18,
          onPressed: onNext,
          icon: Icon(Icons.chevron_right, color: iconColor),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final bool isDark;
  final Color bg;
  final Color border;
  final Color titleColor;
  final Color textColor;
  final Color subtleText;
  final String plannedH;
  final String doneH;
  final String diffH;

  const _SummaryCard({
    required this.isDark,
    required this.bg,
    required this.border,
    required this.titleColor,
    required this.textColor,
    required this.subtleText,
    required this.plannedH,
    required this.doneH,
    required this.diffH,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Resumo da Semana",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: subtleText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Planejado: $plannedH",
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Realizado: $doneH",
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Desvio: $diffH",
                  style: TextStyle(
                    color: diffH.startsWith('-') ? Colors.redAccent : Colors.green, 
                    fontSize: 13
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final int quantity;
  final Color borderColor;
  final Color bg;
  final Color textPrimary;
  final Color textSecondary;

  const _MiniStatCard({
    required this.title,
    required this.quantity,
    required this.borderColor,
    required this.bg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            "Quantidade: $quantity",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final bool isDark;
  final Color bg;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final double plannedHours;
  final double doneHours;

  const _WeeklyChart({
    required this.isDark,
    required this.bg,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.plannedHours,
    required this.doneHours,
  });

  @override
  Widget build(BuildContext context) {
    final ph = plannedHours;
    final dh = doneHours;
    
    // Evita divisão por zero
    double plannedPct = 1.0;
    double donePct = 0.0;

    if (ph > 0) {
      donePct = (dh / ph).clamp(0.0, 1.0);
    } else if (dh > 0) {
      donePct = 1.0; 
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            "Gráfico Semanal",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          _ChartRow(
            label: "Planejado",
            rightText: "${ph.toStringAsFixed(1)}h",
            fillPercent: plannedPct,
            fillColor: const Color(0xFF1D4ED8), 
            trackColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFE5E7EB),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 10),

          _ChartRow(
            label: "Realizado",
            rightText: "${dh.toStringAsFixed(1)}h",
            fillPercent: donePct,
            fillColor: const Color(0xFF22C55E), 
            trackColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFE5E7EB),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ChartRow extends StatelessWidget {
  final String label;
  final String rightText;
  final double fillPercent;
  final Color fillColor;
  final Color trackColor;
  final Color textPrimary;
  final Color textSecondary;

  const _ChartRow({
    required this.label,
    required this.rightText,
    required this.fillPercent,
    required this.fillColor,
    required this.trackColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 8,
              color: trackColor,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fillPercent,
                  child: Container(color: fillColor),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            rightText,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final bool isDark;
  final Color bg;
  final Color border;
  final Color textColor;
  final Color iconColor;
  final String text;

  const _InsightCard({
    required this.isDark,
    required this.bg,
    required this.border,
    required this.textColor,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                height: 1.15,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}