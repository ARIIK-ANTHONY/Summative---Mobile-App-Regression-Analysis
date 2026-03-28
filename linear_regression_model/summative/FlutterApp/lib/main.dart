import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// App entry point.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Score Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6E6E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0B6E6E), width: 1.7),
          ),
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ),
      home: const PredictionDashboardPage(),
    );
  }
}

class PredictionDashboardPage extends StatefulWidget {
  const PredictionDashboardPage({super.key});

  @override
  State<PredictionDashboardPage> createState() =>
      _PredictionDashboardPageState();
}

class _PredictionDashboardPageState extends State<PredictionDashboardPage> {
  // Deployment-friendly API config: inject with --dart-define at runtime.
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://summative-mobile-app-regression-analysis-2rfp.onrender.com',
  );

  // Build the prediction endpoint from the configured base URL.
  static String get apiUrl {
    final normalizedBase = _apiBaseUrl.endsWith('/')
        ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
        : _apiBaseUrl;
    return '$normalizedBase/predict';
  }

  final _formKey = GlobalKey<FormState>();

  final _hoursStudied = TextEditingController();
  final _attendance = TextEditingController();
  final _parentalInvolvement = TextEditingController();
  final _accessToResources = TextEditingController();
  final _extracurricular = TextEditingController();
  final _previousScores = TextEditingController();
  final _motivationLevel = TextEditingController();
  final _internetAccess = TextEditingController();
  final _tutoringSessions = TextEditingController();
  final _familyIncome = TextEditingController();
  final _teacherQuality = TextEditingController();
  final _peerInfluence = TextEditingController();
  final _learningDisabilities = TextEditingController();
  final _parentalEducation = TextEditingController();
  final _distanceFromHome = TextEditingController();

  String _result = '';
  bool _loading = false;
  bool _isError = false;
  double? _predictedScore;

  // Controller cleanup to prevent memory leaks.
  @override
  void dispose() {
    _hoursStudied.dispose();
    _attendance.dispose();
    _parentalInvolvement.dispose();
    _accessToResources.dispose();
    _extracurricular.dispose();
    _previousScores.dispose();
    _motivationLevel.dispose();
    _internetAccess.dispose();
    _tutoringSessions.dispose();
    _familyIncome.dispose();
    _teacherQuality.dispose();
    _peerInfluence.dispose();
    _learningDisabilities.dispose();
    _parentalEducation.dispose();
    _distanceFromHome.dispose();
    super.dispose();
  }

  // Tracks form completion for the dashboard card.
  int get _filledCount {
    final controllers = [
      _hoursStudied,
      _attendance,
      _parentalInvolvement,
      _accessToResources,
      _extracurricular,
      _previousScores,
      _motivationLevel,
      _internetAccess,
      _tutoringSessions,
      _familyIncome,
      _teacherQuality,
      _peerInfluence,
      _learningDisabilities,
      _parentalEducation,
      _distanceFromHome,
    ];
    return controllers.where((c) => c.text.trim().isNotEmpty).length;
  }

  // Validates input, calls the API, and updates UI state with the result.
  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _result = '';
      _isError = false;
    });

    try {
      final body = {
        'Hours_Studied': int.parse(_hoursStudied.text.trim()),
        'Attendance': int.parse(_attendance.text.trim()),
        'Parental_Involvement': int.parse(_parentalInvolvement.text.trim()),
        'Access_to_Resources': int.parse(_accessToResources.text.trim()),
        'Extracurricular_Activities': int.parse(_extracurricular.text.trim()),
        'Previous_Scores': int.parse(_previousScores.text.trim()),
        'Motivation_Level': int.parse(_motivationLevel.text.trim()),
        'Internet_Access': int.parse(_internetAccess.text.trim()),
        'Tutoring_Sessions': int.parse(_tutoringSessions.text.trim()),
        'Family_Income': int.parse(_familyIncome.text.trim()),
        'Teacher_Quality': int.parse(_teacherQuality.text.trim()),
        'Peer_Influence': int.parse(_peerInfluence.text.trim()),
        'Learning_Disabilities': int.parse(_learningDisabilities.text.trim()),
        'Parental_Education_Level': int.parse(_parentalEducation.text.trim()),
        'Distance_from_Home': int.parse(_distanceFromHome.text.trim()),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final score = (data['predicted_exam_score'] as num).toDouble();
        setState(() {
          _predictedScore = score;
          _result = 'Predicted Exam Score: ${score.toStringAsFixed(2)} / 100';
          _isError = false;
        });
      } else if (response.statusCode == 422) {
        setState(() {
          _result = 'One or more values are out of accepted range.';
          _isError = true;
        });
      } else {
        setState(() {
          _result = 'Server error (${response.statusCode}).';
          _isError = true;
        });
      }
    } catch (_) {
      setState(() {
        _result = 'Could not reach server. Check internet/API URL.';
        _isError = true;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  // Reusable numeric input field with per-feature validation rules.
  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int min,
    required int max,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: false,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: '$min-$max',
          suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) return '$label is required';
          final n = int.tryParse(val.trim());
          if (n == null) return 'Enter a whole number';
          if (n < min || n > max) return 'Must be between $min and $max';
          return null;
        },
      ),
    );
  }

  // Small metric cards shown in the horizontal dashboard row.
  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable section wrapper used for grouped inputs.
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF0B6E6E)),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // Main page layout.
  @override
  Widget build(BuildContext context) {
    final completion = '$_filledCount/15';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6FFFA), Color(0xFFF4F7FB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              14,
              14,
              14,
              14 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B6E6E), Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Performance Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Enter 15 factors, run prediction, and review score instantly.',
                          style: TextStyle(
                            color: Color(0xFFCCFBF1),
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'All 15 fields are required. Use the ranges shown on the right.',
                          style: TextStyle(
                            color: Color(0xFF99F6E4),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _dashboardCard(
                          title: 'Form Completion',
                          value: completion,
                          icon: Icons.checklist_rounded,
                          color: const Color(0xFF0B6E6E),
                        ),
                        const SizedBox(width: 10),
                        _dashboardCard(
                          title: 'API Endpoint',
                          value: _apiBaseUrl.trim().isEmpty
                              ? 'Not Configured'
                              : _apiBaseUrl,
                          icon: Icons.cloud_done_rounded,
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 10),
                        _dashboardCard(
                          title: 'Last Score',
                          value: _predictedScore == null
                              ? '--'
                              : _predictedScore!.toStringAsFixed(2),
                          icon: Icons.auto_graph_rounded,
                          color: const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'Study Habits',
                    icon: Icons.menu_book_rounded,
                    children: [
                      _field(
                        controller: _hoursStudied,
                        label: 'Hours Studied per Week',
                        hint: 'e.g. 20',
                        min: 1,
                        max: 44,
                      ),
                      _field(
                        controller: _attendance,
                        label: 'Attendance (%)',
                        hint: 'e.g. 85',
                        min: 0,
                        max: 100,
                      ),
                      _field(
                        controller: _previousScores,
                        label: 'Previous Scores',
                        hint: 'e.g. 75',
                        min: 0,
                        max: 100,
                      ),
                      _field(
                        controller: _tutoringSessions,
                        label: 'Tutoring Sessions per Week',
                        hint: 'e.g. 2',
                        min: 0,
                        max: 8,
                      ),
                      _field(
                        controller: _extracurricular,
                        label: 'Extracurricular Activities',
                        hint: '0 = No, 1 = Yes',
                        min: 0,
                        max: 1,
                      ),
                    ],
                  ),
                  _sectionCard(
                    title: 'Student Background',
                    icon: Icons.person_rounded,
                    children: [
                      _field(
                        controller: _motivationLevel,
                        label: 'Motivation Level',
                        hint: '0=Low 1=Medium 2=High',
                        min: 0,
                        max: 2,
                      ),
                      _field(
                        controller: _internetAccess,
                        label: 'Internet Access',
                        hint: '0 = No, 1 = Yes',
                        min: 0,
                        max: 1,
                      ),
                      _field(
                        controller: _learningDisabilities,
                        label: 'Learning Disabilities',
                        hint: '0 = No, 1 = Yes',
                        min: 0,
                        max: 1,
                      ),
                      _field(
                        controller: _peerInfluence,
                        label: 'Peer Influence',
                        hint: '0=Negative 1=Neutral 2=Positive',
                        min: 0,
                        max: 2,
                      ),
                    ],
                  ),
                  _sectionCard(
                    title: 'Family and School',
                    icon: Icons.apartment_rounded,
                    children: [
                      _field(
                        controller: _parentalInvolvement,
                        label: 'Parental Involvement',
                        hint: '0=Low 1=Medium 2=High',
                        min: 0,
                        max: 2,
                      ),
                      _field(
                        controller: _accessToResources,
                        label: 'Access to Resources',
                        hint: '0=Low 1=Medium 2=High',
                        min: 0,
                        max: 2,
                      ),
                      _field(
                        controller: _familyIncome,
                        label: 'Family Income',
                        hint: '0=Low 1=Medium 2=High',
                        min: 0,
                        max: 2,
                      ),
                      _field(
                        controller: _teacherQuality,
                        label: 'Teacher Quality',
                        hint: '0=Low 1=Medium 2=High',
                        min: 0,
                        max: 2,
                      ),
                      _field(
                        controller: _parentalEducation,
                        label: 'Parental Education Level',
                        hint: '0=High School 1=College 2=Postgraduate',
                        min: 0,
                        max: 2,
                      ),
                      _field(
                        controller: _distanceFromHome,
                        label: 'Distance from Home',
                        hint: '0=Far 1=Moderate 2=Near',
                        min: 0,
                        max: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _predict,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B6E6E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.insights_rounded),
                      label: Text(
                        _loading ? 'Predicting...' : 'Predict',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_result.isNotEmpty)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isError
                            ? const Color(0xFFFFF1F2)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isError
                              ? const Color(0xFFFDA4AF)
                              : const Color(0xFF6EE7B7),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _isError
                                ? Icons.error_outline_rounded
                                : Icons.check_circle_outline_rounded,
                            color: _isError
                                ? const Color(0xFFBE123C)
                                : const Color(0xFF047857),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _result,
                              style: TextStyle(
                                color: _isError
                                    ? const Color(0xFF9F1239)
                                    : const Color(0xFF065F46),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
