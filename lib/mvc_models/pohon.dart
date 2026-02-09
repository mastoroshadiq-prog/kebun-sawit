// models/Pohon.dart
class Pohon {
  final String blok;
  final String nbaris;
  final String npohon;
  final String objectId;
  final String status;
  final String nflag;

  const Pohon({
    required this.blok,
    required this.nbaris,
    required this.npohon,
    required this.objectId,
    required this.status,
    required this.nflag,
  });

  Map<String, dynamic> toMap() {
    return {
      'blok': blok,
      'nbaris': nbaris,
      'npohon': npohon,
      'objectId': objectId,
      'status': status,
      'nflag': nflag,
    };
  }

  factory Pohon.fromMap(Map<String, dynamic> map) {
    return Pohon(
      blok: map['blok'] ?? '',
      nbaris: map['nbaris'] ?? '',
      npohon: map['npohon'] ?? '',
      objectId: map['objectId'] ?? '',
      status: map['status'] ?? '',
      nflag: map['nflag'] ?? '',
    );
  }

  factory Pohon.virtual(String blok, int baris, int nomor) {
    return Pohon(
      blok: blok,
      status: '1',
      objectId: 'V-$baris-$nomor',
      npohon: nomor.toString(),
      nbaris: baris.toString(),
      nflag: '9',              // kode khusus kosong
    );
  }
}



// --- 1️⃣ Kelompokkan berdasarkan nbaris
Map<String, List<Pohon>> groupByBaris(List<Pohon> pohonList) {
  final Map<String, List<Pohon>> grouped = {};
  for (var pohon in pohonList) {
    grouped.putIfAbsent(pohon.nbaris, () => []);
    grouped[pohon.nbaris]!.add(pohon);
  }
  return grouped;
}

// --- 2️⃣ Bangun data grid
List<List<Map<String, dynamic>>> generateDataGrid(
    List<String> barisList,
    List<Pohon> pohonList,
    ) {
  final grouped = groupByBaris(pohonList);
  final List<List<Map<String, dynamic>>> result = [];

  for (var baris in barisList) {
    final pohonBaris = grouped[baris] ?? [];

    if (pohonBaris.isEmpty) {
      result.add([]); // jika baris tidak punya pohon
      continue;
    }

    // urutkan berdasarkan nomor pohon
    pohonBaris.sort((a, b) => int.parse(a.npohon).compareTo(int.parse(b.npohon)));

    // cari range npohon (misal 1–40)
    final minNo = int.parse(pohonBaris.first.npohon);
    final maxNo = int.parse(pohonBaris.last.npohon);

    // buat grid sesuai range
    final rowGrid = <Map<String, dynamic>>[];
    for (int i = maxNo; i >= minNo; i--) {
      final found = pohonBaris.firstWhere(
            (p) => int.parse(p.npohon) == i,
        orElse: () => Pohon(
          blok: '',
          nbaris: baris,
          npohon: '',
          objectId: '',
          status: '',
          nflag: '',
        ),
      );

      if (found.npohon.isNotEmpty) {
        rowGrid.add({'no': i, 'hasTree': true});
      } else {
        rowGrid.add({'no': null, 'hasTree': false});
      }
    }

    result.add(rowGrid);
  }

  return result;
}
/*
Map<String, List<Pohon>> groupByBaris(List<Pohon> pohonList) {
  final Map<String, List<Pohon>> grouped = {};
  for (var pohon in pohonList) {
    grouped.putIfAbsent(pohon.nbaris, () => []);
    grouped[pohon.nbaris]!.add(pohon);
  }
  return grouped;
}
*/

List<List<Map<String, dynamic>>> generateVerticalGrid(
    List<String> barisList,
    List<Pohon> pohonList,
    ) {
  final grouped = groupByBaris(pohonList);

  final List<List<Map<String, dynamic>>> result = [];

  for (var baris in barisList) {
    final pohonBaris = grouped[baris] ?? [];

    // urutkan sesuai nomor pohon (npohon)
    pohonBaris.sort((a, b) => int.parse(a.npohon).compareTo(int.parse(b.npohon)));

    // ambil semua npohon yang ada
    //final existingNos = pohonBaris.map((p) => int.parse(p.npohon)).toList();

    // Misal kamu tahu jumlah slot (misal 3 slot)
    // atau bisa disesuaikan dengan max-min npohon
    //final maxNo = existingNos.isEmpty ? 0 : existingNos.reduce((a, b) => a > b ? a : b);
    //final minNo = existingNos.isEmpty ? 0 : existingNos.reduce((a, b) => a < b ? a : b);

    // kita bikin grid manual sesuai pola gambar
    final column = <Map<String, dynamic>>[];

    // dalam contoh gambar ada 3 baris pohon (atas ke bawah)
    for (var i = 0; i < 3; i++) {
      // ambil data pohon jika ada
      final pohon = i < pohonBaris.length ? pohonBaris[i] : null;
      if (pohon != null) {
        column.add({'no': int.parse(pohon.npohon), 'hasTree': true});
      } else {
        column.add({'no': null, 'hasTree': false});
      }
    }

    result.add(column);
  }

  return result;
}

// Fungsi utama
List<List<Map<String, dynamic>>> generateHorizontalGrid(
    List<String> barisList,
    List<Pohon> pohonList,
    ) {
  final grouped = groupByBaris(pohonList);

  // pastikan tiap baris diurutkan berdasarkan npohon
  for (var entry in grouped.entries) {
    entry.value.sort((a, b) => int.parse(b.npohon).compareTo(int.parse(a.npohon)));
  }

  // hitung jumlah baris vertikal paling banyak
  final maxLength = grouped.values.fold<int>(
    0,
        (prev, list) => list.length > prev ? list.length : prev,
  );

  // Buat list hasil akhir (baris ke bawah)
  final List<List<Map<String, dynamic>>> grid = [];

  for (int i = 0; i < maxLength; i++) {
    final row = <Map<String, dynamic>>[];

    for (var baris in barisList) {
      final pohonBaris = grouped[baris] ?? [];
      if (i < pohonBaris.length) {
        final p = pohonBaris[i];
        row.add({'no': int.parse(p.npohon), 'hasTree': true});
      } else {
        row.add({'no': null, 'hasTree': false});
      }
    }

    grid.add(row);
  }

  return grid;
}

List<List<Map<String, dynamic>>> generateNumberAlignedGrid(
    List<String> barisList,
    List<Pohon> pohonList,
    ) {
  // group per baris, and make a set of all numbers found
  final Map<String, Set<int>> groupedNos = {};
  final Set<int> allNos = {};

  for (var p in pohonList) {
    int? n;
    try {
      n = int.parse(p.npohon);
    } catch (e) {
      continue; // skip non-numeric
    }
    groupedNos.putIfAbsent(p.nbaris, () => <int>{});
    groupedNos[p.nbaris]!.add(n);
    allNos.add(n);
  }

  if (allNos.isEmpty) return [];

  // sort all numbers descending (tampilan dari atas ke bawah besar -> kecil)
  final sortedNosDesc = allNos.toList()..sort((a, b) => b.compareTo(a));

  final List<List<Map<String, dynamic>>> grid = [];

  // Untuk tiap nomor (row), bangun kolom sesuai barisList
  for (var no in sortedNosDesc) {
    final row = <Map<String, dynamic>>[];
    for (var baris in barisList) {
      final has = groupedNos[baris]?.contains(no) ?? false;
      if (has) {
        row.add({'no': no, 'hasTree': true});
      } else {
        row.add({'no': null, 'hasTree': false});
      }
    }

    // optional: hanya tambahkan baris yang setidaknya ada satu pohon
    final anyTree = row.any((cell) => cell['hasTree'] == true);
    if (anyTree) grid.add(row);
  }

  return grid;
}
