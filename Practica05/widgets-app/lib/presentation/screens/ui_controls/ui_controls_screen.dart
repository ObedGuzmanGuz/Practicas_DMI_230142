import 'package:flutter/material.dart';

class UiControlsScreen extends StatelessWidget {
  static const name = 'ui_controls_screen';
  const UiControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controles de interfaz')),
      body: const _UiControlsView(),
    );
  }
}

class _UiControlsView extends StatefulWidget {
  const _UiControlsView();

  @override
  State<_UiControlsView> createState() => _UiControlsViewState();
}

enum Transportation { car, plane, boat, submarine }

class _UiControlsViewState extends State<_UiControlsView> {
  bool isDeveloper = true;
  Transportation selectedTransportation = Transportation.car;
  bool wantsBreakfast = false;
  bool wantsLunch = false;
  bool wantsDinner = false;

  String get transportationLabel {
    switch (selectedTransportation) {
      case Transportation.car: return 'Automóvil';
      case Transportation.plane: return 'Avión';
      case Transportation.boat: return 'Barco';
      case Transportation.submarine: return 'Submarino';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.code_rounded),
          title: const Text('Modo desarrollador'),
          subtitle: const Text('Mostrar controles adicionales'),
          value: isDeveloper,
          onChanged: (value) => setState(() => isDeveloper = value),
        ),
        if (isDeveloper) ...[
          ExpansionTile(
            leading: const Icon(Icons.commute_rounded),
            title: const Text('Medio de transporte'),
            subtitle: Text(transportationLabel),
            children: [
              RadioListTile<Transportation>(
                title: const Text('Automóvil'), subtitle: const Text('Viajar por carretera'),
                value: Transportation.car, groupValue: selectedTransportation,
                onChanged: (value) { if (value != null) setState(() => selectedTransportation = value); },
              ),
              RadioListTile<Transportation>(
                title: const Text('Barco'), subtitle: const Text('Viajar por agua'),
                value: Transportation.boat, groupValue: selectedTransportation,
                onChanged: (value) { if (value != null) setState(() => selectedTransportation = value); },
              ),
              RadioListTile<Transportation>(
                title: const Text('Avión'), subtitle: const Text('Viajar por aire'),
                value: Transportation.plane, groupValue: selectedTransportation,
                onChanged: (value) { if (value != null) setState(() => selectedTransportation = value); },
              ),
              RadioListTile<Transportation>(
                title: const Text('Submarino'), subtitle: const Text('Explorar bajo el agua'),
                value: Transportation.submarine, groupValue: selectedTransportation,
                onChanged: (value) { if (value != null) setState(() => selectedTransportation = value); },
              ),
            ],
          ),
        ],
        CheckboxListTile(
          secondary: const Icon(Icons.free_breakfast_rounded),
          title: const Text('¿Deseas desayuno?'),
          value: wantsBreakfast,
          onChanged: (value) => setState(() => wantsBreakfast = value ?? false),
        ),
        CheckboxListTile(
          secondary: const Icon(Icons.lunch_dining_rounded),
          title: const Text('¿Deseas almuerzo?'),
          value: wantsLunch,
          onChanged: (value) => setState(() => wantsLunch = value ?? false),
        ),
        CheckboxListTile(
          secondary: const Icon(Icons.dinner_dining_rounded),
          title: const Text('¿Deseas cena?'),
          value: wantsDinner,
          onChanged: (value) => setState(() => wantsDinner = value ?? false),
        ),
      ],
    );
  }
}
