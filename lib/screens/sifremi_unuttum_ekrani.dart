import 'package:flutter/material.dart';

class SifremiUnuttumEkrani extends StatefulWidget {
  const SifremiUnuttumEkrani({super.key});

  @override
  State<SifremiUnuttumEkrani> createState() => _SifremiUnuttumEkraniState();
}

class _SifremiUnuttumEkraniState extends State<SifremiUnuttumEkrani> {
  final _epostaController = TextEditingController();
  bool _yukleniyor = false;

  void _sifreyiSifirla() {
    final eposta = _epostaController.text;

    if (eposta.isEmpty || !eposta.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir e-posta adresi giriniz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _yukleniyor = true;
    });

    // Burada normalde şifre sıfırlama API'si çağrılır
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _yukleniyor = false;
      });

      // Başarılı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Şifre sıfırlama bağlantısı $eposta adresine gönderildi'),
          backgroundColor: Colors.green,
        ),
      );

      // Login ekranına geri dön
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Şifremi Unuttum'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Şifrenizi sıfırlamak için e-posta adresinizi girin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _epostaController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'E-posta',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: Icon(Icons.email, color: Colors.grey),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _yukleniyor ? null : _sifreyiSifirla,
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
                        'Şifremi Sıfırla',
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
    _epostaController.dispose();
    super.dispose();
  }
}
