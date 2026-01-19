import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Create Booking (Mobile) - Corporate UI
/// - White background, subtle borders, soft shadows, rounded cards
/// - Poppins typography via GoogleFonts
/// - FontAwesome icons with contextual colors
///
/// Replace the stub methods:
/// - _fetchRooms()
/// - _searchInternalAttendees()
/// - _submitBooking()
class CreateBookingPage extends StatefulWidget {
  const CreateBookingPage({super.key});

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _attendeeCountCtrl = TextEditingController(text: '0');
  final _descriptionCtrl = TextEditingController();
  final _internalSearchCtrl = TextEditingController();

  // Data
  List<Room> _rooms = const [];
  Room? _selectedRoom;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);

  bool _isRecurring = false;

  // Attendees
  final List<Attendee> _selectedAttendees = [];
  List<Attendee> _internalSuggestions = const [];

  bool _loadingRooms = true;
  bool _searchingInternal = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _attendeeCountCtrl.dispose();
    _descriptionCtrl.dispose();
    _internalSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _loadingRooms = true);
    final rooms = await _fetchRooms();
    setState(() {
      _rooms = rooms;
      _loadingRooms = false;
    });
  }

  // ---------------------------
  // STUBS: Replace with your API
  // ---------------------------
  Future<List<Room>> _fetchRooms() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      Room(id: 'R1', name: 'Conference Room - 1', capacity: 8),
      Room(id: 'R2', name: 'Conference Room - 2', capacity: 12),
      Room(id: 'R3', name: 'Board Room', capacity: 20),
      Room(id: 'R4', name: 'Huddle Space', capacity: 4),
    ];
  }

  Future<List<Attendee>> _searchInternalAttendees(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    const directory = [
      Attendee.internal(name: 'Aayushman Gupta', email: 'aayushman@company.com'),
      Attendee.internal(name: 'Manoj Bilapati', email: 'manoj@company.com'),
      Attendee.internal(name: 'Kavita Sharma', email: 'kavita@company.com'),
      Attendee.internal(name: 'Rohan Patil', email: 'rohan@company.com'),
      Attendee.internal(name: 'Pranav Mehta', email: 'pranav@company.com'),
      Attendee.internal(name: 'Mukta Patel', email: 'mukta@company.com'),
    ];

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return directory
        .where((a) =>
            a.name.toLowerCase().contains(q) ||
            (a.email ?? '').toLowerCase().contains(q))
        .take(8)
        .toList(growable: false);
  }

  Future<void> _submitBooking(CreateBookingRequest req) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  // ---------------------------
  // Helpers
  // ---------------------------
  DateTime _combine(DateTime date, TimeOfDay tod) =>
      DateTime(date.year, date.month, date.day, tod.hour, tod.minute);

  Duration get _duration {
    final start = _combine(_selectedDate, _startTime);
    final end = _combine(_selectedDate, _endTime);
    if (end.isBefore(start)) {
      // Optional behavior: end time next day if earlier than start
      return end.add(const Duration(days: 1)).difference(start);
    }
    return end.difference(start);
  }

  String get _durationLabel {
    final d = _duration;
    if (d.inMinutes <= 0) return '-';
    final hours = d.inHours;
    final mins = d.inMinutes.remainder(60);
    if (mins == 0) return hours == 1 ? '1 hour' : '$hours hours';
    if (hours == 0) return '$mins min';
    final hLabel = hours == 1 ? '1 hour' : '$hours hours';
    return '$hLabel $mins min';
  }

  String _ddMMyyyy(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd-$mm-${d.year}';
  }

  void _syncAttendeeCount() {
    _attendeeCountCtrl.text = _selectedAttendees.length.toString();
  }

  void _addAttendee(Attendee a) {
    final exists = _selectedAttendees.any((x) =>
        x.type == a.type &&
        x.name.toLowerCase() == a.name.toLowerCase() &&
        (x.email ?? '').toLowerCase() == (a.email ?? '').toLowerCase());
    if (exists) return;

    setState(() {
      _selectedAttendees.add(a);
      _syncAttendeeCount();
      _internalSuggestions = const [];
    });
  }

  void _removeAttendee(Attendee a) {
    setState(() {
      _selectedAttendees.remove(a);
      _syncAttendeeCount();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _startTime);
    if (picked == null) return;

    setState(() {
      _startTime = picked;

      final start = _combine(_selectedDate, _startTime);
      final end = _combine(_selectedDate, _endTime);
      if (!end.isAfter(start)) {
        final newEnd = start.add(const Duration(hours: 1));
        _endTime = TimeOfDay(hour: newEnd.hour, minute: newEnd.minute);
      }
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime);
    if (picked == null) return;
    setState(() => _endTime = picked);
  }

  Future<void> _runInternalSearch(String query) async {
    setState(() => _searchingInternal = true);
    final result = await _searchInternalAttendees(query);
    if (!mounted) return;
    setState(() {
      _internalSuggestions = result;
      _searchingInternal = false;
    });
  }

  Future<void> _openRoomPicker() async {
    if (_rooms.isEmpty) return;

    final selected = await showModalBottomSheet<Room>(
      context: context,
      showDragHandle: true,
      backgroundColor: DS.background,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DS.xl, DS.m, DS.xl, DS.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Select a room', style: DS.text.cardTitle),
                const SizedBox(height: DS.m),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _rooms.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: DS.border),
                    itemBuilder: (context, i) {
                      final r = _rooms[i];
                      final isSel = _selectedRoom?.id == r.id;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: FaIcon(
                          FontAwesomeIcons.doorOpen,
                          size: 14,
                          color: DS.primary,
                        ),
                        title: Text(
                          r.name,
                          style: DS.text.primary.copyWith(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Capacity: ${r.capacity}',
                          style: DS.text.secondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSel
                            ? FaIcon(FontAwesomeIcons.circleCheck,
                                size: 16, color: DS.success)
                            : FaIcon(FontAwesomeIcons.chevronRight,
                                size: 14, color: DS.textSecondary),
                        onTap: () => Navigator.of(context).pop(r),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) setState(() => _selectedRoom = selected);
  }

  Future<void> _openAddExternalAttendeeSheet() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    final added = await showModalBottomSheet<Attendee>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: DS.background,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(DS.xl, DS.m, DS.xl, bottomInset + DS.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add External Attendee', style: DS.text.cardTitle),
              const SizedBox(height: DS.l),
              TextField(
                controller: nameCtrl,
                style: DS.text.primary,
                decoration: DS.input(
                  label: 'Name *',
                  hint: 'Enter attendee name',
                  prefixIcon: FaIcon(FontAwesomeIcons.user, size: 14, color: DS.primary),
                ),
              ),
              const SizedBox(height: DS.m),
              TextField(
                controller: emailCtrl,
                style: DS.text.primary,
                keyboardType: TextInputType.emailAddress,
                decoration: DS.input(
                  label: 'Email (optional)',
                  hint: 'Enter email',
                  prefixIcon: FaIcon(FontAwesomeIcons.envelope, size: 14, color: DS.primary),
                ),
              ),
              const SizedBox(height: DS.l),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name is required.')),
                      );
                      return;
                    }
                    Navigator.of(context).pop(
                      Attendee.external(name: name, email: email.isEmpty ? null : email),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.userPlus, size: 14),
                  label: Text('Add', style: DS.text.primary.copyWith(color: Colors.white)),
                  style: DS.primaryButton,
                ),
              ),
            ],
          ),
        );
      },
    );

    nameCtrl.dispose();
    emailCtrl.dispose();

    if (added != null) _addAttendee(added);
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a room.')),
      );
      return;
    }

    final req = CreateBookingRequest(
      meetingTitle: _titleCtrl.text.trim(),
      roomId: _selectedRoom!.id,
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      isRecurring: _isRecurring,
      numberOfAttendees: int.tryParse(_attendeeCountCtrl.text.trim()) ?? 0,
      attendees: List<Attendee>.from(_selectedAttendees),
      description: _descriptionCtrl.text.trim(),
    );

    setState(() => _submitting = true);
    try {
      await _submitBooking(req);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully.')),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create booking: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Page-scoped theme enforcing Poppins + your palette (no pure black)
    final pageTheme = Theme.of(context).copyWith(
      scaffoldBackgroundColor: DS.background,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: DS.textPrimary,
        displayColor: DS.textPrimary,
      ),
      dividerColor: DS.border,
      inputDecorationTheme: const InputDecorationTheme(),
    );

    return Theme(
      data: pageTheme,
      child: Scaffold(
        appBar: AppBar(
        elevation: 1,
        backgroundColor: const Color.fromARGB(255, 24, 0, 112),
        // ignore: deprecated_member_use
        shadowColor: Colors.black.withOpacity(0.05),
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Create New Booking',
                  style: GoogleFonts.poppins(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
                ),
                const SizedBox(width: 8),
                Icon(
                  FontAwesomeIcons.circlePlus,
                  size: 20,
                  color: Colors.blue.shade400,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Book a conference room for your meeting',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w300
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
 
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DS.xl, DS.m, DS.xl, DS.l),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submitting ? null : _onSubmit,
                style: DS.primaryButton,
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Create Booking',
                        style: DS.text.primary.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        body: _loadingRooms
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(DS.xl, DS.m, DS.xl, 96),
                    children: [
                      const SizedBox(height: DS.xl),

                      // Booking Details
                      DSCard(
                        title: 'Booking Details',
                        icon: FaIcon(FontAwesomeIcons.clipboardList, size: 14, color: DS.primary),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleCtrl,
                              style: DS.text.primary,
                              decoration: DS.input(
                                label: 'Meeting Title *',
                                hint: 'e.g., Weekly Team Meeting',
                                prefixIcon: FaIcon(FontAwesomeIcons.penToSquare, size: 14, color: DS.primary),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Meeting title is required.'
                                  : null,
                            ),
                            const SizedBox(height: DS.l),

                            _TapField(
                              label: 'Room *',
                              value: _selectedRoom == null
                                  ? 'Select a room...'
                                  : '${_selectedRoom!.name} • ${_selectedRoom!.capacity}',
                              prefixIcon: FaIcon(FontAwesomeIcons.doorOpen, size: 14, color: DS.primary),
                              onTap: _openRoomPicker,
                            ),
                            const SizedBox(height: DS.l),

                            Row(
                              children: [
                                Expanded(
                                  child: _TapField(
                                    label: 'Date *',
                                    value: _ddMMyyyy(_selectedDate),
                                    prefixIcon: FaIcon(FontAwesomeIcons.calendarDays, size: 14, color: DS.primary),
                                    onTap: _pickDate,
                                  ),
                                ),
                                const SizedBox(width: DS.m),
                                Expanded(
                                  child: TextFormField(
                                    controller: _attendeeCountCtrl,
                                    style: DS.text.primary,
                                    keyboardType: TextInputType.number,
                                    decoration: DS.input(
                                      label: 'Attendees *',
                                      hint: '0',
                                      prefixIcon: FaIcon(FontAwesomeIcons.users, size: 14, color: DS.success),
                                    ),
                                    validator: (v) {
                                      final n = int.tryParse((v ?? '').trim());
                                      if (n == null || n < 0) return 'Invalid number';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DS.l),

                            Row(
                              children: [
                                Expanded(
                                  child: _TapField(
                                    label: 'Start Time *',
                                    value: _startTime.format(context),
                                    prefixIcon: FaIcon(FontAwesomeIcons.clock, size: 14, color: DS.primary),
                                    onTap: _pickStartTime,
                                  ),
                                ),
                                const SizedBox(width: DS.m),
                                Expanded(
                                  child: _TapField(
                                    label: 'End Time *',
                                    value: _endTime.format(context),
                                    prefixIcon: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 14, color: DS.primary),
                                    onTap: _pickEndTime,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DS.m),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: DS.m, vertical: DS.s),
                                decoration: BoxDecoration(
                                  color: DS.primaryLight,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: DS.border),
                                ),
                                child: Text(
                                  'Duration: $_durationLabel',
                                  style: DS.text.secondary.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: DS.xl),

                      // Attendees
                      DSCard(
                        title: 'Attendees',
                        icon: FaIcon(FontAwesomeIcons.peopleGroup, size: 14, color: DS.success),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Internal (Microsoft 365)', style: DS.text.cardTitle),
                            const SizedBox(height: DS.m),

                            TextField(
                              controller: _internalSearchCtrl,
                              style: DS.text.primary,
                              decoration: DS.input(
                                label: 'Search',
                                hint: 'Search by name or email...',
                                prefixIcon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 14, color: DS.primary),
                                suffixIcon: _searchingInternal
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      )
                                    : IconButton(
                                        icon: const FaIcon(FontAwesomeIcons.arrowRight, size: 14, color: DS.primary),
                                        onPressed: () => _runInternalSearch(_internalSearchCtrl.text),
                                      ),
                              ),
                              onChanged: (v) => _runInternalSearch(v),
                            ),

                            if (_internalSuggestions.isNotEmpty) ...[
                              const SizedBox(height: DS.m),
                              Container(
                                decoration: BoxDecoration(
                                  color: DS.background,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: DS.border),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _internalSuggestions.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1, color: DS.border),
                                  itemBuilder: (context, i) {
                                    final a = _internalSuggestions[i];
                                    return ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: DS.m, vertical: DS.xs),
                                      leading: const FaIcon(FontAwesomeIcons.user, size: 14, color: DS.primary),
                                      title: Text(a.name, style: DS.text.primary, overflow: TextOverflow.ellipsis),
                                      subtitle: a.email == null
                                          ? null
                                          : Text(a.email!, style: DS.text.secondary, overflow: TextOverflow.ellipsis),
                                      trailing: const FaIcon(FontAwesomeIcons.circlePlus, size: 16, color: DS.success),
                                      onTap: () {
                                        _addAttendee(a);
                                        _internalSearchCtrl.clear();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: DS.l),

                            Row(
                              children: [
                                Expanded(child: Text('External attendees', style: DS.text.cardTitle)),
                                TextButton.icon(
                                  onPressed: _openAddExternalAttendeeSheet,
                                  icon: const FaIcon(FontAwesomeIcons.userPlus, size: 14, color: DS.primary),
                                  label: Text('Add', style: DS.text.primary.copyWith(color: DS.primary)),
                                ),
                              ],
                            ),

                            const SizedBox(height: DS.m),

                            Row(
                              children: [
                                Text('Selected', style: DS.text.primary.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(width: DS.s),
                                _CountPill(count: _selectedAttendees.length),
                              ],
                            ),
                            const SizedBox(height: DS.m),

                            if (_selectedAttendees.isEmpty)
                              _EmptyState(
                                title: 'No attendees added',
                                subtitle: 'Search internal or add external attendees',
                              )
                            else
                              Wrap(
                                spacing: DS.s,
                                runSpacing: DS.s,
                                children: _selectedAttendees.map((a) {
                                  return _Chip(
                                    label: a.displayLabel,
                                    onRemove: () => _removeAttendee(a),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: DS.xl),

                      // Description
                      DSCard(
                        title: 'Meeting Description',
                        icon: FaIcon(FontAwesomeIcons.alignLeft, size: 14, color: DS.primary),
                        child: TextFormField(
                          controller: _descriptionCtrl,
                          style: DS.text.primary,
                          maxLines: 4,
                          decoration: DS.input(
                            label: 'Description',
                            hint: 'Describe agenda or any special requirements...',
                            prefixIcon: FaIcon(FontAwesomeIcons.noteSticky, size: 14, color: DS.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// ---------------------------
/// Design System (as per user spec)
/// ---------------------------
class DS {
  // Colors
  static const Color primary = Color(0xFF1892F5);
  static const Color primaryLight = Color(0xFFE8F2FE);
  static const Color border = Color(0xFFDCE6F1);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color background = Color(0xFFFFFFFF);

  // Spacing (only tokens)
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;

  // Card
  static const double cardRadius = 16;
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // Typography (Poppins via GoogleFonts) - sizes/weights as per spec
  static _DSText get text => _DSText();

  // Input decoration with corporate style
  static InputDecoration input({
    required String label,
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: DS.text.label,
      hintStyle: DS.text.label.copyWith(color: DS.textSecondary),
      prefixIcon: prefixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 12, right: 10),
              child: prefixIcon,
            ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: DS.primaryLight.withOpacity(0.55),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DS.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DS.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DS.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DS.error, width: 1),
      ),
    );
  }

  // Primary button
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: DS.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 0,
  );
}

class _DSText {
  TextStyle get screenTitle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: DS.textPrimary,
        height: 1.25,
      );

  TextStyle get cardTitle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DS.textPrimary,
        height: 1.25,
      );

  TextStyle get primary => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DS.textPrimary,
        height: 1.35,
      );

  TextStyle get secondary => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DS.textSecondary,
        height: 1.35,
      );

  TextStyle get label => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DS.textSecondary,
        height: 1.2,
      );
}

/// ---------------------------
/// UI Components
/// ---------------------------
class DSCard extends StatelessWidget {
  const DSCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final Widget icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DS.l),
      decoration: BoxDecoration(
        color: DS.background,
        borderRadius: BorderRadius.circular(DS.cardRadius),
        border: Border.all(color: DS.border, width: 1),
        boxShadow: DS.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: DS.s),
              Expanded(
                child: Text(
                  title,
                  style: DS.text.cardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DS.l),
          child,
        ],
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  const _TapField({
    required this.label,
    required this.value,
    required this.prefixIcon,
    required this.onTap,
  });

  final String label;
  final String value;
  final Widget prefixIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value.trim().endsWith('...');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: DS.input(
          label: label,
          hint: '',
          prefixIcon: prefixIcon,
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 10),
            child: FaIcon(FontAwesomeIcons.chevronDown, size: 14, color: DS.textSecondary),
          ),
        ),
        child: Text(
          value,
          style: DS.text.primary.copyWith(
            color: isPlaceholder ? DS.textSecondary : DS.textPrimary,
            fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DS.m, vertical: DS.xs),
      decoration: BoxDecoration(
        color: DS.primaryLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DS.border),
      ),
      child: Text(
        count.toString(),
        style: DS.text.secondary.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DS.m, vertical: DS.s),
      decoration: BoxDecoration(
        color: DS.primaryLight.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DS.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: DS.text.secondary.copyWith(color: DS.textPrimary, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: DS.s),
          InkWell(
            onTap: onRemove,
            child: const FaIcon(FontAwesomeIcons.circleXmark, size: 16, color: DS.error),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DS.l),
      decoration: BoxDecoration(
        color: DS.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DS.border, width: 1),
      ),
      child: Column(
        children: [
          const FaIcon(FontAwesomeIcons.users, size: 18, color: DS.textSecondary),
          const SizedBox(height: DS.s),
          Text(title, style: DS.text.primary.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: DS.xs),
          Text(subtitle, style: DS.text.secondary, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// ---------------------------
/// Models
/// ---------------------------
class Room {
  final String id;
  final String name;
  final int capacity;

  const Room({required this.id, required this.name, required this.capacity});
}

enum AttendeeType { internal, external }

class Attendee {
  final AttendeeType type;
  final String name;
  final String? email;

  const Attendee._({required this.type, required this.name, required this.email});

  const Attendee.internal({required String name, required String email})
      : this._(type: AttendeeType.internal, name: name, email: email);

  const Attendee.external({required String name, String? email})
      : this._(type: AttendeeType.external, name: name, email: email);

  String get displayLabel {
    final e = (email ?? '').trim();
    return e.isEmpty ? name : '$name ($e)';
  }
}

class CreateBookingRequest {
  final String meetingTitle;
  final String roomId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isRecurring;
  final int numberOfAttendees;
  final List<Attendee> attendees;
  final String description;

  const CreateBookingRequest({
    required this.meetingTitle,
    required this.roomId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isRecurring,
    required this.numberOfAttendees,
    required this.attendees,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    String hhmm(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return {
      'meetingTitle': meetingTitle,
      'roomId': roomId,
      'date': date.toIso8601String(),
      'startTime': hhmm(startTime),
      'endTime': hhmm(endTime),
      'isRecurring': isRecurring,
      'numberOfAttendees': numberOfAttendees,
      'attendees': attendees
          .map((a) => {'type': a.type.name, 'name': a.name, 'email': a.email})
          .toList(),
      'description': description,
    };
  }
}
