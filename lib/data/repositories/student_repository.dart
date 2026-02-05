import '../database/database_helper.dart';
import '../models/student_model.dart';

class StudentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Crea o recupera un estudiante por email
  Future<StudentModel> getOrCreateStudent(
    String email,
    String studentCode,
  ) async {
    // Verificar si ya existe
    final existingStudent = await _dbHelper.getStudentByEmail(email);

    if (existingStudent != null) {
      return existingStudent;
    }

    // Crear nuevo estudiante
    final newStudent = StudentModel(email: email, studentCode: studentCode);

    return await _dbHelper.createStudent(newStudent);
  }

  /// Verifica si un estudiante ya votó
  Future<bool> hasVoted(String email) async {
    final student = await _dbHelper.getStudentByEmail(email);
    return student?.hasVoted ?? false;
  }

  /// Obtiene un estudiante por email
  Future<StudentModel?> getStudentByEmail(String email) async {
    return await _dbHelper.getStudentByEmail(email);
  }

  /// Actualiza la información de un estudiante
  Future<bool> updateStudent(StudentModel student) async {
    final result = await _dbHelper.updateStudent(student);
    return result > 0;
  }
}
