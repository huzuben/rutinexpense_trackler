class Kullanici {
  final String id;
  final String kullaniciAdi;
  final String sifre;
  final DateTime kayitTarihi;

  const Kullanici({
    required this.id,
    required this.kullaniciAdi,
    required this.sifre,
    required this.kayitTarihi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kullaniciAdi': kullaniciAdi,
      'sifre': sifre,
      'kayitTarihi': kayitTarihi.toIso8601String(),
    };
  }

  factory Kullanici.fromMap(Map<String, dynamic> map) {
    return Kullanici(
      id: map['id'] as String,
      kullaniciAdi: map['kullaniciAdi'] as String,
      sifre: map['sifre'] as String,
      kayitTarihi: DateTime.parse(map['kayitTarihi'] as String),
    );
  }
}
