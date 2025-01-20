enum IslemTipi { gelir, gider }

class Islem {
  final String id;
  final String baslik;
  final double miktar;
  final DateTime tarih;
  final String kategori;
  final IslemTipi tip;

  const Islem({
    required this.id,
    required this.baslik,
    required this.miktar,
    required this.tarih,
    required this.kategori,
    required this.tip,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baslik': baslik,
      'miktar': miktar,
      'tarih': tarih.toIso8601String(),
      'kategori': kategori,
      'tip': tip.toString(),
    };
  }

  factory Islem.fromMap(Map<String, dynamic> map) {
    return Islem(
      id: map['id'] as String,
      baslik: map['baslik'] as String,
      miktar: map['miktar'] as double,
      tarih: DateTime.parse(map['tarih'] as String),
      kategori: map['kategori'] as String,
      tip: map['tip'].toString().contains('gelir')
          ? IslemTipi.gelir
          : IslemTipi.gider,
    );
  }
}
