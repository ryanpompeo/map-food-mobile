import 'package:flutter/material.dart';

/// Cores de identidade das métricas de estatística do perfil (dias no app,
/// avaliações, denúncias, acessos/visitas...) — companheiro de
/// `category_colors.dart`, mesma lógica de "cor carrega significado"
/// aplicada a `ProfileStatCard` em vez de chips/badges de categoria.
class AppMetricColors {
  const AppMetricColors._();

  static const diasNoApp = Color(0xFF3B82F6);
  static const avaliacoes = Color(0xFFF59E0B);
  static const denuncias = Color(0xFFEF4444);
  static const acessos = Color(0xFF10B981);
  static const categorias = Color(0xFF7C3AED);
}
