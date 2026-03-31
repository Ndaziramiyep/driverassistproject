import 'dart:js_util' as js_util;

Future<List<Map<String, dynamic>>> searchNearbyPlacesWeb({
  required double lat,
  required double lng,
  required int radiusMeters,
  required String includedType,
  int maxResults = 20,
}) async {
  final bridge = js_util.getProperty<dynamic>(
    js_util.globalThis,
    'driverAssistNearbySearch',
  );

  if (bridge == null) {
    throw Exception('Web places bridge is unavailable.');
  }

  final promise = js_util.callMethod<dynamic>(
    js_util.globalThis,
    'driverAssistNearbySearch',
    [lat, lng, radiusMeters, includedType, maxResults],
  );

  final rawResult = await js_util.promiseToFuture<Object?>(promise);
  final data = js_util.dartify(rawResult);

  if (data is! List) {
    return const [];
  }

  final places = <Map<String, dynamic>>[];
  for (final item in data) {
    if (item is Map) {
      places.add(item.cast<String, dynamic>());
    }
  }

  return places;
}
