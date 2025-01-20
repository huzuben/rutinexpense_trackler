import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/veritabani_yardimcisi.dart';
import 'ana_sayfa.dart';
import 'sifremi_unuttum_ekrani.dart';
import 'kayit_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani>
    with SingleTickerProviderStateMixin {
  final _kullaniciAdiController = TextEditingController();
  final _sifreController = TextEditingController();
  bool _yukleniyor = false;
  bool _beniHatirla = false;
  bool _sifreGizli = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final _veritabaniYardimcisi = VeritabaniYardimcisi();

  @override
  void initState() {
    super.initState();
    _kayitliKullaniciyiYukle();

    // Logo animasyonu için controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Ölçek animasyonu
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Animasyonu başlat
    _animationController.forward();
  }

  Future<void> _kayitliKullaniciyiYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final beniHatirla = prefs.getBool('beniHatirla') ?? false;

    if (beniHatirla) {
      final kayitliKullaniciAdi = prefs.getString('kayitliKullaniciAdi');
      final kayitliSifre = prefs.getString('kayitliSifre');

      if (kayitliKullaniciAdi != null && kayitliSifre != null) {
        setState(() {
          _kullaniciAdiController.text = kayitliKullaniciAdi;
          _sifreController.text = kayitliSifre;
          _beniHatirla = true;
        });
      }
    }
  }

  Future<void> _girisYap() async {
    setState(() {
      _yukleniyor = true;
    });

    final kullaniciAdi = _kullaniciAdiController.text;
    final sifre = _sifreController.text;

    if (kullaniciAdi.isEmpty || sifre.isEmpty) {
      setState(() {
        _yukleniyor = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı adı ve şifre gereklidir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final kullanici =
          await _veritabaniYardimcisi.kullaniciGetir(kullaniciAdi);

      if (kullanici == null) {
        if (!mounted) return;
        setState(() {
          _yukleniyor = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Kayıtlı kullanıcı bulunamadı. Lütfen kayıt olunuz.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Kayıt Ol',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KayitEkrani()),
                );
              },
            ),
          ),
        );
        return;
      }

      if (kullanici.sifre != sifre) {
        if (!mounted) return;
        setState(() {
          _yukleniyor = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre yanlış. Lütfen tekrar deneyiniz.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_beniHatirla) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('beniHatirla', true);
        await prefs.setString('kayitliKullaniciAdi', kullaniciAdi);
        await prefs.setString('kayitliSifre', sifre);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('beniHatirla', false);
        await prefs.remove('kayitliKullaniciAdi');
        await prefs.remove('kayitliSifre');
      }

      if (!mounted) return;
      setState(() {
        _yukleniyor = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnaSayfa()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _yukleniyor = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş yaparken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sifremiUnuttumEkraninaGit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SifremiUnuttumEkrani(),
      ),
    );
  }

  void _kayitEkraninaGit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const KayitEkrani(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171716),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Animasyonlu logo container
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: 600,
                  width: 600,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
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
                    tooltip: _sifreGizli ? 'Şifreyi göster' : 'Şifreyi gizle',
                  ),
                ),
                obscureText: _sifreGizli,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _beniHatirla,
                    onChanged: (value) {
                      setState(() {
                        _beniHatirla = value ?? false;
                      });
                    },
                    fillColor: MaterialStateProperty.resolveWith(
                      (states) => states.contains(MaterialState.selected)
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  const Text(
                    'Beni Hatırla',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _yukleniyor ? null : _girisYap,
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
                          'Giriş Yap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _sifremiUnuttumEkraninaGit,
                    child: const Text(
                      'Şifremi Unuttum',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: _kayitEkraninaGit,
                    child: const Text(
                      'Kayıt Ol',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _sifreController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
