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

  // Theme mode: 0 = dark, 1 = light, 2 = AMOLED
  int _themeMode = 0;
  int get themeMode => _themeMode;

  // Streak tracking
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;
  int _longestStreak = 0;
  int get longestStreak => _longestStreak;
  String _lastActiveDate = '';
  String get lastActiveDate => _lastActiveDate;

  // Daily quote
  String _todaysQuote = '';
  String get todaysQuote => _todaysQuote;
  String _todaysQuoteAuthor = '';
  String get todaysQuoteAuthor => _todaysQuoteAuthor;

  static const List<Map<String, String>> _quotes = [
    {'text': 'You have approximately 4,000 weeks. This is not a metaphor.', 'author': 'Oliver Burkeman'},
    {'text': 'The average human lifespan is absurdly, insultingly brief. Assuming you live to be eighty, you have just over four thousand weeks.', 'author': 'Oliver Burkeman'},
    {'text': 'Time is the most valuable thing a man can spend.', 'author': 'Theophrastus'},
    {'text': 'Your time is finite. Do not waste it living someone else\'s life.', 'author': 'Steve Jobs'},
    {'text': 'We are all dying. Some of us just have a head start.', 'author': 'Unknown'},
    {'text': 'Every second you waste is a second you will never get back.', 'author': 'Unknown'},
    {'text': 'The trouble is, you think you have time.', 'author': 'Jack Kornfield'},
    {'text': 'Life is not a problem to be solved, but a reality to be experienced.', 'author': 'Søren Kierkegaard'},
    {'text': 'Time flies over us, but leaves its shadow behind.', 'author': 'Nathaniel Hawthorne'},
    {'text': 'Lost time is never found again.', 'author': 'Benjamin Franklin'},
    {'text': 'The two most powerful warriors are patience and time.', 'author': 'Leo Tolstoy'},
    {'text': 'Time you enjoy wasting is not wasted time.', 'author': 'Marthe Troly-Curtin'},
    {'text': 'You may delay, but time will not.', 'author': 'Benjamin Franklin'},
    {'text': 'Time is what we want most, but what we use worst.', 'author': 'William Penn'},
    {'text': 'The future is something which everyone reaches at the rate of sixty minutes an hour.', 'author': 'C.S. Lewis'},
    {'text': 'Don\'t count the days, make the days count.', 'author': 'Muhammad Ali'},
    {'text': 'Time is the coin of your life. It is the only coin you have.', 'author': 'Carl Sandburg'},
    {'text': 'In three words I can sum up life: it goes on.', 'author': 'Robert Frost'},
    {'text': 'The worst saving is saving time.', 'author': 'Baltasar Gracian'},
    {'text': 'Time is the most undefinable yet paradoxical of things; without it, nothing can be done.', 'author': 'Cotton Mather'},
    {'text': 'A year from now you will wish you had started today.', 'author': 'Karen Lamb'},
    {'text': 'The time you enjoy wasting is not wasted time at all.', 'author': 'Marthe Troly-Curtin'},
    {'text': 'Don\'t wait. The time will never be just right.', 'author': 'Napoleon Hill'},
    {'text': 'Time is what prevents everything from happening at once.', 'author': 'John Archibald Wheeler'},
    {'text': 'If you love life, don\'t waste time, for time is what life is made up of.', 'author': 'Bruce Lee'},
    {'text': 'All we have to decide is what to do with the time that is given us.', 'author': 'J.R.R. Tolkien'},
    {'text': 'Realize deeply that the present moment is all you ever have.', 'author': 'Eckhart Tolle'},
    {'text': 'Time moves slowly, but passes quickly.', 'author': 'Alice Walker'},
    {'text': 'It is not that we have a short time to live, but that we waste a good deal of it.', 'author': 'Seneca'},
    {'text': 'The greatest浪费 of time is between impulse and action.', 'author': 'Unknown'},
  ];

  Future<void> _init() async {
    _profile = await LocalStorage.loadProfile();
    await _loadCollections();
    await _loadPreferences();
    _recomputeLife();
    _pickTodaysQuote();
    _updateStreak();
    _isInitialized = true;
    notifyListeners();
  }

  void _pickTodaysQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final index = dayOfYear % _quotes.length;
    _todaysQuote = _quotes[index]['text']!;
    _todaysQuoteAuthor = _quotes[index]['author']!;
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getInt('theme_mode') ?? 0;
    _currentStreak = prefs.getInt('current_streak') ?? 0;
    _longestStreak = prefs.getInt('longest_streak') ?? 0;
    _lastActiveDate = prefs.getString('last_active_date') ?? '';
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode);
    await prefs.setInt('current_streak', _currentStreak);
    await prefs.setInt('longest_streak', _longestStreak);
    await prefs.setString('last_active_date', _lastActiveDate);
  }

  void _updateStreak() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (_lastActiveDate == todayStr) return;

    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

    if (_lastActiveDate == yesterdayStr) {
      _currentStreak++;
    } else if (_lastActiveDate.isEmpty) {
      _currentStreak = 1;
    } else {
      _currentStreak = 1;
    }

    _lastActiveDate = todayStr;
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }
    _savePreferences();
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
        icon: 'S',
      ),
      TimeAllocation(
        id: const Uuid().v4(),
        name: 'Job',
        hoursPerDay: 9,
        icon: 'J',
      ),
      TimeAllocation(
        id: const Uuid().v4(),
        name: 'Commute',
        hoursPerDay: 1.5,
        icon: 'C',
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

  Future<void> setThemeMode(int mode) async {
    _themeMode = mode;
    await _savePreferences();
    notifyListeners();
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
