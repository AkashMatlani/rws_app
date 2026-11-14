class Earthquake {
  const Earthquake({
    required this.id,
    required this.place,
    required this.magnitude,
    required this.depthKm,
    required this.latitude,
    required this.longitude,
    required this.occurredAt,
    required this.url,
  });

  final String id;
  final String place;
  final double magnitude;
  final double depthKm;
  final double latitude;
  final double longitude;
  final DateTime occurredAt;
  final String url;

  factory Earthquake.fromGeoJson(Map<String, dynamic> feature) {
    final properties = feature['properties'];
    final geometry = feature['geometry'];

    if (properties is! Map<String, dynamic> ||
        geometry is! Map<String, dynamic>) {
      throw const FormatException(
        'Earthquake feature is missing properties or geometry.',
      );
    }

    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 3) {
      throw const FormatException(
        'Earthquake feature has invalid coordinates.',
      );
    }

    final magnitude = _asDouble(properties['mag']);
    final longitude = _asDouble(coordinates[0]);
    final latitude = _asDouble(coordinates[1]);
    final depth = _asDouble(coordinates[2]);
    final timestamp = properties['time'];

    if (magnitude == null ||
        longitude == null ||
        latitude == null ||
        depth == null ||
        timestamp is! num) {
      throw const FormatException(
        'Earthquake feature contains invalid numeric data.',
      );
    }

    final rawId = feature['id'];
    final rawPlace = properties['place'];
    final rawUrl = properties['url'];

    return Earthquake(
      id: rawId is String && rawId.isNotEmpty
          ? rawId
          : '${timestamp.toInt()}-$latitude-$longitude',
      place: rawPlace is String && rawPlace.trim().isNotEmpty
          ? rawPlace.trim()
          : 'Location unavailable',
      magnitude: magnitude,
      depthKm: depth,
      latitude: latitude,
      longitude: longitude,
      occurredAt: DateTime.fromMillisecondsSinceEpoch(
        timestamp.toInt(),
        isUtc: true,
      ),
      url: rawUrl is String ? rawUrl : 'https://earthquake.usgs.gov/',
    );
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
