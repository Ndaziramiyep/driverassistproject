import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:driverassist/models/service_provider_model.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'driverassist.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE service_providers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        rating REAL NOT NULL,
        review_count INTEGER NOT NULL,
        phone TEXT,
        is_open INTEGER NOT NULL,
        distance REAL,
        image_url TEXT,
        cached_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        collection TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> cacheServiceProviders(List<ServiceProviderModel> providers) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final p in providers) {
      batch.insert(
        'service_providers',
        {
          'id': p.id,
          'name': p.name,
          'type': p.type,
          'address': p.address,
          'latitude': p.latitude,
          'longitude': p.longitude,
          'rating': p.rating,
          'review_count': p.reviewCount,
          'phone': p.phone,
          'is_open': p.isOpen ? 1 : 0,
          'distance': p.distance,
          'image_url': p.imageUrl,
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ServiceProviderModel>> getCachedServiceProviders({String? type}) async {
    final db = await database;
    final where = type != null ? 'WHERE type = ?' : '';
    final args = type != null ? [type] : null;
    final rows = await db.rawQuery(
      'SELECT * FROM service_providers $where ORDER BY distance ASC',
      args,
    );
    return rows.map((row) => ServiceProviderModel(
      id: row['id'] as String,
      name: row['name'] as String,
      type: row['type'] as String,
      address: row['address'] as String,
      latitude: row['latitude'] as double,
      longitude: row['longitude'] as double,
      rating: row['rating'] as double,
      reviewCount: row['review_count'] as int,
      phone: row['phone'] as String?,
      isOpen: (row['is_open'] as int) == 1,
      distance: row['distance'] as double?,
      imageUrl: row['image_url'] as String?,
    )).toList();
  }

  Future<void> addToSyncQueue(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    await db.insert('sync_queue', {
      'action': action,
      'collection': collection,
      'data': data.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return db.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete('sync_queue');
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('service_providers');
  }
}
