/// 4500 -> "4 500"
String formatNombre(int n) {
  final s = n.abs().toString();
  final buffer = StringBuffer(n < 0 ? '-' : '');
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(s[i]);
  }
  return buffer.toString();
}

/// 4500 -> "4 500 FCFA"
String formatFcfa(int montant) => '${formatNombre(montant)} FCFA';

/// 3.0 -> "3 kg", 1.5 -> "1,5 kg"
String formatPoids(double kg) {
  final s = kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toString().replaceAll('.', ',');
  return '$s kg';
}

/// "+241077000001" -> "+241 077 00 00 01" (9 chiffres, groupes 3-2-2-2)
String formatTelephone(String telephone) {
  if (!telephone.startsWith('+241')) return telephone;
  final digits = telephone.substring(4);
  final buffer = StringBuffer('+241 ');
  final premier = digits.length.isOdd ? 3 : 2;
  for (int i = 0; i < digits.length; i++) {
    if (i >= premier && (i - premier) % 2 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// "Jean-Pierre Moussavou" -> "JM"
String initiales(String nom) {
  final mots = nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
  if (mots.isEmpty) return '';
  if (mots.length == 1) return mots.first[0].toUpperCase();
  return (mots.first[0] + mots.last[0]).toUpperCase();
}

const _mois = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];

/// 2026-10-02 14:05 -> "2 oct. à 14h05"
String formatDate(DateTime date) {
  final minutes = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${_mois[date.month - 1]} à ${date.hour}h$minutes';
}
