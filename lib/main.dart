import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(colorSchemeSeed: const Color(0xFF6B4028), scaffoldBackgroundColor: const Color(0xFFFAF3E8)), home: const IcecreamApp()));

class IcecreamApp extends StatefulWidget {
  const IcecreamApp({super.key});
  @override
  State<IcecreamApp> createState() => _IcecreamAppState();
}

class _IcecreamAppState extends State<IcecreamApp> {
  final foods = {
    'アールグレイ': 400,
    'レディグレイ': 450,
    'イングリッシュブレックファスト': 400,
    'ダージリン': 500,
    'プリンス オブ ウェールズ': 450,
  };
  late String food = foods.keys.first;
  String deco = '標準';
  final fruits = <String>{};
  int order = 0;
  bool spoon = false, napkin = false;
  String receipt = '';

  Widget choices(
    Iterable<String> items,
    String value,
    void Function(String) change,
  ) => Wrap(
    spacing: 6,
    children: [
      for (final s in items)
        ChoiceChip(
          label: Text(s),
          selected: value == s,
          onSelected: (_) => setState(() => change(s)),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final subtotal = foods[food]! + fruits.length * 50;
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;
    final photo = Text(
      food,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
    final products = choices(
      foods.keys.map((s) => '$s  ${foods[s]}円'),
      '$food  ${foods[food]}円',
      (s) => food = s.substring(0, s.lastIndexOf('  ')),
    );
    final toppings = Wrap(
      spacing: 6,
      children: [
        for (final s in ['シナモン', 'クローブ', 'カルダモン'])
          FilterChip(
            label: Text(s),
            selected: fruits.contains(s),
            onSelected: (v) => setState(() {
              if (v) {
                fruits.add(s);
              } else {
                fruits.remove(s);
              }
            }),
          ),
      ],
    );
    final decorations = choices(
      ['控えめ', '標準', 'しっかり'], deco, (s) => deco = s,
    );
    Widget supply(String label, bool value, void Function(bool) change) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => setState(() => change(v ?? false)),
        ),
        Text(label),
      ],
    );
    final supplies = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        supply('マドラー（無料）', spoon, (v) => spoon = v),
        supply('紙ナプキン（無料）', napkin, (v) => napkin = v),
      ],
    );
    final bill = Column(
      children: [
        Text('税抜 $subtotal 円 / 消費税 $tax 円'),
        Text('合計 $total 円', style: const TextStyle(fontSize: 28)),
      ],
    );
    final submit = Center(
      child: FilledButton(
        onPressed: () => setState(() {
          order = Random().nextInt(999) + 1;
          receipt =
              '$food  ${foods[food]}円\n'
              'スパイス: ${fruits.isEmpty ? 'なし' : fruits.join('・')}（${fruits.length * 50}円）\n'
              '渋み: $deco\n'
              'マドラー: ${spoon ? 'あり' : 'なし'}\n'
              '紙ナプキン: ${napkin ? 'あり' : 'なし'}\n'
              '税抜: $subtotal 円 / 消費税（10%）: $tax 円\n'
              '合計: $total 円';
        }),
        child: const Text('注文する'),
      ),
    );
    final ticket = order == 0
        ? const SizedBox.shrink()
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('注文番号 #$order', style: const TextStyle(fontSize: 26)),
                  Text(receipt),
                ],
              ),
            ),
          );

    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text('紅茶屋台 注文アプリ')),
        body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Center(child: photo),
          const Text('茶葉を選ぶ（ホット・1杯250ml／税抜価格）'),
          products,
          const Text('スパイス（1種類50円・複数選択可）'),
          toppings,
          const Text('渋み（無料）'),
          decorations,
          const Text('無料サービス'),
          supplies,
          const Divider(),
          bill,
          submit,
          ticket,
        ]))),
    );
  }
}
