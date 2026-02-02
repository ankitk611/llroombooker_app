import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roombooker/core/constants/url.dart';
import 'package:roombooker/core/methods/create_booking_api_service.dart';
import 'package:roombooker/core/methods/token_methods.dart';
import 'package:roombooker/widgets/app_drawer.dart';
import 'package:roombooker/widgets/navbar_widget.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/create_booking_design.dart';
import '../../core/methods/create_booking_service.dart';
import '../../core/models/create_booking_models.dart';
import '../../widgets/create_booking_widgets.dart';

class CreateBookingPage extends StatefulWidget {
  CreateBookingPage({super.key, CreateBookingService? service})
    : service = service ?? ApiCreateBookingService();

  final CreateBookingService service;

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  final _formKey = GlobalKey<FormState>();

  List<Attendee> _internalDirectory = const [];
  bool _loadingInternalDirectory = false;

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
    _refreshAvailableRooms();
    _loadInternalDirectoryOnce();
  }

  String _formatDateTime(DateTime dt) {
    return dt.toIso8601String().replaceFirst('T', ' ').substring(0, 19);
  }

  void _refreshAvailableRooms() {
    final start = _combine(_selectedDate, _startTime);
    final end = _combine(_selectedDate, _endTime);

    setState(() => _loadingRooms = true);
    fetchRooms(startTime: start, endTime: end);
  }

  Future<void> fetchRooms({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Url.baseUrl}/rooms/available'),
        headers: {
          'Content-Type': 'application/json',
          // add token if required
          'Authorization': 'Bearer ${await TokenUtils().getBearerToken()}',
        },
        body: jsonEncode({
          "start_time": _formatDateTime(startTime),
          "end_time": _formatDateTime(endTime),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch rooms');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final List data = decoded['data'] ?? [];

      final rooms = data.map<Room>((r) {
        return Room(
          id: r['id'].toString(),
          name: r['name'],
          capacity: r['capacity'] ?? r['max_occupancy'] ?? 0,
        );
      }).toList();

      setState(() {
        _rooms = rooms;
        _loadingRooms = false;
      });
    } catch (e) {
      print('ROOM FETCH ERROR: $e');
      setState(() {
        _rooms = [];
        _loadingRooms = false;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _attendeeCountCtrl.dispose();
    _descriptionCtrl.dispose();
    _internalSearchCtrl.dispose();
    super.dispose();
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
    final exists = _selectedAttendees.any(
      (x) =>
          x.type == a.type &&
          x.name.toLowerCase() == a.name.toLowerCase() &&
          (x.email ?? '').toLowerCase() == (a.email ?? '').toLowerCase(),
    );
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
    _refreshAvailableRooms();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked == null) return;

    setState(() {
      _startTime = picked;
      _refreshAvailableRooms();

      final start = _combine(_selectedDate, _startTime);
      final end = _combine(_selectedDate, _endTime);
      if (!end.isAfter(start)) {
        final newEnd = start.add(const Duration(hours: 1));
        _endTime = TimeOfDay(hour: newEnd.hour, minute: newEnd.minute);
      }
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked == null) return;
    setState(() => _endTime = picked);
    _refreshAvailableRooms();
  }

  void _runInternalSearch(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() => _internalSuggestions = const []);
      return;
    }

    // Local search from cached directory
    final results = _internalDirectory
        .where((a) {
          final name = a.name.toLowerCase();
          final email = (a.email ?? "").toLowerCase();
          return name.contains(q) || email.contains(q);
        })
        .take(15)
        .toList(); // limit suggestions

    setState(() => _internalSuggestions = results);
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
                        leading: const FaIcon(
                          FontAwesomeIcons.doorOpen,
                          size: 14,
                          color: DS.primary,
                        ),
                        title: Text(
                          r.name,
                          style: DS.text.primary.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Capacity: ${r.capacity}',
                          style: DS.text.secondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSel
                            ? const FaIcon(
                                FontAwesomeIcons.circleCheck,
                                size: 16,
                                color: DS.success,
                              )
                            : const FaIcon(
                                FontAwesomeIcons.chevronRight,
                                size: 14,
                                color: DS.textSecondary,
                              ),
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
                  prefixIcon: const FaIcon(
                    FontAwesomeIcons.user,
                    size: 14,
                    color: DS.primary,
                  ),
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
                  prefixIcon: const FaIcon(
                    FontAwesomeIcons.envelope,
                    size: 14,
                    color: DS.primary,
                  ),
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
                      Attendee.external(
                        name: name,
                        email: email.isEmpty ? null : email,
                      ),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.userPlus, size: 14),
                  label: Text(
                    'Add',
                    style: DS.text.primary.copyWith(color: Colors.white),
                  ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a room.')));
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
      await widget.service.submitBooking(req);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully.')),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create booking: $e')));
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
          iconTheme: const IconThemeData(
            color: Colors.white, // 👈 back button color
          ),
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
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        drawer: const AppDrawer(currentIndex: 1),
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
                        icon: const FaIcon(
                          FontAwesomeIcons.clipboardList,
                          size: 14,
                          color: DS.primary,
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleCtrl,
                              style: DS.text.primary,
                              decoration: DS.input(
                                label: 'Meeting Title *',
                                hint: 'e.g., Weekly Team Meeting',
                                prefixIcon: const FaIcon(
                                  FontAwesomeIcons.penToSquare,
                                  size: 14,
                                  color: DS.primary,
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Meeting title is required.'
                                  : null,
                            ),
                            const SizedBox(height: DS.l),

                            Row(
                              children: [
                                Expanded(
                                  child: TapField(
                                    label: 'Date *',
                                    value: _ddMMyyyy(_selectedDate),
                                    prefixIcon: const FaIcon(
                                      FontAwesomeIcons.calendarDays,
                                      size: 14,
                                      color: DS.primary,
                                    ),
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
                                      prefixIcon: const FaIcon(
                                        FontAwesomeIcons.users,
                                        size: 14,
                                        color: DS.success,
                                      ),
                                    ),
                                    validator: (v) {
                                      final n = int.tryParse((v ?? '').trim());
                                      if (n == null || n < 0) {
                                        return 'Invalid number';
                                      }
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
                                  child: TapField(
                                    label: 'Start Time *',
                                    value: _startTime.format(context),
                                    prefixIcon: const FaIcon(
                                      FontAwesomeIcons.clock,
                                      size: 14,
                                      color: DS.primary,
                                    ),
                                    onTap: _pickStartTime,
                                  ),
                                ),
                                const SizedBox(width: DS.m),
                                Expanded(
                                  child: TapField(
                                    label: 'End Time *',
                                    value: _endTime.format(context),
                                    prefixIcon: const FaIcon(
                                      FontAwesomeIcons.clockRotateLeft,
                                      size: 14,
                                      color: DS.primary,
                                    ),
                                    onTap: _pickEndTime,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DS.m),

                            TapField(
                              label: 'Room *',
                              value: _selectedRoom == null
                                  ? 'Select a room...'
                                  : '${_selectedRoom!.name} • ${_selectedRoom!.capacity}',
                              prefixIcon: const FaIcon(
                                FontAwesomeIcons.doorOpen,
                                size: 14,
                                color: DS.primary,
                              ),
                              onTap: _openRoomPicker,
                            ),
                            const SizedBox(height: DS.l),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DS.m,
                                  vertical: DS.s,
                                ),
                                decoration: BoxDecoration(
                                  color: DS.primaryLight,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: DS.border),
                                ),
                                child: Text(
                                  'Duration: $_durationLabel',
                                  style: DS.text.secondary.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
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
                        icon: const FaIcon(
                          FontAwesomeIcons.peopleGroup,
                          size: 14,
                          color: DS.success,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Internal (Microsoft 365)',
                              style: DS.text.cardTitle,
                            ),
                            const SizedBox(height: DS.m),

                            TextField(
                              controller: _internalSearchCtrl,
                              style: DS.text.primary,
                              decoration: DS.input(
                                label: 'Search',
                                hint: 'Search by name or email...',
                                prefixIcon: const FaIcon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  size: 14,
                                  color: DS.primary,
                                ),
                                suffixIcon: _loadingInternalDirectory
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        FontAwesomeIcons.magnifyingGlass,
                                        size: 14,
                                        color: DS.primary,
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
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 1,
                                    color: DS.border,
                                  ),
                                  itemBuilder: (context, i) {
                                    final a = _internalSuggestions[i];
                                    return ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: DS.m,
                                            vertical: DS.xs,
                                          ),
                                      leading: const FaIcon(
                                        FontAwesomeIcons.user,
                                        size: 14,
                                        color: DS.primary,
                                      ),
                                      title: Text(
                                        a.name,
                                        style: DS.text.primary,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: a.email == null
                                          ? null
                                          : Text(
                                              a.email!,
                                              style: DS.text.secondary,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      trailing: const FaIcon(
                                        FontAwesomeIcons.circlePlus,
                                        size: 16,
                                        color: DS.success,
                                      ),
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
                                Expanded(
                                  child: Text(
                                    'External attendees',
                                    style: DS.text.cardTitle,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _openAddExternalAttendeeSheet,
                                  icon: const FaIcon(
                                    FontAwesomeIcons.userPlus,
                                    size: 14,
                                    color: DS.primary,
                                  ),
                                  label: Text(
                                    'Add',
                                    style: DS.text.primary.copyWith(
                                      color: DS.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: DS.m),

                            Row(
                              children: [
                                Text(
                                  'Selected',
                                  style: DS.text.primary.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: DS.s),
                                CountPill(count: _selectedAttendees.length),
                              ],
                            ),
                            const SizedBox(height: DS.m),

                            if (_selectedAttendees.isEmpty)
                              const EmptyState(
                                title: 'No attendees added',
                                subtitle:
                                    'Search internal or add external attendees',
                              )
                            else
                              Wrap(
                                spacing: DS.s,
                                runSpacing: DS.s,
                                children: _selectedAttendees.map((a) {
                                  return RemovableChip(
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
                        icon: const FaIcon(
                          FontAwesomeIcons.alignLeft,
                          size: 14,
                          color: DS.primary,
                        ),
                        child: TextFormField(
                          controller: _descriptionCtrl,
                          style: DS.text.primary,
                          maxLines: 4,
                          decoration: DS.input(
                            label: 'Description',
                            hint:
                                'Describe agenda or any special requirements...',
                            prefixIcon: const FaIcon(
                              FontAwesomeIcons.noteSticky,
                              size: 14,
                              color: DS.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: DS.xl),

                      // Submit button INSIDE body
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _onSubmit,
                          style: DS.primaryButton,
                          child: _submitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Create Booking',
                                  style: DS.text.primary.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: DS.xl),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: AppBottomNavbar(currentIndex: 1),
      ),
    );
  }

  Future<void> _loadInternalDirectoryOnce() async {
    setState(() => _loadingInternalDirectory = true);
    try {
      // We know service is ApiCreateBookingService here, but keep it safe:
      final svc = widget.service;
      if (svc is ApiCreateBookingService) {
        final all = await svc.fetchAllInternalAttendees();
        if (!mounted) return;
        setState(() {
          _internalDirectory = all;
          _loadingInternalDirectory = false;
        });
      } else {
        // fallback: if you keep only interface, add a method to interface too
        setState(() => _loadingInternalDirectory = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _internalDirectory = [];
        _loadingInternalDirectory = false;
      });
    }
  }
}
