import 'package:flutter/material.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Como Funciona')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo ao Spotty',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'O Spotty facilita a descoberta de estabelecimentos, serviços e negócios próximos, reunindo informações importantes em um único lugar.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 32),

            _buildSection(
              context,
              icon: Icons.search,
              title: 'Encontrando Estabelecimentos',
              content: [
                'Pesquise por nome ou categoria.',
                'Visualize empresas no mapa.',
                'Filtre resultados conforme sua necessidade.',
                'Acesse informações detalhadas rapidamente.',
              ],
            ),

            _buildSection(
              context,
              icon: Icons.map,
              title: 'Utilizando o Mapa',
              content: [
                'Visualize estabelecimentos próximos.',
                'Navegue livremente pela região.',
                'Toque nos marcadores para ver detalhes.',
                'Abra rotas em aplicativos de navegação.',
              ],
            ),

            _buildSection(
              context,
              icon: Icons.store,
              title: 'Cadastro de Negócios',
              content: [
                'Crie uma conta.',
                'Cadastre seu estabelecimento.',
                'Adicione fotos e informações.',
                'Publique seu negócio na plataforma.',
              ],
            ),

            _buildSection(
              context,
              icon: Icons.edit,
              title: 'Gerenciamento das Informações',
              content: [
                'Atualize horários de funcionamento.',
                'Altere contatos.',
                'Adicione novas imagens.',
                'Mantenha seus dados sempre atualizados.',
              ],
            ),

            _buildSection(
              context,
              icon: Icons.security,
              title: 'Segurança e Confiabilidade',
              content: [
                'Cadastros podem ser revisados periodicamente.',
                'Informações incorretas podem ser corrigidas.',
                'Contas que violem as regras podem ser suspensas.',
              ],
            ),

            _buildSection(
              context,
              icon: Icons.tips_and_updates,
              title: 'Dicas para uma Melhor Experiência',
              content: [
                'Mantenha o aplicativo atualizado.',
                'Autorize a localização para resultados próximos.',
                'Reporte informações incorretas.',
              ],
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suporte',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Caso tenha dúvidas ou encontre algum problema, entre em contato com nossa equipe através dos canais disponíveis no aplicativo.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'Versão 1.0 • Junho de 2026',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...content.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
