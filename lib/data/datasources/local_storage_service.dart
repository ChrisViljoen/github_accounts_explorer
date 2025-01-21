import 'dart:async';

import 'package:github_accounts_explorer/data/models/github_user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageService {
  static const String _tableName = 'liked_users';
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'github_explorer.db');

    return await openDatabase(
      path,
      version: 1,
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
      },
    );
  }

  Future<List<GitHubUser>> getLikedUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
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
  }

  Future<bool> toggleLikedUser(GitHubUser user) async {
    final db = await database;
    final isLiked = await this.isUserLiked(user);

    if (isLiked) {
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [user.id],
      );
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
      return true;
    }
  }

  Future<bool> isUserLiked(GitHubUser user) async {
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
  }
}
