import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/course.dart';
import '../data/mock/mock_data.dart';

final courseActiveProvider = StateProvider<Course?>((ref) => null);

final historiqueProvider = Provider<List<Course>>((ref) => mockHistorique);

class CourseNotifier extends StateNotifier<Course?> {
  CourseNotifier() : super(null);

  void demarrerCourse(Course course) => state = course;

  void avancerStatut() {
    if (state == null) return;
    final next = _nextStatut(state!.statut);
    if (next != null) {
      state = Course(
        id: state!.id,
        adresseDepart: state!.adresseDepart,
        adresseDestination: state!.adresseDestination,
        poids: state!.poids,
        prix: state!.prix,
        statut: next,
        livreurNom: state!.livreurNom,
        livreurTelephone: state!.livreurTelephone,
        createdAt: state!.createdAt,
      );
    }
  }

  StatutCourse? _nextStatut(StatutCourse current) {
    switch (current) {
      case StatutCourse.enAttente:
        return StatutCourse.acceptee;
      case StatutCourse.acceptee:
        return StatutCourse.enCours;
      case StatutCourse.enCours:
        return StatutCourse.livree;
      default:
        return null;
    }
  }
}

final courseNotifierProvider = StateNotifierProvider<CourseNotifier, Course?>(
  (ref) => CourseNotifier(),
);
