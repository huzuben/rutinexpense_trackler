import 'package:flutter/material.dart';
import '../models/islem.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
  final _uuid = const Uuid();

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

  void _kaydet() {
    if (_baslikController.text.isEmpty ||
        _miktarController.text.isEmpty ||
        double.tryParse(_miktarController.text) == null) {
      return;
    }

    final yeniIslem = Islem(
      id: _uuid.v4(),
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
    final aktifKategoriler = _secilenTip == IslemTipi.gelir
        ? _gelirKategorileri
        : _giderKategorileri;

    if (!aktifKategoriler.contains(_secilenKategori)) {
      _secilenKategori = aktifKategoriler.first;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _secilenTip == IslemTipi.gelir ? 'Gelir Ekle' : 'Gider Ekle',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<IslemTipi>(
                segments: const [
                  ButtonSegment(
                    value: IslemTipi.gelir,
                    label: Text('Gelir'),
                    icon: Icon(Icons.add),
                  ),
                  ButtonSegment(
                    value: IslemTipi.gider,
                    label: Text('Gider'),
                    icon: Icon(Icons.remove),
                  ),
                ],
                selected: {_secilenTip},
                onSelectionChanged: (Set<IslemTipi> newSelection) {
                  setState(() {
                    _secilenTip = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => states.contains(MaterialState.selected)
                        ? Colors.green
                        : Colors.grey[800]!,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _baslikController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _miktarController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tutar',
                  suffixText: 'TL',
                  suffixStyle: TextStyle(color: Colors.grey),
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _secilenTarih,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Colors.green,
                            surface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _secilenTarih = pickedDate;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[800]!,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tarih',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_secilenTarih),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _secilenKategori,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                items: aktifKategoriler.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _secilenKategori = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'İptal',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _kaydet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ekle'),
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
    _baslikController.dispose();
    _miktarController.dispose();
    super.dispose();
  }
}
