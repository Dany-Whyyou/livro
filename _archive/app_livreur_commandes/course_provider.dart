import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/course.dart';
import '../data/mock/mock_data.dart';

final courseActiveProvider = StateNotifierProvider<CourseActiveNotifier, Course?>(
  (ref) => CourseActiveNotifier(),
);

class CourseActiveNotifier extends StateNotifier<Course?> {
  CourseActiveNotifier() : super(null);

  void accepter(Course course) {
    state = course.copyWith(statut: StatutCourse.acceptee);
  }

  void avancer() {
    if (state == null) return;
    final next = _next(state!.statut);
    if (next != null) state = state!.copyWith(statut: next);
  }

  void terminer() => state = null;

  StatutCourse? _next(StatutCourse s) {
    switch (s) {
      case StatutCourse.acceptee:
        return StatutCourse.enCours;
      case StatutCourse.enCours:
        return StatutCourse.livree;
      default:
        return null;
    }
  }
}

final nouvellesCoursesMockProvider = Provider<List<Course>>(
  (ref) => mockNouvellesCourses,
);

final historiqueLivreurProvider = Provider<List<Course>>(
  (ref) => mockHistoriqueLivreur,
);
