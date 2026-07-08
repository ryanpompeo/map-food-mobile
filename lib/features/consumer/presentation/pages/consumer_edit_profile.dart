import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/features/consumer/data/models/consumer_model.dart';
import 'package:map_food/features/consumer/data/services/consumer_service.dart';

class ConsumerEditProfile extends StatefulWidget {
  const ConsumerEditProfile({super.key});

  @override
  State<ConsumerEditProfile> createState() => _ConsumerEditProfileState();
}

class _ConsumerEditProfileState extends State<ConsumerEditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _service = ConsumerService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _showSenha = false;
  bool _showConfirmarSenha = false;
  ConsumerModel? _original;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final session = await AuthStorage.getSession();
      if (session == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final data = await _service.getById(session.id);
      if (mounted) {
        _original = data;
        _nomeController.text = data.nome;
        _emailController.text = data.email;
        _celularController.text = data.celular ?? '';
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível carregar seus dados.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_original == null) return;

    final novaSenha = _senhaController.text.trim();
    final confirmar = _confirmarSenhaController.text.trim();
    if (novaSenha.isNotEmpty && novaSenha != confirmar) {
      setState(() => _errorMsg = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      final atualizado = ConsumerModel(
        id: _original!.id,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        cpf: _original!.cpf,
        celular: _celularController.text.trim(),
      );
      await _service.update(
        atualizado,
        novaSenha: novaSenha.isNotEmpty ? novaSenha : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Perfil atualizado com sucesso!',
            style: AppText.corpo(context)
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      );
      Navigator.pop(context);
    } on AppException catch (e) {
      setState(() => _errorMsg = e.message);
    } catch (_) {
      setState(() => _errorMsg = 'Erro ao salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Editar Perfil',
          style: AppText.subtitulo(context).copyWith(
            fontWeight: FontWeight.w900,
            color: ColorsPalette.black,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            LucideIcons.chevronLeft,
            color: ColorsPalette.redComponents,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: ColorsPalette.redComponents
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _nomeController.text.isNotEmpty
                                  ? _nomeController.text[0].toUpperCase()
                                  : 'U',
                              style: AppText.titulo(context).copyWith(
                                fontSize: 32,
                                color: ColorsPalette.redComponents,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        'Meus Dados',
                        style: AppText.subtitulo(context)
                            .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppFormField(
                        label: 'Nome completo',
                        hint: 'Seu nome completo',
                        controller: _nomeController,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppFormField(
                        label: 'E-mail',
                        hint: 'seuemail@exemplo.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'E-mail obrigatório';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppFormField(
                        label: 'Celular',
                        hint: '(XX) 9 XXXX-XXXX',
                        controller: _celularController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        'Alterar Senha (opcional)',
                        style: AppText.subtitulo(context)
                            .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppFormField(
                        label: 'Nova senha',
                        hint: 'Mínimo 6 caracteres',
                        controller: _senhaController,
                        obscureText: !_showSenha,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showSenha ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 20,
                            color: ColorsPalette.greyText,
                          ),
                          onPressed: () =>
                              setState(() => _showSenha = !_showSenha),
                        ),
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 6) {
                            return 'Mínimo de 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppFormField(
                        label: 'Confirmar nova senha',
                        hint: 'Repita a senha',
                        controller: _confirmarSenhaController,
                        obscureText: !_showConfirmarSenha,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmarSenha
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                            size: 20,
                            color: ColorsPalette.greyText,
                          ),
                          onPressed: () => setState(
                              () => _showConfirmarSenha = !_showConfirmarSenha),
                        ),
                      ),

                      if (_errorMsg != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: ColorsPalette.redComponents
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.alertCircle,
                                  color: ColorsPalette.redComponents, size: 18),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  _errorMsg!,
                                  style: AppText.corpo(context).copyWith(
                                      color: ColorsPalette.redComponents),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xl),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _salvar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsPalette.redComponents,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Salvar alterações',
                                  style: AppText.botao(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
