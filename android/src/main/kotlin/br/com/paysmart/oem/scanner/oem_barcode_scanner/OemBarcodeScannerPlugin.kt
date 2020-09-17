package br.com.paysmart.oem.scanner.oem_barcode_scanner

import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class OemBarcodeScannerPlugin
    : FlutterPlugin, MethodCallHandler {

    private lateinit var mContext: Context
    private lateinit var mChannel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mChannel = MethodChannel(flutterPluginBinding.getFlutterEngine().dartExecutor, "oem_barcode_scanner")
        mChannel.setMethodCallHandler(this)
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "oem_barcode_scanner")
            channel.setMethodCallHandler(OemBarcodeScannerPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "scan") {
            scan(call, result)
        }
    }

    private fun scan(call: MethodCall, result: Result) {
        call.argument<String>("color")?.let { color ->
            mContext.startActivity(Intent(mContext, BarCodeScannerActivity::class.java).apply {
                putExtra("color", color)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })
            result.success("It worked!")
        }

    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel.setMethodCallHandler(null)
    }

}
