import 'package:flutter/material.dart';

import '../widgets/practice_module_scaffold.dart';

class MeasurementModuleScreen extends StatelessWidget {
  const MeasurementModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PracticeModuleScaffold(
      title: 'Medición',
      subtitle: 'Compara tamaños, pesos y capacidades.',
      icon: Icons.straighten_rounded,
      color: Color(0xFF00A6A6),
      items: [
        PracticeModuleItem(
          title: 'Largo y corto',
          description: 'Compara longitudes.',
          icon: Icons.swap_horiz_rounded,
          color: Color(0xFF00A6A6),
        ),
        PracticeModuleItem(
          title: 'Pesado y ligero',
          description: 'Reconoce qué pesa más.',
          icon: Icons.scale_rounded,
          color: Color(0xFF9B51E0),
        ),
        PracticeModuleItem(
          title: 'Litros y mililitros',
          description: 'Mide líquidos.',
          icon: Icons.water_drop_rounded,
          color: Color(0xFF2F80ED),
        ),
        PracticeModuleItem(
          title: 'Centímetros y metros',
          description: 'Elige la unidad adecuada.',
          icon: Icons.square_foot_rounded,
          color: Color(0xFFF2994A),
        ),
      ],
      examples: [
        PracticeExample(
          prompt: '¿Qué unidad usarías para medir un lápiz?',
          answer: 'Centímetros',
          hint: 'Un lápiz es pequeño.',
        ),
        PracticeExample(
          prompt: '¿Qué pesa más: una mochila o una pluma?',
          answer: 'Una mochila',
          hint: 'Piensa cuál cuesta más levantar.',
        ),
      ],
    );
  }
}
