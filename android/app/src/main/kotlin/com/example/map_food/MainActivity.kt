package com.example.map_food

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var respostaPendente: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANAL).setMethodCallHandler { chamada, resposta ->
            when (chamada.method) {
                "pedirPermissao" -> pedirPermissao(resposta)
                "mostrar" -> mostrar(chamada, resposta)
                else -> resposta.notImplemented()
            }
        }
    }

    private fun pedirPermissao(resposta: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        ) {
            resposta.success(true)
            return
        }
        if (respostaPendente != null) {
            resposta.success(false)
            return
        }
        respostaPendente = resposta
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), CODIGO_DO_PEDIDO)
    }

    private fun mostrar(chamada: MethodCall, resposta: MethodChannel.Result) {
        val gerente = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || gerente == null) {
            resposta.success(false)
            return
        }
        val titulo = chamada.argument<String>("titulo")
        val texto = chamada.argument<String>("texto")
        val id = chamada.argument<Int>("id")
        if (titulo == null || texto == null || id == null) {
            resposta.error("argumentos", "titulo, texto e id sao obrigatorios", null)
            return
        }

        gerente.createNotificationChannel(
            NotificationChannel(CANAL_DE_AVISOS, "Avisos da loja", NotificationManager.IMPORTANCE_HIGH)
        )

        val abrirOApp = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        gerente.notify(
            id,
            Notification.Builder(this, CANAL_DE_AVISOS)
                .setSmallIcon(R.drawable.ic_stat_ronda)
                .setContentTitle(titulo)
                .setContentText(texto)
                .setStyle(Notification.BigTextStyle().bigText(texto))
                .setAutoCancel(true)
                .setContentIntent(abrirOApp)
                .build()
        )
        resposta.success(true)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != CODIGO_DO_PEDIDO) return
        respostaPendente?.success(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
        respostaPendente = null
    }

    companion object {
        private const val CANAL = "map_food/notificacoes"
        private const val CANAL_DE_AVISOS = "avisos_da_loja"
        private const val CODIGO_DO_PEDIDO = 7301
    }
}
