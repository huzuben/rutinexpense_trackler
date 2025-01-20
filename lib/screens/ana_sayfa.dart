import 'package:flutter/material.dart';
import '../helpers/veritabani_yardimcisi.dart';
import '../models/islem.dart';
import 'package:intl/intl.dart';
import 'giris_ekrani.dart';
import '../widgets/harcama_ekle.dart';
import '../widgets/harcama_listesi.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final _veritabaniYardimcisi = VeritabaniYardimcisi();
  List<Islem> _islemler = [];
  bool _yukleniyor = true;
  String? _secilenKategoriFiltresi;
  bool _tarihSiralamaAzalan = true;

  @override
  void initState() {
    super.initState();
    _islemleriYukle();
  }

  void _islemleriYukle() {
    _harcamalariYukle();
  }

  Future<void> _harcamalariYukle() async {
    try {
      final harcamalar = await _veritabaniYardimcisi.tumHarcamalariGetir();
      setState(() {
        _islemler.clear();
        _islemler.addAll(harcamalar);
        _yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        _yukleniyor = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harcamalar yüklenirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cikisYap() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const GirisEkrani(),
      ),
    );
  }

  List<Islem> get _filtrelenmisVeSiralanmisHarcamalar {
    List<Islem> harcamalar = List.from(_islemler);

    if (_secilenKategoriFiltresi != null) {
      harcamalar = harcamalar
          .where((h) => h.kategori == _secilenKategoriFiltresi)
          .toList();
    }

    harcamalar.sort((a, b) => _tarihSiralamaAzalan
        ? b.tarih.compareTo(a.tarih)
        : a.tarih.compareTo(b.tarih));

    return harcamalar;
  }

  Future<void> _harcamaEkle(Islem islem) async {
    try {
      await _veritabaniYardimcisi.harcamaEkle(islem);
      setState(() {
        _islemler.add(islem);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harcama eklenirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _harcamaSil(Islem islem) async {
    try {
      await _veritabaniYardimcisi.harcamaSil(islem.id);
      setState(() {
        _islemler.remove(islem);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harcama silinirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _harcamaEklePenceresiGoster() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => HarcamaEkle(islemEklendi: _harcamaEkle),
    );
  }

  double get _toplamGelir {
    return _islemler
        .where((islem) => islem.tip == IslemTipi.gelir)
        .fold(0, (toplam, islem) => toplam + islem.miktar);
  }

  double get _toplamGider {
    return _islemler
        .where((islem) => islem.tip == IslemTipi.gider)
        .fold(0, (toplam, islem) => toplam + islem.miktar);
  }

  double get _bakiye => _toplamGelir - _toplamGider;

  Map<String, double> get _kategoriToplam {
    final toplamlar = <String, double>{};
    for (final islem in _islemler.where((i) => i.tip == IslemTipi.gider)) {
      toplamlar[islem.kategori] =
          (toplamlar[islem.kategori] ?? 0) + islem.miktar;
    }
    return toplamlar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171716),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ana Sayfa',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _tarihSiralamaAzalan ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _tarihSiralamaAzalan = !_tarihSiralamaAzalan;
              });
            },
            tooltip: 'Tarihe göre sırala',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _cikisYap,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  color: Colors.green.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bakiye',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_bakiye.toStringAsFixed(2)} TL',
                          style: TextStyle(
                            color: _bakiye >= 0 ? Colors.green : Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Toplam Gelir',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${_toplamGelir.toStringAsFixed(2)} TL',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Toplam Gider',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${_toplamGider.toStringAsFixed(2)} TL',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_kategoriToplam.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.green.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Kategori Bazlı Harcamalar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              DropdownButton<String?>(
                                value: _secilenKategoriFiltresi,
                                dropdownColor: const Color(0xFF171716),
                                style: const TextStyle(color: Colors.white),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Tümü'),
                                  ),
                                  ..._kategoriToplam.keys.map(
                                    (kategori) => DropdownMenuItem(
                                      value: kategori,
                                      child: Text(kategori),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _secilenKategoriFiltresi = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...(_kategoriToplam.entries.map(
                            (giris) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    giris.key,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '${giris.value.toStringAsFixed(2)} TL',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: HarcamaListesi(
                    harcamalar: _filtrelenmisVeSiralanmisHarcamalar,
                    harcamaSil: _harcamaSil,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _harcamaEklePenceresiGoster,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
