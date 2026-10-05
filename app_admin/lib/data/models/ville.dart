/// Les neuf provinces du Gabon.
const provinces = ['Estuaire', 'Haut-Ogooué', 'Moyen-Ogooué', 'Ngounié', 'Nyanga', 'Ogooué-Ivindo', 'Ogooué-Lolo', 'Ogooué-Maritime', 'Woleu-Ntem'];

class Ville {
  final String id;
  final String nom;
  final String province;

  const Ville({required this.id, required this.nom, required this.province});
}
