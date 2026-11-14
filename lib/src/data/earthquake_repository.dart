import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/earthquake.dart';

enum FeedWindow {
  hour('Past hour', Duration(hours: 1), 'all_hour'),
  day('24 hours', Duration(hours: 24), 'all_day'),
  week('7 days', Duration(days: 7), 'all_week');

  const FeedWindow(this.label, this.duration, this.feedPath);

  final String label;
  final Duration duration;
  final String feedPath;
}

class EarthquakeSnapshot {
  const EarthquakeSnapshot({
    required this.events,
    required this.fetchedAt,
    this.isStale = false,
  });

  final List<Earthquake> events;
  final DateTime fetchedAt;
  final bool isStale;
}

abstract interface class EarthquakeApi {
  Future<List<Earthquake>> fetch(FeedWindow window);
}

abstract interface class SnapshotCache {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}

class UsgsEarthquakeApi implements EarthquakeApi {
  UsgsEarthquakeApi(this._dio);

  final Dio _dio;

  @override
  Future<List<Earthquake>> fetch(FeedWindow window) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/${window.feedPath}.geojson',
    );

    final body = response.data;
    final features = body?['features'];
    if (features is! List) {
      throw const FormatException('USGS returned an unexpected response.');
    }

    final events = <Earthquake>[];
    for (final item in features) {
      if (item is Map<String, dynamic>) {
        try {
          events.add(Earthquake.fromGeoJson(item));
        } on FormatException {
          // A malformed individual feature should not take down the whole feed.
        }
      }
    }

    events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return events;
  }
}

class PreferencesSnapshotCache implements SnapshotCache {
  PreferencesSnapshotCache(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
}

class EarthquakeRepository {
  EarthquakeRepository({
    required this._api,
    required this._cache,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final EarthquakeApi _api;
  final SnapshotCache _cache;
  final DateTime Function() _clock;

  Future<EarthquakeSnapshot> load(FeedWindow window) async {
    final cacheKey = 'quakewatch.${window.name}';
    try {
      final events = await _api.fetch(window);
      final fetchedAt = _clock().toUtc();
      final encoded = jsonEncode({
        'fetchedAt': fetchedAt.toIso8601String(),
        'features': events.map(_toCacheMap).toList(),
      });
      // A storage failure should not discard a perfectly good live response.
      try {
        await _cache.write(cacheKey, encoded);
      } catch (_) {
        // The feed remains usable; the next visit may simply have no snapshot.
      }
      return EarthquakeSnapshot(events: events, fetchedAt: fetchedAt);
    } catch (error) {
      final cached = await _readCached(cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<EarthquakeSnapshot?> _readCached(String key) async {
    try {
      final raw = await _cache.read(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> ||
          decoded['features'] is! List ||
          decoded['fetchedAt'] is! String) {
        return null;
      }

      final events = <Earthquake>[];
      for (final item in decoded['features'] as List) {
        if (item is Map<String, dynamic>) {
          try {
            events.add(Earthquake.fromGeoJson(item));
          } on FormatException {
            // Ignore corrupted individual cache entries.
          }
        }
      }

      return EarthquakeSnapshot(
        events: events,
        fetchedAt:
            DateTime.tryParse(decoded['fetchedAt'] as String)?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        isStale: true,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _toCacheMap(Earthquake event) => {
    'type': 'Feature',
    'id': event.id,
    'properties': {
      'place': event.place,
      'mag': event.magnitude,
      'time': event.occurredAt.millisecondsSinceEpoch,
      'url': event.url,
    },
    'geometry': {
      'type': 'Point',
      'coordinates': [event.longitude, event.latitude, event.depthKm],
    },
  };
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 8),
      headers: {'Accept': 'application/geo+json, application/json'},
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

final earthquakeRepositoryProvider = Provider<EarthquakeRepository>((ref) {
  return EarthquakeRepository(
    api: UsgsEarthquakeApi(ref.watch(dioProvider)),
    cache: PreferencesSnapshotCache(SharedPreferencesAsync()),
  );
});

class FeedWindowController extends Notifier<FeedWindow> {
  @override
  FeedWindow build() => FeedWindow.day;

  void select(FeedWindow window) => state = window;
}

final feedWindowProvider = NotifierProvider<FeedWindowController, FeedWindow>(
  FeedWindowController.new,
);

final earthquakeFeedProvider = FutureProvider<EarthquakeSnapshot>((ref) {
  final window = ref.watch(feedWindowProvider);
  return ref.watch(earthquakeRepositoryProvider).load(window);
});
