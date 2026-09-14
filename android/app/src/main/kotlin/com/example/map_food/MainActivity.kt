package com.example.map_food

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var respostaPendente: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANAL).setMethodCallHandler { chamada, resposta ->
            if (chamada.method == "pedirPermissao") pedirPermissao(resposta) else resposta.notImplemented()
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

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != CODIGO_DO_PEDIDO) return
        respostaPendente?.success(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
        respostaPendente = null
    }

    companion object {
        private const val CANAL = "map_food/notificacoes"
        private const val CODIGO_DO_PEDIDO = 7301
    }
}
