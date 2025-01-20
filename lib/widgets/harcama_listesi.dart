import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/islem.dart';

class HarcamaListesi extends StatelessWidget {
  final List<Islem> harcamalar;
  final Function(Islem) harcamaSil;

  const HarcamaListesi({
    super.key,
    required this.harcamalar,
    required this.harcamaSil,
  });

  @override
  Widget build(BuildContext context) {
    if (harcamalar.isEmpty) {
      return const Center(
        child: Text(
          'Henüz hiç işlem eklenmemiş.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: harcamalar.length,
      itemBuilder: (context, index) {
        final islem = harcamalar[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.green.withOpacity(0.1),
          child: ListTile(
            title: Text(
              islem.baslik,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${islem.kategori} - ${DateFormat('dd/MM/yyyy').format(islem.tarih)}',
              style: TextStyle(
                color: Colors.grey[400],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${islem.tip == IslemTipi.gelir ? '+' : '-'}${islem.miktar.toStringAsFixed(2)} TL',
                  style: TextStyle(
                    color: islem.tip == IslemTipi.gelir
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => harcamaSil(islem),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
