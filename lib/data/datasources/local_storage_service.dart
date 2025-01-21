import 'dart:async';

import 'package:github_accounts_explorer/data/models/github_user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageService {
  static const String _tableName = 'liked_users';
  static const String _recentSearchesTable = 'recent_searches';
  static Database? _database;
  List<GitHubUser>? _cachedUsers;
  Set<int>? _cachedUserIds;
  List<String>? _cachedSearches;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'github_explorer.db');

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            login TEXT NOT NULL,
            avatar_url TEXT NOT NULL,
            type TEXT NOT NULL,
            name TEXT,
            bio TEXT,
            public_repos INTEGER,
            followers INTEGER,
            following INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE $_recentSearchesTable (
            query TEXT PRIMARY KEY,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE $_recentSearchesTable (
              query TEXT PRIMARY KEY,
              timestamp INTEGER NOT NULL
            )
          ''');
        }
      },
    );

    await _initCache(db);
    return db;
  }

  Future<void> _initCache(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    _cachedUsers = List.generate(maps.length, (i) {
      return GitHubUser(
        id: maps[i]['id'],
        login: maps[i]['login'],
        avatarUrl: maps[i]['avatar_url'],
        type: maps[i]['type'],
        name: maps[i]['name'],
        bio: maps[i]['bio'],
        publicRepos: maps[i]['public_repos'],
        followers: maps[i]['followers'],
        following: maps[i]['following'],
      );
    });
    _cachedUserIds = _cachedUsers?.map((u) => u.id).toSet() ?? {};

    final searches = await db.query(
      _recentSearchesTable,
      orderBy: 'timestamp DESC',
      limit: 10,
    );
    _cachedSearches = searches.map((s) => s['query'] as String).toList();
  }

  Future<List<GitHubUser>> getLikedUsers() async {
    if (_cachedUsers != null) {
      return _cachedUsers!;
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    _cachedUsers = List.generate(maps.length, (i) {
      return GitHubUser(
        id: maps[i]['id'],
        login: maps[i]['login'],
        avatarUrl: maps[i]['avatar_url'],
        type: maps[i]['type'],
        name: maps[i]['name'],
        bio: maps[i]['bio'],
        publicRepos: maps[i]['public_repos'],
        followers: maps[i]['followers'],
        following: maps[i]['following'],
      );
    });
    _cachedUserIds = _cachedUsers?.map((u) => u.id).toSet() ?? {};
    return _cachedUsers!;
  }

  Future<bool> toggleLikedUser(GitHubUser user) async {
    final db = await database;
    final isLiked = _cachedUserIds?.contains(user.id) ?? false;

    if (isLiked) {
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [user.id],
      );
      _cachedUsers?.removeWhere((u) => u.id == user.id);
      _cachedUserIds?.remove(user.id);
      return false;
    } else {
      await db.insert(
        _tableName,
        {
          'id': user.id,
          'login': user.login,
          'avatar_url': user.avatarUrl,
          'type': user.type,
          'name': user.name,
          'bio': user.bio,
          'public_repos': user.publicRepos,
          'followers': user.followers,
          'following': user.following,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _cachedUsers?.add(user);
      _cachedUserIds?.add(user.id);
      return true;
    }
  }

  Future<bool> isUserLiked(GitHubUser user) async {
    if (_cachedUserIds != null) {
      return _cachedUserIds!.contains(user.id);
    }
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [user.id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> clearLikedUsers() async {
    final db = await database;
    await db.delete(_tableName);
    _cachedUsers?.clear();
    _cachedUserIds?.clear();
  }

  Future<List<String>> getRecentSearches() async {
    final db = await database;
    final searches = await db.query(
      _recentSearchesTable,
      orderBy: 'timestamp DESC',
      limit: 10,
    );
    _cachedSearches = searches.map((s) => s['query'] as String).toList();
    return _cachedSearches!;
  }

  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    final db = await database;
    await db.insert(
      _recentSearchesTable,
      {
        'query': query.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await getRecentSearches();
  }

  Future<void> clearRecentSearches() async {
    final db = await database;
    await db.delete(_recentSearchesTable);
    _cachedSearches?.clear();
  }

  Future<void> removeRecentSearch(String query) async {
    final db = await database;
    await db.delete(
      _recentSearchesTable,
      where: 'query = ?',
      whereArgs: [query],
    );
    _cachedSearches?.remove(query);
  }
}
