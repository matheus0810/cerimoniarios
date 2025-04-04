import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _eventos = {};
  String? uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    carregarEscalas();
  }

  Future<void> carregarEscalas() async {
    final snapshot = await FirebaseFirestore.instance.collection('escalas').get();
    final mapa = <DateTime, List<Map<String, dynamic>>>{};
    DateTime? proximaData;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dataEscala = DateTime.parse(data['data']);
      final key = DateTime(dataEscala.year, dataEscala.month, dataEscala.day);

      if (key.isAfter(DateTime.now()) && (proximaData == null || key.isBefore(proximaData))) {
        proximaData = key;
      }

      if (!mapa.containsKey(key)) {
        mapa[key] = [];
      }

      mapa[key]!.add({
        'id': doc.id,
        'horario': data['horario'],
        'local': data['local'],
        'cerimoniarios': data['cerimoniarios'],
      });
    }

    setState(() {
      _eventos = mapa;
      if (proximaData != null) {
        _selectedDay = proximaData;
        _focusedDay = proximaData;
      }
    });
  }

  List<Map<String, dynamic>> _getEventosDoDia(DateTime day) {
    return _eventos[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventosSelecionados = _selectedDay == null ? [] : _getEventosDoDia(_selectedDay!);

    return Scaffold(
      appBar: AppBar(title: Text('Calendário de Escalas')),
      body: Column(
        children: [
          TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventosDoDia,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: eventosSelecionados.length,
              itemBuilder: (context, i) {
                final evento = eventosSelecionados[i];
                return Card(
                  margin: EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('⛪ ${evento['local']} — ${evento['horario']}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Divider(),
                        ...List.from(evento['cerimoniarios']).map((c) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              tileColor: uid != null && c['uid'] == uid ? Colors.blue.shade50 : null,
                              title: Text(c['nome']),
                              subtitle: Text('Função: ${c['funcao']}'),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}