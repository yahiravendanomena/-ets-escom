import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../exams/domain/entities/exam.dart';
import '../../../exams/presentation/providers/exams_notifier.dart';

/// Formulario para crear o editar un ETS.
class ExamFormPage extends ConsumerStatefulWidget {
  final Exam? examToEdit;

  const ExamFormPage({super.key, this.examToEdit});

  @override
  ConsumerState<ExamFormPage> createState() => _ExamFormPageState();
}

class _ExamFormPageState extends ConsumerState<ExamFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _classroomController = TextEditingController();
  final _buildingController = TextEditingController();
  final _professorController = TextEditingController();

  String _selectedCareer = 'ISC';
  int _selectedSemester = 1;
  ExamShift _selectedShift = ExamShift.matutino;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  bool get _isEditing => widget.examToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.examToEdit!;
      _subjectController.text = e.subject;
      _classroomController.text = e.classroom;
      _buildingController.text = e.building;
      _professorController.text = e.professor;
      _selectedCareer = e.careerCode;
      _selectedSemester = e.semester;
      _selectedShift = e.shift;
      _selectedDate = e.date;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _classroomController.dispose();
    _buildingController.dispose();
    _professorController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'MX'),
    );
    if (picked == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final exam = Exam(
      id: _isEditing
          ? widget.examToEdit!.id
          : 'ets-${DateTime.now().millisecondsSinceEpoch}',
      subject: _subjectController.text.trim(),
      careerCode: _selectedCareer,
      semester: _selectedSemester,
      date: _selectedDate,
      shift: _selectedShift,
      classroom: _classroomController.text.trim(),
      building: _buildingController.text.trim(),
      professor: _professorController.text.trim(),
    );

    final notifier = ref.read(examsProvider.notifier);
    final success = _isEditing
        ? await notifier.updateExam(exam)
        : await notifier.createExam(exam);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'ETS actualizado ✅' : 'ETS creado correctamente ✅',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar. Intenta de nuevo.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("d 'de' MMMM 'de' y", 'es_MX');
    final timeFormat = DateFormat('h:mm a', 'es_MX');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar ETS' : 'Nuevo ETS'),
        backgroundColor: AppColors.adminGreen,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Materia.
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Materia',
                prefixIcon: Icon(Icons.book_outlined),
                hintText: 'Ej. Cálculo Vectorial',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'La materia es requerida'
                  : null,
            ),
            const SizedBox(height: 16),

            // Carrera.
            DropdownButtonFormField<String>(
              initialValue: _selectedCareer,
              decoration: const InputDecoration(
                labelText: 'Carrera',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'ISC', child: Text('ISC')),
                DropdownMenuItem(value: 'IIA', child: Text('IIA')),
                DropdownMenuItem(value: 'LCD', child: Text('LCD')),
              ],
              onChanged: (v) => setState(() => _selectedCareer = v!),
            ),
            const SizedBox(height: 16),

            // Semestre.
            DropdownButtonFormField<int>(
              initialValue: _selectedSemester,
              decoration: const InputDecoration(
                labelText: 'Semestre',
                prefixIcon: Icon(Icons.numbers_outlined),
              ),
              items: List.generate(9, (i) => i + 1)
                  .map((s) => DropdownMenuItem(value: s, child: Text('$s°')))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSemester = v!),
            ),
            const SizedBox(height: 16),

            // Fecha y hora.
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: AppColors.adminGreen),
                title: Text(dateFormat.format(_selectedDate)),
                subtitle: Text('Hora: ${timeFormat.format(_selectedDate)}'),
                trailing: const Icon(Icons.edit_outlined),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 16),

            // Turno.
            DropdownButtonFormField<ExamShift>(
              initialValue: _selectedShift,
              decoration: const InputDecoration(
                labelText: 'Turno',
                prefixIcon: Icon(Icons.wb_sunny_outlined),
              ),
              items: ExamShift.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedShift = v!),
            ),
            const SizedBox(height: 16),

            // Edificio.
            TextFormField(
              controller: _buildingController,
              decoration: const InputDecoration(
                labelText: 'Edificio',
                prefixIcon: Icon(Icons.business_outlined),
                hintText: 'Ej. Edificio 3',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            // Salón.
            TextFormField(
              controller: _classroomController,
              decoration: const InputDecoration(
                labelText: 'Salón',
                prefixIcon: Icon(Icons.meeting_room_outlined),
                hintText: 'Ej. 3203',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            // Profesor.
            TextFormField(
              controller: _professorController,
              decoration: const InputDecoration(
                labelText: 'Profesor evaluador',
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'Ej. Dr. Hernández López',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 32),

            // Botón guardar.
            ElevatedButton.icon(
              onPressed: _save,
              icon: Icon(_isEditing ? Icons.save : Icons.add),
              label: Text(_isEditing ? 'Guardar cambios' : 'Crear ETS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adminGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}