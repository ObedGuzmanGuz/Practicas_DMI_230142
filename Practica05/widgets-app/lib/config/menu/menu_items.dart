import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String subTitle;
  final String link;
  final IconData icon;

  const MenuItem({
    required this.title,
    required this.subTitle,
    required this.link,
    required this.icon,
  });
}

const appMenuItems = <MenuItem>[
  MenuItem(
    title: 'Contador interactivo',
    subTitle: 'Practica el estado con Riverpod',
    link: '/counter-river',
    icon: Icons.exposure_plus_1_rounded,
  ),
  MenuItem(
    title: 'Galería de botones',
    subTitle: 'Estilos y acciones disponibles',
    link: '/buttons',
    icon: Icons.touch_app_rounded,
  ),
  MenuItem(
    title: 'Tarjetas visuales',
    subTitle: 'Contenedores con distintos relieves',
    link: '/cards',
    icon: Icons.dashboard_customize_rounded,
  ),
  MenuItem(
    title: 'Barras de progreso',
    subTitle: 'Indicadores circulares y lineales animados',
    link: '/progress',
    icon: Icons.monitor_heart_rounded,
  ),
  MenuItem(
    title: 'Avisos y diálogos',
    subTitle: 'Mensajes y ventanas de confirmación',
    link: '/snackbars',
    icon: Icons.notifications_active_outlined,
  ),
  MenuItem(
    title: 'Formas animadas',
    subTitle: 'Observa cambios suaves de tamaño y color',
    link: '/animated',
    icon: Icons.animation_rounded,
  ),
  MenuItem(
    title: 'Controles de interfaz',
    subTitle: 'Interruptores, opciones y casillas',
    link: '/ui-controls',
    icon: Icons.tune_rounded,
  ),
  MenuItem(
    title: 'Guía de bienvenida',
    subTitle: 'Un recorrido rápido por la aplicación',
    link: '/tutorial',
    icon: Icons.travel_explore_rounded,
  ),
  MenuItem(
    title: 'Galería desplazable',
    subTitle: 'Carga contenido al llegar al final',
    link: '/infinite',
    icon: Icons.photo_library_outlined,
  ),
  MenuItem(
    title: 'Personalizar colores',
    subTitle: 'Elige el acento y el modo visual',
    link: '/theme-changer',
    icon: Icons.palette_outlined,
  ),
];
