Future<List<Map<String, dynamic>>> searchNearbyPlacesWeb({
  required double lat,
  required double lng,
  required int radiusMeters,
  required String includedType,
  int maxResults = 20,
}) {
  throw UnsupportedError('searchNearbyPlacesWeb is only available on web.');
}
