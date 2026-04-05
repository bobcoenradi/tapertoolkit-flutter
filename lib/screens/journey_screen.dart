import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/journal_entry_model.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, JournalEntry> _entryMap = {};
  List<Appointment> _appointments = [];
  List<MedReminder> _meds = [];
  bool _loading = true;

  final _journalCtrl = TextEditingController();
  String _mood = 'neutral';

  static const _moodColors = {
    'radiant': AppColors.success,
    'steady': Color(0xFF7BC67E),
    'neutral': AppColors.warning,
    'uneasy': AppColors.danger,
    'heavy': Color(0xFF9E9E9E),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _journalCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final entries = await FirestoreService.fetchJournalEntries();
    final appts = await FirestoreService.fetchUpcomingAppointments();
    final meds = await FirestoreService.fetchMedReminders();
    if (!mounted) return;
    setState(() {
      _entryMap = {for (final e in entries) e.dateKey: e};
      _appointments = appts;
      _meds = meds;
      _loading = false;
    });
    _loadEntryForDay(_selectedDay);
  }

  Future<void> _loadEntryForDay(DateTime day) async {
    final entry = await FirestoreService.fetchEntryForDate(day);
    if (!mounted) return;
    if (entry != null) {
      _journalCtrl.text = entry.text ?? '';
      setState(() => _mood = entry.mood);
    } else {
      _journalCtrl.clear();
      setState(() => _mood = 'neutral');
    }
  }

  Future<void> _saveEntry() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final key = _dateKey(_selectedDay);
    final entry = JournalEntry(
      id: key,
      uid: uid,
      date: _selectedDay,
      mood: _mood,
      text: _journalCtrl.text.trim().isEmpty ? null : _journalCtrl.text.trim(),
    );
    await FirestoreService.saveJournalEntry(entry);
    setState(() => _entryMap[key] = entry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry saved'), backgroundColor: AppColors.primary),
      );
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Color? _dotColorFor(DateTime day) {
    final entry = _entryMap[_dateKey(day)];
    if (entry == null) return null;
    return _moodColors[entry.mood] ?? AppColors.textLight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildCalendar()),
            SliverToBoxAdapter(child: _buildJournalSection()),
            SliverToBoxAdapter(child: _buildAppointments()),
            SliverToBoxAdapter(child: _buildMeds()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Journey', style: AppTextStyles.h4(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(DateFormat('MMMM yyyy').format(_focusedDay).toUpperCase(),
                    style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 1)),
                Text('Your Taper Progress', style: AppTextStyles.h2()),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.textDark)),
          CircleAvatar(radius: 18, backgroundColor: AppColors.primarySoft, child: const Icon(Icons.person_outline, color: AppColors.primary, size: 18)),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: AppDecorations.card(),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
          _loadEntryForDay(selected);
        },
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          titleTextStyle: AppTextStyles.h4(),
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textDark),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textDark),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.caption(color: AppColors.textLight),
          weekendStyle: AppTextStyles.caption(color: AppColors.textLight),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppTextStyles.label(color: AppColors.primary),
          defaultTextStyle: AppTextStyles.body(color: AppColors.textDark),
          weekendTextStyle: AppTextStyles.body(color: AppColors.textDark),
          outsideTextStyle: AppTextStyles.body(color: AppColors.textLight),
          markerDecoration: const BoxDecoration(),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            final color = _dotColorFor(day);
            if (color == null) return null;
            return Positioned(
              bottom: 4,
              child: Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJournalSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journal Entry for Today', style: AppTextStyles.h4()),
          const SizedBox(height: 12),
          Container(
            decoration: AppDecorations.card(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _journalCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'How are you feeling today? Any shifts in mood or physical symptoms?',
                    hintStyle: AppTextStyles.body(color: AppColors.textLight),
                    border: InputBorder.none,
                  ),
                  style: AppTextStyles.body(color: AppColors.textDark),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text('Save Entry', style: AppTextStyles.label(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointments() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: AppDecorations.card(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.textDark),
                const SizedBox(width: 8),
                Text('Upcoming Appointments', style: AppTextStyles.h4()),
              ],
            ),
            const SizedBox(height: 12),
            if (_appointments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No upcoming appointments', style: AppTextStyles.body()),
              )
            else
              ..._appointments.take(3).map((a) => _AppointmentTile(appointment: a)),
            TextButton(
              onPressed: () => _showAddAppointmentSheet(),
              child: Text('Add Appointment', style: AppTextStyles.label(color: AppColors.textMid)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeds() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: AppDecorations.card(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.local_pharmacy_outlined, size: 18, color: AppColors.textDark),
                const SizedBox(width: 8),
                Text('Meds to Order', style: AppTextStyles.h4()),
              ],
            ),
            const SizedBox(height: 12),
            if (_meds.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No medications tracked yet', style: AppTextStyles.body()),
              )
            else
              ..._meds.map((m) => _MedTile(med: m, onToggle: (ordered) async {
                final updated = MedReminder(id: m.id, uid: m.uid, name: m.name, dosage: m.dosage, ordered: ordered, refillNeededBy: m.refillNeededBy, status: ordered ? 'ordered' : 'needed');
                await FirestoreService.saveMedReminder(updated);
                _loadData();
              })),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                label: Text('Order Prescriptions', style: AppTextStyles.label(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAppointmentSheet() {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Appointment', style: AppTextStyles.h3()),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title (e.g. Dr. Smith)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            TextField(controller: subtitleCtrl, decoration: InputDecoration(labelText: 'Type (e.g. Taper Review)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final appt = Appointment(id: '', uid: '', title: titleCtrl.text, subtitle: subtitleCtrl.text.isEmpty ? null : subtitleCtrl.text, dateTime: selectedDate);
                  await FirestoreService.saveAppointment(appt);
                  Navigator.of(ctx).pop();
                  _loadData();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Save', style: AppTextStyles.label(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMM').format(appointment.dateTime).toUpperCase();
    final day = appointment.dateTime.day;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Text(month, style: AppTextStyles.caption(color: AppColors.primary).copyWith(letterSpacing: 0.5)),
                Text('$day', style: AppTextStyles.h4(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.title, style: AppTextStyles.label(color: AppColors.textDark)),
                if (appointment.subtitle != null)
                  Text(
                    '${appointment.subtitle} • ${DateFormat('h:mm a').format(appointment.dateTime)}',
                    style: AppTextStyles.bodySmall(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedTile extends StatelessWidget {
  final MedReminder med;
  final ValueChanged<bool> onToggle;
  const _MedTile({required this.med, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onToggle(!med.ordered),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
                color: med.ordered ? AppColors.primary : Colors.transparent,
                border: Border.all(color: med.ordered ? AppColors.primary : AppColors.textLight, width: 1.5),
              ),
              child: med.ordered ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${med.name}${med.dosage != null ? ' ${med.dosage}' : ''}',
                    style: AppTextStyles.label(color: AppColors.textDark)),
                if (med.status != null)
                  Text(med.status!.toUpperCase(), style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 0.8)),
              ],
            ),
          ),
          if (!med.ordered)
            const Icon(Icons.priority_high, color: AppColors.danger, size: 18),
        ],
      ),
    );
  }
}
