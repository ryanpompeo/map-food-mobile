import 'package:permission_handler/permission_handler.dart' as ph;

/// Tipos de permissão nativa padronizados pelo app. Mapeados internamente
/// para a permissão real da plataforma — quem consome este serviço nunca
/// importa `permission_handler` diretamente.
enum AppPermissionType { location, camera, gallery }

/// Os três únicos estados que o app trata para qualquer permissão.
enum AppPermissionStatus { granted, denied, permanentlyDenied }

/// Serviço isolado que padroniza a solicitação de qualquer permissão nativa
/// (localização, câmera, galeria) e o tratamento rígido dos três cenários
/// possíveis: concedida, negada, e negada permanentemente.
///
/// Não depende de `BuildContext` nem de UI — a orquestração com o
/// pre-prompt de justificativa fica em [PermissionExplanationDialog].
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  ph.Permission _mapType(AppPermissionType type) {
    return switch (type) {
      AppPermissionType.location => ph.Permission.locationWhenInUse,
      AppPermissionType.camera => ph.Permission.camera,
      AppPermissionType.gallery => ph.Permission.photos,
    };
  }

  AppPermissionStatus _mapStatus(ph.PermissionStatus status) {
    if (status.isGranted || status.isLimited) return AppPermissionStatus.granted;
    if (status.isPermanentlyDenied) return AppPermissionStatus.permanentlyDenied;
    return AppPermissionStatus.denied;
  }

  /// Consulta o status atual sem disparar o pop-up nativo do SO.
  Future<AppPermissionStatus> status(AppPermissionType type) async {
    final status = await _mapType(type).status;
    return _mapStatus(status);
  }

  /// Dispara o pop-up nativo do SO. Se a permissão já tiver sido negada
  /// permanentemente, o SO nem exibe o pop-up — o Flutter perde esse
  /// direito nesse estado, então o retorno já vem como
  /// [AppPermissionStatus.permanentlyDenied] sem nenhuma UI aparecer.
  Future<AppPermissionStatus> request(AppPermissionType type) async {
    final result = await _mapType(type).request();
    return _mapStatus(result);
  }

  /// Único caminho possível para reverter uma permissão negada
  /// permanentemente: abre a tela de configurações do app no SO.
  Future<bool> openSettings() => ph.openAppSettings();
}
