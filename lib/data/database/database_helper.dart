import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student_model.dart';
import '../models/candidate_model.dart';
import '../models/vote_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('voting_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Tabla de estudiantes
    await db.execute('''
      CREATE TABLE students (
        id $idType,
        email $textType UNIQUE,
        student_code $textType,
        has_voted INTEGER NOT NULL DEFAULT 0,
        voted_at TEXT,
        voted_candidate_id INTEGER,
        FOREIGN KEY (voted_candidate_id) REFERENCES candidates (id)
      )
    ''');

    // Tabla de candidatos
    await db.execute('''
      CREATE TABLE candidates (
        id $idType,
        name $textType,
        proposal $textType,
        image_url $textType,
        vote_count $intType DEFAULT 0
      )
    ''');

    // Tabla de votos
    await db.execute('''
      CREATE TABLE votes (
        id $idType,
        student_id $intType,
        candidate_id $intType,
        voted_at $textType,
        latitude $realType,
        longitude $realType,
        FOREIGN KEY (student_id) REFERENCES students (id),
        FOREIGN KEY (candidate_id) REFERENCES candidates (id)
      )
    ''');

    // Insertar candidatos iniciales
    await _insertInitialCandidates(db);
  }

  Future<void> _insertInitialCandidates(Database db) async {
    final candidates = [
      {
        'name': 'Juan Pérez García',
        'proposal':
            'Mejorar la infraestructura de laboratorios y promover eventos tecnológicos mensuales.',
        'image_url':
            'https://ui-avatars.com/api/?name=Juan+Perez&size=200&background=003DA5&color=fff',
        'vote_count': 0,
      },
      {
        'name': 'María González López',
        'proposal':
            'Implementar tutorías peer-to-peer y crear un banco de proyectos de la carrera.',
        'image_url':
            'https://ui-avatars.com/api/?name=Maria+Gonzalez&size=200&background=FF6B00&color=fff',
        'vote_count': 0,
      },
      {
        'name': 'Carlos Ramírez Torres',
        'proposal':
            'Establecer convenios con empresas para prácticas y fortalecer la biblioteca digital.',
        'image_url':
            'https://ui-avatars.com/api/?name=Carlos+Ramirez&size=200&background=10B981&color=fff',
        'vote_count': 0,
      },
      {
        'name': 'Ana Martínez Silva',
        'proposal':
            'Crear hackathons semestrales y un programa de mentoring con egresados.',
        'image_url':
            'https://ui-avatars.com/api/?name=Ana+Martinez&size=200&background=3B82F6&color=fff',
        'vote_count': 0,
      },
    ];

    for (var candidate in candidates) {
      await db.insert('candidates', candidate);
    }
  }

  // CRUD para Estudiantes
  Future<StudentModel> createStudent(StudentModel student) async {
    final db = await database;
    final id = await db.insert('students', student.toMap());
    return student.copyWith(id: id);
  }

  Future<StudentModel?> getStudentByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateStudent(StudentModel student) async {
    final db = await database;
    return db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // CRUD para Candidatos
  Future<List<CandidateModel>> getAllCandidates() async {
    final db = await database;
    final result = await db.query('candidates', orderBy: 'id ASC');
    return result.map((map) => CandidateModel.fromMap(map)).toList();
  }

  Future<CandidateModel?> getCandidateById(int id) async {
    final db = await database;
    final maps = await db.query('candidates', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return CandidateModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCandidateVoteCount(int candidateId, int increment) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE candidates SET vote_count = vote_count + ? WHERE id = ?',
      [increment, candidateId],
    );
  }

  // CRUD para Votos
  Future<VoteModel> createVote(VoteModel vote) async {
    final db = await database;
    final id = await db.insert('votes', vote.toMap());
    return vote.copyWith(id: id);
  }

  Future<List<VoteModel>> getAllVotes() async {
    final db = await database;
    final result = await db.query('votes', orderBy: 'voted_at DESC');
    return result.map((map) => VoteModel.fromMap(map)).toList();
  }

  Future<int> getTotalVotes() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM votes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<VoteModel?> getVoteByStudentId(int studentId) async {
    final db = await database;
    final maps = await db.query(
      'votes',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    if (maps.isNotEmpty) {
      return VoteModel.fromMap(maps.first);
    }
    return null;
  }

  // Método para registrar un voto completo (transacción)
  Future<bool> registerVote({
    required int studentId,
    required int candidateId,
    required String votedAt,
    required double latitude,
    required double longitude,
  }) async {
    final db = await database;

    try {
      await db.transaction((txn) async {
        // 1. Crear el voto
        await txn.insert('votes', {
          'student_id': studentId,
          'candidate_id': candidateId,
          'voted_at': votedAt,
          'latitude': latitude,
          'longitude': longitude,
        });

        // 2. Actualizar el estudiante
        await txn.update(
          'students',
          {
            'has_voted': 1,
            'voted_at': votedAt,
            'voted_candidate_id': candidateId,
          },
          where: 'id = ?',
          whereArgs: [studentId],
        );

        // 3. Incrementar el contador de votos del candidato
        await txn.rawUpdate(
          'UPDATE candidates SET vote_count = vote_count + 1 WHERE id = ?',
          [candidateId],
        );
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Método para borrar toda la base de datos (útil para desarrollo)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'voting_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
