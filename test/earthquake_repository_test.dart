import 'package:flutter_test/flutter_test.dart';
import 'package:rws_app/src/data/earthquake_repository.dart';
import 'package:rws_app/src/domain/earthquake.dart';

class FakeApi implements EarthquakeApi {
  FakeApi(this.result);
  Object? result;

  @override
  Future<List<Earthquake>> fetch(FeedWindow window) async {
    final current = result;
    if (current is Exception) throw current;
    return current as List<Earthquake>;
  }
}

class FakeCache implements SnapshotCache {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  group('EarthquakeRepository', () {
    final fixedNow = DateTime.utc(2026, 11, 13, 10);

    test('returns fresh events and writes a snapshot to cache', () async {
      final event = _sampleEvent();
      final cache = FakeCache();
      final repository = EarthquakeRepository(
        api: FakeApi([event]),
        cache: cache,
        clock: () => fixedNow,
      );

      final result = await repository.load(FeedWindow.day);

      expect(result.events, [event]);
      expect(result.isStale, isFalse);
      expect(result.fetchedAt, fixedNow);
      expect(cache.values.containsKey('quakewatch.day'), isTrue);
    });

    test('returns stale cached data when the API fails', () async {
      final cache = FakeCache();
      final seed = EarthquakeRepository(
        api: FakeApi([_sampleEvent()]),
        cache: cache,
        clock: () => fixedNow,
      );
      await seed.load(FeedWindow.day);

      final offlineRepository = EarthquakeRepository(
        api: FakeApi(Exception('offline')),
        cache: cache,
        clock: () => fixedNow.add(const Duration(minutes: 5)),
      );

      final result = await offlineRepository.load(FeedWindow.day);

      expect(result.events.single.id, 'event-1');
      expect(result.isStale, isTrue);
      expect(result.fetchedAt, fixedNow);
    });

    test('rethrows API error when no cached snapshot exists', () async {
      final repository = EarthquakeRepository(
        api: FakeApi(Exception('offline')),
        cache: FakeCache(),
      );

      expect(
            () => repository.load(FeedWindow.hour),
        throwsException,
      );
    });
  });
}

Earthquake _sampleEvent() => Earthquake(
  id: 'event-1',
  place: 'Test location',
  magnitude: 3.2,
  depthKm: 7.0,
  latitude: 12,
  longitude: 23,
  occurredAt: DateTime.utc(2026, 11, 13, 9),
  url: 'https://earthquake.usgs.gov/',
);
