import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:widgets_app/config/menu/menu_items.dart';
import 'package:widgets_app/presentation/widgets/side_menu.dart';

const alienImageUrl =
    'https://houstonseagle.com/wp-content/uploads/sites/105/2026/03/17740469286584.png?w=1024&strip=all&quality=80';

class HomeScreen extends StatelessWidget {
  static const String name = 'home_screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Laboratorio Digital'),
        actions: [
          IconButton(
            tooltip: 'Abrir guía de bienvenida',
            onPressed: () => context.push('/tutorial'),
            icon: const Icon(Icons.auto_awesome_rounded),
          ),
        ],
      ),
      body: const _HomeView(),
      drawer: SideMenu(scaffoldKey: scaffoldKey),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: appMenuItems.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const _WelcomeBanner();
        final menuItem = appMenuItems[index - 1];
        return _CustomListTile(menuItem: menuItem);
      },
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF111820),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.42)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            alienImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF101820),
              alignment: Alignment.center,
              child: Icon(Icons.public_rounded, size: 76, color: accent),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xEE000000)],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EXPLORA Y EXPERIMENTA',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tu espacio de widgets',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Prueba controles, animaciones y estilos.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  const _CustomListTile({required this.menuItem});
  final MenuItem menuItem;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111111)
          : null,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(menuItem.icon, color: colors.primary),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: colors.primary),
        title: Text(menuItem.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(menuItem.subTitle),
        onTap: () => context.push(menuItem.link),
      ),
    );
  }
}
