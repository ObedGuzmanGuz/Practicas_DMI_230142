import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const tutorialAlienImageUrl =
    'https://houstonseagle.com/wp-content/uploads/sites/105/2026/03/17740469286584.png?w=1024&strip=all&quality=80';

class SlideInfo {
  final String title;
  final String caption;
  final String imageUrl;
  final bool isNetworkImage;

  const SlideInfo(this.title, this.caption, this.imageUrl, {this.isNetworkImage = false});
}

final slides = <SlideInfo>[
  SlideInfo('Bienvenido al laboratorio', 'Explora los ejemplos de controles y componentes en una interfaz oscura.', tutorialAlienImageUrl, isNetworkImage: true),
  SlideInfo('Prueba cada herramienta', 'Abre botones, tarjetas y controles para descubrir cómo responden.', 'assets/images/2.png'),
  SlideInfo('Personaliza tu espacio', 'Elige un color de acento y observa las animaciones en acción.', 'assets/images/3.png'),
];

class AppTutorialScreen extends StatefulWidget {
  static const name = 'tutorial_screen';
  const AppTutorialScreen({super.key});

  @override
  State<AppTutorialScreen> createState() => _AppTutorialScreenState();
}

class _AppTutorialScreenState extends State<AppTutorialScreen> {
  final PageController pageviewController = PageController();
  bool endReached = false;

  @override
  void initState() {
    super.initState();
    pageviewController.addListener(() {
      final page = pageviewController.page ?? 0;
      if (!endReached && page >= (slides.length - 1.5)) {
        setState(() => endReached = true);
      }
    });
  }

  @override
  void dispose() {
    pageviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: pageviewController,
            physics: const BouncingScrollPhysics(),
            children: slides.map((slideData) => _Slide(
              title: slideData.title,
              caption: slideData.caption,
              imageUrl: slideData.imageUrl,
              isNetworkImage: slideData.isNetworkImage,
            )).toList(),
          ),
          Positioned(
            right: 20,
            top: 50,
            child: TextButton.icon(
              icon: const Icon(Icons.close_rounded),
              label: const Text('Salir'),
              onPressed: () => context.pop(),
            ),
          ),
          if (endReached)
            Positioned(
              bottom: 30,
              right: 30,
              child: FadeInRight(
                from: 15,
                delay: const Duration(milliseconds: 500),
                child: FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text('Comenzar'),
                  style: FilledButton.styleFrom(backgroundColor: colors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String title;
  final String caption;
  final String imageUrl;
  final bool isNetworkImage;

  const _Slide({
    required this.title,
    required this.caption,
    required this.imageUrl,
    required this.isNetworkImage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
    final captionStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: isNetworkImage
                  ? Image.network(
                      imageUrl,
                      height: 235,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 235,
                        width: double.infinity,
                        color: const Color(0xFF111820),
                        alignment: Alignment.center,
                        child: Icon(Icons.public_rounded, size: 76, color: colors.primary),
                      ),
                    )
                  : Image(image: AssetImage(imageUrl), height: 235, width: double.infinity, fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            Text(title, style: titleStyle),
            const SizedBox(height: 10),
            Text(caption, style: captionStyle),
          ],
        ),
      ),
    );
  }
}
