import 'package:flutter_test/flutter_test.dart';
import 'package:rws_app/src/domain/earthquake.dart';

void main() {
  group('Earthquake.fromGeoJson', () {
    test('parses a valid USGS GeoJSON feature', () {
      final earthquake = Earthquake.fromGeoJson({
        'type': 'Feature',
        'id': 'us-test-1',
        'properties': {
          'mag': 4.6,
          'place': '12 km N of Somewhere',
          'time': 1700000000000,
          'url': 'https://earthquake.usgs.gov/example',
        },
        'geometry': {
          'type': 'Point',
          'coordinates': [-118.2, 34.1, 8.5],
        },
      });

      expect(earthquake.id, 'us-test-1');
      expect(earthquake.magnitude, 4.6);
      expect(earthquake.latitude, 34.1);
      expect(earthquake.longitude, -118.2);
      expect(earthquake.depthKm, 8.5);
      expect(earthquake.place, '12 km N of Somewhere');
      expect(earthquake.occurredAt.toUtc().millisecondsSinceEpoch, 1700000000000);
    });

    test('uses safe display defaults for optional text fields', () {
      final earthquake = Earthquake.fromGeoJson({
        'properties': {
          'mag': 2,
          'time': 1700000000000,
        },
        'geometry': {
          'coordinates': [10, 20, 3],
        },
      });

      expect(earthquake.place, 'Location unavailable');
      expect(earthquake.url, 'https://earthquake.usgs.gov/');
    });

    test('rejects malformed coordinates instead of silently plotting them', () {
      expect(
            () => Earthquake.fromGeoJson({
          'properties': {'mag': 2, 'time': 1700000000000},
          'geometry': {'coordinates': [10, 20]},
        }),
        throwsFormatException,
      );
    });

    test('rejects missing magnitude', () {
      expect(
            () => Earthquake.fromGeoJson({
          'properties': {'time': 1700000000000},
          'geometry': {'coordinates': [10, 20, 3]},
        }),
        throwsFormatException,
      );
    });
  });
}
