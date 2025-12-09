import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/agendar/botao_voltar_padrao.dart';
import '../widgets/agendar/botao_confirmar_agendar.dart';

class AgendarDescartePage extends StatefulWidget {
  const AgendarDescartePage({super.key});

  @override
  State<AgendarDescartePage> createState() => _AgendarDescartePageState();
}

class _AgendarDescartePageState extends State<AgendarDescartePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedTime = '12:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cabeçalho com gradiente
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00B894), Color(0xFF0066A2)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 16,
                        child: BotaoVoltarPadrao(
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Text(
                        'Agendar Descarte',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Selecione uma data',
                  style: TextStyle(
                    color: Color(0xFF006F7F),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                // CALENDÁRIO COM DATAS PASSADAS BLOQUEADAS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TableCalendar(
                    firstDay: DateTime.now(), // Bloqueia datas passadas
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,

                    enabledDayPredicate: (day) {
                      final hoje = DateTime.now();
                      final hojeSemHora =
                          DateTime(hoje.year, hoje.month, hoje.day);
                      return !day.isBefore(hojeSemHora);
                    },

                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),

                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;

                        // ✅ Reseta o horário ao trocar a data
                        _selectedTime = '12:00';
                      });
                    },

                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: Color(0xFF006F7F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: Color(0xFF006F7F)),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: Color(0xFF006F7F)),
                    ),

                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Color(0xFF00A4A4)),
                      weekendStyle: TextStyle(color: Color(0xFF00A4A4)),
                    ),

                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(
                        color: Color(0xFF00B894),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF0066A2),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle:
                          const TextStyle(color: Colors.black87),
                      weekendTextStyle:
                          const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Horário',
                  style: TextStyle(
                    color: Color(0xFF006F7F),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () async {
                    final now = DateTime.now();

                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: now.hour,
                        minute: now.minute,
                      ),
                    );

                    if (pickedTime != null) {
                      // Se a data for hoje, valida horário futuro
                      if (_selectedDay != null &&
                          isSameDay(_selectedDay, DateTime.now())) {
                        final horarioSelecionado = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        if (horarioSelecionado.isBefore(now)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Selecione um horário futuro.'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return; // 🔒 Bloqueia horário inválido
                        }
                      }

                      setState(() {
                        _selectedTime = pickedTime.format(context);
                      });
                    }
                  },

                  child: Container(
                    width: 120,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B894), Color(0xFF0066A2)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _selectedTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                BotaoConfirmarAgendar(
                  onPressed: () {
                    if (_selectedDay == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Por favor, selecione uma data antes de confirmar.'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final empresa = ModalRoute.of(context)!.settings.arguments
                            as Map<String, dynamic>? ??
                        {};

                    Navigator.pushNamed(
                      context,
                      '/confirmacao',
                      arguments: {
                        'id_solicitada':
                            empresa['empresa']['id_solicitada'],
                        'geminiItens':
                            empresa['empresa']['geminiItens'],
                        'empresa': empresa['empresa'],
                        'data': _selectedDay!.toString().split(' ')[0],
                        'hora': _selectedTime,
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}