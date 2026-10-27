import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: IcecreamApp()));

class IcecreamApp extends StatefulWidget {
  const IcecreamApp({super.key});
  @override
  State<IcecreamApp> createState() => _IcecreamAppState();
}

class _IcecreamAppState extends State<IcecreamApp> {
  final foods = {
    '🍦 ソフトクリーム（コーン付き）': 450,
    '🍨 アイスクリーム（カップ入り）': 400,
    '🍧 かき氷（夏限定）': 300,
  };
  late String food = foods.keys.first;
  String deco = 'なし';
  final fruits = <String>{};
  int decoCount = 1, order = 0;
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
    final subtotal =
        foods[food]! +
        fruits.length * 100 +
        (deco == 'なし' ? 0 : decoCount * 50);
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;
    final photo = SizedBox(
      width: 190,
      height: 145,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                deco == 'なし' ? '' : List.filled(decoCount, deco).join(),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          Center(
            child: Text(
              food.split(' ').first,
              style: const TextStyle(fontSize: 90),
            ),
          ),
          Positioned(
            top: 35,
            right: 28,
            child: SizedBox(
              width: 78,
              child: Text(
                fruits.join(),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );
    final products = choices(
      foods.keys.map((s) => '$s  ${foods[s]}円'),
      '$food  ${foods[food]}円',
      (s) => food = s.substring(0, s.lastIndexOf('  ')),
    );
    final toppings = Wrap(
      spacing: 6,
      children: [
        for (final s in ['🍓', '🍒', '🍌', '🥝', '🍇'])
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
    final decorations = Column(
      children: [
        choices(['なし', '❤️', '⭐', '🌸'], deco, (s) => deco = s),
        if (deco != 'なし')
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('デコ数'),
              IconButton(
                onPressed: decoCount > 0
                    ? () => setState(() => decoCount--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$decoCount', style: const TextStyle(fontSize: 22)),
              IconButton(
                onPressed: decoCount < 3
                    ? () => setState(() => decoCount++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
      ],
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
        supply('🥄 スプーン（無料）', spoon, (v) => spoon = v),
        supply('🧻 紙ナプキン（無料）', napkin, (v) => napkin = v),
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
              'フルーツ: ${fruits.isEmpty ? 'なし' : fruits.join(' ')}\n'
              'デコレーション: ${deco == 'なし' ? 'なし' : '$deco × $decoCount'}\n'
              '🥄 スプーン: ${spoon ? 'あり' : 'なし'}\n'
              '🧻 紙ナプキン: ${napkin ? 'あり' : 'なし'}\n'
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
        appBar: AppBar(centerTitle: true, title: const Text('🍦 Icecream 屋台注文アプリ')),
        body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Center(child: photo),
          const Text('商品を選ぶ'),
          products,
          const Text('フルーツトッピング（1種類100円）'),
          toppings,
          const Text('デコレーション（1個50円）'),
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
