import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../models/islem.dart';
import '../models/kullanici.dart';

class VeritabaniYardimcisi {
  static final VeritabaniYardimcisi _instance =
      VeritabaniYardimcisi._internal();
  static Database? _database;
  static bool _initialized = false;

  factory VeritabaniYardimcisi() {
    return _instance;
  }

  VeritabaniYardimcisi._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    await _initializeDatabase();
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> _initializeDatabase() async {
    if (_initialized) return;

    if (!kIsWeb) {
      // Windows için SQLite FFI'yi başlat
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    }

    _initialized = true;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platformunda SQLite desteklenmemektedir. Lütfen masaüstü veya mobil uygulamayı kullanın.',
      );
    }

    final dbFolder = await getDatabasesPath();
    final dbPath = path.join(dbFolder, 'expense_tracker.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE islemler(
        id TEXT PRIMARY KEY,
        baslik TEXT NOT NULL,
        miktar REAL NOT NULL,
        tarih TEXT NOT NULL,
        kategori TEXT NOT NULL,
        tip TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE kullanicilar(
        id TEXT PRIMARY KEY,
        kullaniciAdi TEXT UNIQUE,
        sifre TEXT,
        kayitTarihi TEXT
      )
    ''');
  }

  Future<void> kullaniciEkle(Kullanici kullanici) async {
    final db = await database;
    await db.insert(
      'kullanicilar',
      kullanici.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Kullanici?> kullaniciGetir(String kullaniciAdi) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      where: 'kullaniciAdi = ?',
      whereArgs: [kullaniciAdi],
    );

    if (maps.isEmpty) return null;
    return Kullanici.fromMap(maps.first);
  }

  Future<bool> kullaniciDogrula(String kullaniciAdi, String sifre) async {
    final kullanici = await kullaniciGetir(kullaniciAdi);
    return kullanici?.sifre == sifre;
  }

  Future<void> harcamaEkle(Islem islem) async {
    final db = await database;
    await db.insert(
      'islemler',
      islem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> harcamaSil(String id) async {
    final db = await database;
    await db.delete(
      'islemler',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Islem>> tumHarcamalariGetir() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('islemler');
    return List.generate(maps.length, (i) {
      return Islem.fromMap(maps[i]);
    });
  }
}
