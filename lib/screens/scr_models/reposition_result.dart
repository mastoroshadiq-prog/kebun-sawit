class ReposisiResult {
  final String idTanaman;
  final bool success;
  final String message;
  final String flag;
  final String barisAwal;
  final String pohonAwal;
  final int pohonIndex;

  ReposisiResult({
    required this.idTanaman,
    required this.success,
    required this.message,
    required this.flag,
    required this.barisAwal,
    required this.pohonAwal,
    required this.pohonIndex,
  });
}
