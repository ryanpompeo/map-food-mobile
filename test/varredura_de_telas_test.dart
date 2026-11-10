import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/theme/theme_controller.dart';
import 'package:map_food/features/auth/presentation/pages/account_type_page.dart';
import 'package:map_food/features/auth/presentation/pages/consumer_register_page.dart';
import 'package:map_food/features/auth/presentation/pages/esqueci_senha_page.dart';
import 'package:map_food/features/auth/presentation/pages/login_page.dart';
import 'package:map_food/features/auth/presentation/pages/merchant_register_page.dart';
import 'package:map_food/features/auth/presentation/pages/verificar_email_page.dart';
import 'package:map_food/features/avaliacoes/presentation/pages/consumer_review_page.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_edit_profile.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_profile_page.dart';
import 'package:map_food/features/contato/presentation/pages/contato_page.dart';
import 'package:map_food/features/denuncias/presentation/pages/consumer_complaints_page.dart';
import 'package:map_food/features/denuncias/presentation/pages/merchant_complaints_page.dart';
import 'package:map_food/features/favorites/presentation/pages/consumer_favorites_page.dart';
import 'package:map_food/features/guest/presentation/pages/guest_profile_page.dart';
import 'package:map_food/features/guest/presentation/pages/how_it_works_page.dart';
import 'package:map_food/features/guest/presentation/pages/politica_privacidade_page.dart';
import 'package:map_food/features/guest/presentation/pages/termos_page.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_edit_profile.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_how_it_works.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_profile_page.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_store_page.dart';
import 'package:map_food/features/merchant/presentation/pages/plano_destaque_page.dart';
import 'package:map_food/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:map_food/features/settings/presentation/pages/settings_page.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';
import 'package:map_food/features/store/presentation/pages/store_edit_page.dart';
import 'package:map_food/features/store/presentation/pages/store_register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/api_falsa.dart';
import 'support/cofre_de_teste.dart';

const _nomeLongo = 'Maria Aparecida dos Santos Oliveira';
const _emailLongo = 'maria.aparecida.santos.oliveira@exemplo.com.br';

StoreDto _loja() => StoreDto.fromJson({
      'id': 1,
      'nome': 'Pastelaria do Seu Zé Com Um Nome Bem Comprido Para Testar',
      'descricao':
          'Pastéis fritos na hora, caldo de cana e outros quitutes da casa, feitos com carinho desde 1998.',
      'statusLoja': 'ATIVA',
      'categorias': [
        {'id': 1, 'nome': 'Lanches'},
        {'id': 2, 'nome': 'Bebidas'},
      ],
      'mediaAvaliacao': 4.7,
      'totalAvaliacoes': 1234,
      'endereco': 'Avenida Governador Doutor Professor Fulano de Tal, 12345',
      'cidade': 'São José do Rio Preto',
      'estado': 'SP',
      'cep': '15000-000',
      'latitude': -20.8,
      'longitude': -49.38,
      'tipoLoja': 'FIXA',
    });

final _telas = <String, Widget Function()>{
  'AccountTypePage': () => const AccountTypePage(),
  'ConsumerRegisterPage': () => const ConsumerRegisterPage(),
  'LoginPage': () => const LoginPage(),
  'EsqueciSenhaPage': () => const EsqueciSenhaPage(emailInicial: _emailLongo),
  'MerchantRegisterPage': () => const MerchantRegisterPage(),
  'VerificarEmailPage': () => const VerificarEmailPage(),
  'ContatoPage': () => const ContatoPage(),
  'GuestProfilePage': () => const GuestProfilePage(),
  'HowItWorksPage': () => const HowItWorksPage(),
  'PoliticaPrivacidadePage': () => const PoliticaPrivacidadePage(),
  'TermosPage': () => const TermosPage(),
  'MerchantHowItWorksPage': () => const MerchantHowItWorksPage(),
  'PlanoDestaquePage': () => const PlanoDestaquePage(),
  'OnboardingPage': () => const OnboardingPage(),
  'SettingsPage': () => SettingsPage(howItWorksPageBuilder: (_) => const SizedBox()),
  'ConsumerComplaintsPage': () => const ConsumerComplaintsPage(),
  'MerchantComplaintsPage': () => const MerchantComplaintsPage(),
  'ConsumerEditProfile': () => const ConsumerEditProfile(),
  'MerchantEditProfile': () => const MerchantEditProfile(),
  'ConsumerFavoritesPage': () => const ConsumerFavoritesPage(),
  'ConsumerReviewPage': () => const ConsumerReviewPage(),
  'ConsumerProfilePage': () =>
      const ConsumerProfilePage(userName: _nomeLongo, userEmail: _emailLongo),
  'MerchantProfilePage': () =>
      const MerchantProfilePage(userName: _nomeLongo, userEmail: _emailLongo),
  'MoreInfoStorePage': () => MoreInfoStorePage(store: _loja()),
  'StoreEditPage': () => StoreEditPage(store: _loja()),
  'MerchantStorePage': () => MerchantStorePage(store: _loja()),
  'StoreRegisterPage': () => const StoreRegisterPage(),
};

const _tamanhos = {
  '320x568': Size(320, 568),
  '360x640': Size(360, 640),
  '412x915': Size(412, 915),
};

const _escalas = [1.0, 1.3, 2.0];

Future<void> _carregarInter() async {
  final loader = FontLoader('Inter');
  for (final peso in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Inter_18pt-$peso.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

String _resumo(FlutterErrorDetails detalhes) {
  final primeiraLinha = detalhes.exceptionAsString().split('\n').first;
  final onde = RegExp(r'(lib[\\/][\w\\/]+\.dart:\d+)')
      .allMatches(detalhes.toString())
      .map((m) => m.group(1))
      .toSet()
      .take(2)
      .join(' ; ');
  return onde.isEmpty ? primeiraLinha : '$primeiraLinha @ $onde';
}

void main() {
  setUpAll(_carregarInter);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    usarCofreEmMemoria();
    await ThemeController.load();
    final api = ApiFalsa()..padrao = (200, '[]');
    ApiClient.overrideInstance(ApiClient(
      dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
        ..httpClientAdapter = api
        ..interceptors.add(ErrorInterceptor()),
    ));
  });

  tearDown(ApiClient.resetInstance);

  for (final tema in ['claro', 'escuro']) {
    for (final tela in _telas.entries) {
      for (final tamanho in _tamanhos.entries) {
        for (final escala in _escalas) {
          if (tema == 'escuro' && (tamanho.key != '360x640' || escala != 1.0)) continue;

          testWidgets('${tela.key} em ${tamanho.key}, fonte ${escala}x, tema $tema',
              (tester) async {
            tester.view.physicalSize = tamanho.value * 3;
            tester.view.devicePixelRatio = 3;
            addTearDown(tester.view.reset);

            final erros = <String>[];
            final original = FlutterError.onError;
            FlutterError.onError = (detalhes) => erros.add(_resumo(detalhes));
            try {
              await tester.pumpWidget(MaterialApp(
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: tema == 'escuro' ? ThemeMode.dark : ThemeMode.light,
                home: MediaQuery(
                  data: MediaQueryData(
                    size: tamanho.value,
                    textScaler: TextScaler.linear(escala),
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                  ),
                  child: tela.value(),
                ),
              ));
              for (var i = 0; i < 6; i++) {
                await tester.pump(const Duration(milliseconds: 300));
              }
              await tester.pumpWidget(const SizedBox());
              await tester.pump(const Duration(seconds: 30));
            } finally {
              FlutterError.onError = original;
            }

            final excecao = tester.takeException();
            if (excecao != null) erros.add(excecao.toString().split('\n').first);

            expect(erros.toSet(), isEmpty);
          });
        }
      }
    }
  }
}
