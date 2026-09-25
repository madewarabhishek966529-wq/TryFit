import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/try_on/domain/try_on_models.dart';
import '../../features/wardrobe/domain/wardrobe_item.dart';

/// Snappy offline-first local persistence service.
/// Uses SharedPreferences with in-memory caching for synchronous, zero-jank UI reads
/// and asynchronous, non-blocking disk persistence.
class LocalStorageService {
  static const String _keyJobs = 'tryfit_jobs_v1';
  static const String _keyWardrobe = 'tryfit_wardrobe_v1';
  static const String _keyTheme = 'tryfit_dark_mode_v1';
  static const String _keyMirrorCam = 'tryfit_mirror_camera_v1';

  final SharedPreferences _prefs;

  LocalStorageService._(this._prefs);

  static LocalStorageService? _instance;

  static Future<LocalStorageService> getInstance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalStorageService._(prefs);
    return _instance!;
  }

  /// Synchronously or eagerly initialized instance for testing/dependency injection
  static void setMockInstance(LocalStorageService mock) {
    _instance = mock;
  }

  /// Loads persisted simulation jobs
  List<TryOnJob> loadJobs() {
    final rawList = _prefs.getStringList(_keyJobs);
    if (rawList == null || rawList.isEmpty) return [];

    final jobs = <TryOnJob>[];
    for (final raw in rawList) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        jobs.add(TryOnJob.fromJson(map));
      } catch (_) {
        // Skip corrupted entries gracefully
      }
    }
    return jobs;
  }

  /// Persists simulation jobs asynchronously without blocking the UI frame
  Future<bool> saveJobs(List<TryOnJob> jobs) async {
    final encoded = jobs.map((j) => jsonEncode(j.toJson())).toList();
    return _prefs.setStringList(_keyJobs, encoded);
  }

  /// Loads persisted custom wardrobe items
  List<WardrobeItem> loadWardrobe() {
    final rawList = _prefs.getStringList(_keyWardrobe);
    if (rawList == null || rawList.isEmpty) return [];

    final items = <WardrobeItem>[];
    for (final raw in rawList) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        items.add(WardrobeItem.fromJson(map));
      } catch (_) {
        // Skip corrupted entries
      }
    }
    return items;
  }

  /// Persists wardrobe items
  Future<bool> saveWardrobe(List<WardrobeItem> items) async {
    final encoded = items.map((i) => jsonEncode(i.toJson())).toList();
    return _prefs.setStringList(_keyWardrobe, encoded);
  }

  /// User theme preference
  bool? loadDarkMode() => _prefs.getBool(_keyTheme);
  Future<bool> saveDarkMode(bool isDark) => _prefs.setBool(_keyTheme, isDark);

  /// Camera mirror preference
  bool loadMirrorCamera() => _prefs.getBool(_keyMirrorCam) ?? true;
  Future<bool> saveMirrorCamera(bool mirror) =>
      _prefs.setBool(_keyMirrorCam, mirror);

  /// Complete local data purge
  Future<bool> clearAll() async {
    await _prefs.remove(_keyJobs);
    await _prefs.remove(_keyWardrobe);
    return true;
  }
}
