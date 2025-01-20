import 'package:flutter/material.dart';
import '../models/islem.dart';
import 'package:intl/intl.dart';

class HarcamaEkle extends StatefulWidget {
  final ValueChanged<Islem> islemEklendi;

  const HarcamaEkle({
    super.key,
    required this.islemEklendi,
  });

  @override
  State<HarcamaEkle> createState() => _HarcamaEkleState();
}

class _HarcamaEkleState extends State<HarcamaEkle> {
  final _baslikController = TextEditingController();
  final _miktarController = TextEditingController();
  DateTime _secilenTarih = DateTime.now();
  String _secilenKategori = 'Diğer';
  IslemTipi _secilenTip = IslemTipi.gider;

  final List<String> _giderKategorileri = [
    'Yiyecek',
    'Ulaşım',
    'Alışveriş',
    'Faturalar',
    'Eğlence',
    'Sağlık',
    'Diğer',
  ];

  final List<String> _gelirKategorileri = [
    'Maaş',
    'Ek Gelir',
    'Hediye',
    'Yatırım',
    'Diğer',
  ];

  List<String> get _kategoriler =>
      _secilenTip == IslemTipi.gider ? _giderKategorileri : _gelirKategorileri;

  @override
  void initState() {
    super.initState();
    _secilenKategori = _kategoriler.first;
  }

  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: _secilenTarih,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Color(0xFF171716),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (secilen != null && secilen != _secilenTarih) {
      setState(() {
        _secilenTarih = secilen;
      });
    }
  }

  void _kaydet() {
    if (_baslikController.text.isEmpty ||
        _miktarController.text.isEmpty ||
        double.tryParse(_miktarController.text) == null) {
      return;
    }

    final yeniIslem = Islem(
      id: DateTime.now().toIso8601String(),
      baslik: _baslikController.text,
      miktar: double.parse(_miktarController.text),
      tarih: _secilenTarih,
      kategori: _secilenKategori,
      tip: _secilenTip,
    );

    widget.islemEklendi(yeniIslem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171716),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _secilenTip == IslemTipi.gider ? 'Gider Ekle' : 'Gelir Ekle',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<IslemTipi>(
                segments: const [
                  ButtonSegment<IslemTipi>(
                    value: IslemTipi.gider,
                    label: Text('Gider'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment<IslemTipi>(
                    value: IslemTipi.gelir,
                    label: Text('Gelir'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: {_secilenTip},
                onSelectionChanged: (Set<IslemTipi> newSelection) {
                  setState(() {
                    _secilenTip = newSelection.first;
                    _secilenKategori = _kategoriler.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return _secilenTip == IslemTipi.gider
                            ? Colors.red
                            : Colors.green;
                      }
                      return Colors.grey;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _baslikController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _miktarController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Miktar (TL)',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _secilenKategori,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF171716),
                    style: const TextStyle(color: Colors.white),
                    items: _kategoriler.map((String kategori) {
                      return DropdownMenuItem<String>(
                        value: kategori,
                        child: Text(kategori),
                      );
                    }).toList(),
                    onChanged: (String? yeniDeger) {
                      if (yeniDeger != null) {
                        setState(() {
                          _secilenKategori = yeniDeger;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _tarihSec(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_secilenTarih),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _kaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secilenTip == IslemTipi.gider
                      ? Colors.red
                      : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _secilenTip == IslemTipi.gider ? 'Gider Ekle' : 'Gelir Ekle',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _miktarController.dispose();
    super.dispose();
  }
}
