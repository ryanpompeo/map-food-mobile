import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/how_it_works_scaffold.dart';

/// Três passos para o comerciante entender a mecânica do app.
///
/// Os passos são uma sequência de operação (ativar → rodar → colher retorno),
/// e é por isso que aparecem numa linha do tempo, e não como três cards soltos
/// de mesmo peso. O desenho vive em [HowItWorksScaffold], compartilhado com a
/// versão do visitante — aqui fica só o conteúdo.
class MerchantHowItWorksPage extends StatelessWidget {
  const MerchantHowItWorksPage({super.key});

  static const _passos = <HowItWorksStep>[
    (
      icone: AppIcons.storefront,
      titulo: 'Abra sua loja',
      descricao: 'O botão "Abrir loja" é o que coloca você no mapa. Fechada, '
          'você não aparece para ninguém.',
    ),
    (
      icone: AppIcons.navigationArrow,
      titulo: 'Fique em ronda',
      descricao: 'Com a loja aberta, sua posição acompanha o seu deslocamento '
          'automaticamente — quem está por perto vê você se aproximando.',
    ),
    (
      icone: AppIcons.chatCircle,
      titulo: 'Acompanhe as avaliações',
      descricao: 'As notas e comentários dos clientes ficam no perfil da loja. '
          'Reputação alta é o que traz o próximo cliente.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const HowItWorksScaffold(
      titulo: 'Como funciona',
      subtitulo: 'Três passos para o seu comércio ser encontrado por quem está '
          'perto agora.',
      passos: _passos,
      ctaLabel: 'Entendi, vamos lá',
      ctaVariant: AppButtonVariant.inverse,
    );
  }
}
