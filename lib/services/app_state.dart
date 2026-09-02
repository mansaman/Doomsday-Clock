import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/alarm.dart';
import '../models/task.dart';
import '../models/time_allocation.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../services/life_calculator.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _init();
  }

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  LifeCalculator? _lifeCalculator;
  LifeCalculator? get lifeCalculator => _lifeCalculator;

  final List<QuickNote> _notes = [];
  final List<QuickNote> _pinnedNotes = [];
  List<QuickNote> get notes => List.unmodifiable(_notes);
  List<QuickNote> get pinnedNotes => List.unmodifiable(_pinnedNotes);

  final List<AppAlarm> _alarms = [];
  List<AppAlarm> get alarms => List.unmodifiable(_alarms);

  final List<WorkTask> _tasks = [];
  List<WorkTask> get tasks => List.unmodifiable(_tasks);

  List<WorkTask> get activeTasks =>
      _tasks.where((t) => t.isActive && !t.isCompleted).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  final List<TimeAllocation> _allocations = [];
  List<TimeAllocation> get allocations => List.unmodifiable(_allocations);

  double get totalAllocatedHoursPerDay =>
      _allocations.where((a) => a.isActive).fold(0.0, (sum, a) => sum + a.hoursPerDay);

  bool get isReady => _isInitialized;

  bool _isInitialized = false;

  Future<void> _init() async {
    _profile = await LocalStorage.loadProfile();
    await _loadCollections();
    _recomputeLife();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('time_allocations');
    if (raw != null) {
      try {
        final list = (raw.split('~~').where((s) => s.isNotEmpty));
        _allocations.addAll(list.map((s) {
          final parts = s.split('|');
          return TimeAllocation(
            id: parts[0],
            name: parts[1],
            hoursPerDay: double.parse(parts[2]),
            icon: parts[3],
            isActive: parts[4] == 'true',
          );
        }));
      } catch (_) {}
    }
    if (_allocations.isEmpty) {
      _seedDefaultAllocations();
      await _persistAllocations();
    }
  }

  void _seedDefaultAllocations() {
    _allocations.addAll([
      TimeAllocation(
        id: const Uuid().v4(),
        name: 'Sleep',
        hoursPerDay: 8,
        icon: '🌙',
      ),
      TimeAllocation(
        id: const Uuid().v4(),
        name: 'Job',
        hoursPerDay: 9,
        icon: '💼',
      ),
      TimeAllocation(
        id: const Uuid().v4(),
        name: 'Commute',
        hoursPerDay: 1.5,
        icon: '🚗',
      ),
    ]);
  }

  Future<void> _persistAllocations() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _allocations.map((a) =>
        '${a.id}|${a.name}|${a.hoursPerDay}|${a.icon}|${a.isActive}').join('~~');
    await prefs.setString('time_allocations', encoded);
  }

  void _recomputeLife() {
    if (_profile != null) {
      _lifeCalculator = LifeCalculator(
        dateOfBirth: _profile!.dateOfBirth,
        lifeExpectancyYears: _profile!.lifeExpectancyYears,
        allocations: List.of(_allocations),
      );
    }
  }

  Future<void> completeOnboarding({
    required DateTime dateOfBirth,
    required int lifeExpectancyYears,
  }) async {
    _profile = UserProfile(
      dateOfBirth: dateOfBirth,
      lifeExpectancyYears: lifeExpectancyYears,
      isOnboarded: true,
    );
    await LocalStorage.saveProfile(_profile!);
    _recomputeLife();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    await LocalStorage.saveProfile(profile);
    _recomputeLife();
    notifyListeners();
  }

  Future<void> addAllocation({
    required String name,
    required double hoursPerDay,
    required String icon,
  }) async {
    _allocations.add(TimeAllocation(
      id: const Uuid().v4(),
      name: name,
      hoursPerDay: hoursPerDay,
      icon: icon,
    ));
    await _persistAllocations();
    _recomputeLife();
    notifyListeners();
  }

  Future<void> updateAllocation(TimeAllocation allocation) async {
    final index = _allocations.indexWhere((a) => a.id == allocation.id);
    if (index != -1) {
      _allocations[index] = allocation;
      await _persistAllocations();
      _recomputeLife();
      notifyListeners();
    }
  }

  Future<void> removeAllocation(String id) async {
    _allocations.removeWhere((a) => a.id == id);
    await _persistAllocations();
    _recomputeLife();
    notifyListeners();
  }

  void addNote({
    required String content,
    int? flashIntervalMinutes,
  }) {
    final note = QuickNote(
      id: const Uuid().v4(),
      content: content,
      flashIntervalMinutes: flashIntervalMinutes,
      createdAt: DateTime.now(),
    );
    if (note.isPinned) {
      _pinnedNotes.add(note);
    } else {
      _notes.add(note);
    }
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _pinnedNotes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void togglePin(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final note = QuickNote(
        id: _notes[index].id,
        content: _notes[index].content,
        flashIntervalMinutes: _notes[index].flashIntervalMinutes,
        isPinned: true,
        createdAt: _notes[index].createdAt,
      );
      _notes.removeAt(index);
      _pinnedNotes.insert(0, note);
    } else {
      final pIndex = _pinnedNotes.indexWhere((n) => n.id == id);
      if (pIndex != -1) {
        final note = QuickNote(
          id: _pinnedNotes[pIndex].id,
          content: _pinnedNotes[pIndex].content,
          flashIntervalMinutes: _pinnedNotes[pIndex].flashIntervalMinutes,
          isPinned: false,
          createdAt: _pinnedNotes[pIndex].createdAt,
        );
        _pinnedNotes.removeAt(pIndex);
        _notes.insert(0, note);
      }
    }
    notifyListeners();
  }

  void addAlarm({
    required int hour,
    required int minute,
    required String message,
  }) {
    final alarm = AppAlarm(
      id: const Uuid().v4(),
      hour: hour,
      minute: minute,
      message: message,
      isActive: true,
    );
    _alarms.add(alarm);
    notifyListeners();
  }

  void removeAlarm(String id) {
    _alarms.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleAlarm(String id) {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = AppAlarm(
        id: alarm.id,
        hour: alarm.hour,
        minute: alarm.minute,
        message: alarm.message,
        isActive: !alarm.isActive,
        repeatDaily: alarm.repeatDaily,
      );
      notifyListeners();
    }
  }

  void addTask({
    required String name,
    int? allocatedMinutes,
  }) {
    final task = WorkTask(
      id: const Uuid().v4(),
      name: name,
      allocatedMinutes: allocatedMinutes,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(WorkTask task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleTaskComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = WorkTask(
        id: task.id,
        name: task.name,
        allocatedMinutes: task.allocatedMinutes,
        isCompleted: !task.isCompleted,
        isActive: task.isActive,
        createdAt: task.createdAt,
      );
      notifyListeners();
    }
  }
}
