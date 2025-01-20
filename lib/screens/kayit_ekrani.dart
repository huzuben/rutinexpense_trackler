import 'package:flutter/material.dart';
import '../helpers/veritabani_yardimcisi.dart';
import '../models/kullanici.dart';
import 'giris_ekrani.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _kullaniciAdiController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();
  bool _yukleniyor = false;
  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;
  final _veritabaniYardimcisi = VeritabaniYardimcisi();

  Future<void> _kayitOl() async {
    setState(() {
      _yukleniyor = true;
    });

    final kullaniciAdi = _kullaniciAdiController.text;
    final sifre = _sifreController.text;
    final sifreTekrar = _sifreTekrarController.text;

    if (kullaniciAdi.isEmpty || sifre.isEmpty || sifreTekrar.isEmpty) {
      setState(() {
        _yukleniyor = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm alanları doldurunuz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (sifre != sifreTekrar) {
      setState(() {
        _yukleniyor = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreler eşleşmiyor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final mevcutKullanici =
          await _veritabaniYardimcisi.kullaniciGetir(kullaniciAdi);
      if (mevcutKullanici != null) {
        if (!mounted) return;
        setState(() {
          _yukleniyor = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu kullanıcı adı zaten kullanılıyor'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final yeniKullanici = Kullanici(
        id: DateTime.now().toIso8601String(),
        kullaniciAdi: kullaniciAdi,
        sifre: sifre,
        kayitTarihi: DateTime.now(),
      );

      await _veritabaniYardimcisi.kullaniciEkle(yeniKullanici);

      if (!mounted) return;
      setState(() {
        _yukleniyor = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GirisEkrani()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _yukleniyor = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt olurken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171716),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kayıt Ol',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _kullaniciAdiController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Adı',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: Icon(Icons.person, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sifreController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Şifre',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _sifreGizli ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _sifreGizli = !_sifreGizli;
                    });
                  },
                ),
              ),
              obscureText: _sifreGizli,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sifreTekrarController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Şifre Tekrar',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _sifreTekrarGizli ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _sifreTekrarGizli = !_sifreTekrarGizli;
                    });
                  },
                ),
              ),
              obscureText: _sifreTekrarGizli,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _yukleniyor ? null : _kayitOl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _yukleniyor
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    super.dispose();
  }
}
