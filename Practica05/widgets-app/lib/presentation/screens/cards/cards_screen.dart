import 'package:flutter/material.dart';

const cards = <Map<String,dynamic>>[
  { 'elevation': 0.0, 'label': 'Relieve 0' },
  { 'elevation': 1.0, 'label': 'Relieve 1' },
  { 'elevation': 2.0, 'label': 'Relieve 2' },
  { 'elevation': 3.0, 'label': 'Relieve 3' },
  { 'elevation': 4.0, 'label': 'Relieve 4' },
  { 'elevation': 5.0, 'label': 'Relieve 5' },
];





class CardsScreen extends StatelessWidget {

  static const String name = 'cards_screen';

  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarjetas visuales'),
      ),
      body: const _CardsView(),
    );
  }
}

class _CardsView extends StatelessWidget {
  const _CardsView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          
          ...cards.map( 
            (card) => _CardType1( elevation: card['elevation'], label: card['label'] ),
          ),

          ...cards.map( 
            (card) => _CardType2( elevation: card['elevation'], label: card['label'] ),
          ),

          ...cards.map( 
            (card) => _CardType3( elevation: card['elevation'], label: card['label'] ),
          ),

          ...cards.map( 
            (card) => _CardType4( elevation: card['elevation'], label: card['label'] ),
          ),
          
          const SizedBox(height: 50 ),
        ],
      ),
    );
  }
}


class _CardType1 extends StatelessWidget {

  final String label;
  final double elevation;

  const _CardType1({
    required this.label,
    required this.elevation
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon( Icons.more_horiz_rounded),
                onPressed: () {},
              ),
            ),

            Align(
              alignment: Alignment.bottomLeft,
              child: Text( label ),
            )

          ],
        ),
      ),
    );
  }
}


class _CardType2 extends StatelessWidget {

  final String label;
  final double elevation;

  const _CardType2({
    required this.label,
    required this.elevation
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all( Radius.circular(12) ),
        side: BorderSide(
          color: colors.outline
        )
      ),
      elevation: elevation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon( Icons.more_horiz_rounded),
                onPressed: () {},
              ),
            ),

            Align(
              alignment: Alignment.bottomLeft,
              child: Text('$label - contorno'),
            )

          ],
        ),
      ),
    );
  }
}



class _CardType3 extends StatelessWidget {

  final String label;
  final double elevation;

  const _CardType3({
    required this.label,
    required this.elevation
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceVariant,
      elevation: elevation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon( Icons.more_horiz_rounded),
                onPressed: () {},
              ),
            ),

            Align(
              alignment: Alignment.bottomLeft,
              child: Text('$label - relleno'),
            )

          ],
        ),
      ),
    );
  }
}



class _CardType4 extends StatelessWidget {

  final String label;
  final double elevation;

  const _CardType4({
    required this.label,
    required this.elevation
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: elevation,
      child: Stack(
        children: [

          Image.network(
            'https://houstonseagle.com/wp-content/uploads/sites/105/2026/03/17740469286584.png?w=1024&strip=all&quality=80',
            height: 350,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 350,
              color: const Color(0xFF101820),
              alignment: Alignment.center,
              child: Icon(Icons.public_rounded, size: 64, color: colors.primary),
            ),
          ),


          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: const BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.only( bottomLeft: Radius.circular(20) )
              ),
              child: IconButton(
                icon: const Icon( Icons.more_horiz_rounded),
                onPressed: () {},
              ),
            ),
          ),


        ],
      ),
    );
  }
}




