import 'package:flutter/material.dart';

import '../widgets/practice_module_scaffold.dart';

class MoneyModuleScreen extends StatelessWidget {
  const MoneyModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PracticeModuleScaffold(
      title: 'Dinero',
      subtitle: 'Compra, paga y calcula cambios.',
      icon: Icons.payments_rounded,
      color: Color(0xFF27AE60),
      items: [
        PracticeModuleItem(
          title: 'Monedas y billetes',
          description: 'Reconoce valores simples.',
          icon: Icons.monetization_on_rounded,
          color: Color(0xFF27AE60),
        ),
        PracticeModuleItem(
          title: 'Compras pequeñas',
          description: 'Suma precios de objetos.',
          icon: Icons.shopping_bag_rounded,
          color: Color(0xFFF2994A),
        ),
        PracticeModuleItem(
          title: 'Cambio',
          description: 'Calcula cuánto queda.',
          icon: Icons.currency_exchange_rounded,
          color: Color(0xFF2F80ED),
        ),
      ],
      examples: [
        PracticeExample(
          prompt: 'Si tienes 10 pesos y gastas 4, ¿cuánto queda?',
          answer: '6 pesos',
          hint: 'Resta 10 - 4.',
        ),
        PracticeExample(
          prompt: 'Una paleta cuesta 5 pesos. Compras 2. ¿Cuánto pagas?',
          answer: '10 pesos',
          hint: 'Suma 5 + 5.',
        ),
      ],
    );
  }
}
