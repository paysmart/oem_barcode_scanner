package br.com.paysmart.oem.scanner.oem_barcode_scanner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class OemBarcodeScannerPlugin
    : FlutterPlugin, MethodCallHandler {

    private lateinit var mContext: Context
    private lateinit var mChannel: MethodChannel

    private fun init(ctx: Context, msgr: BinaryMessenger) {
        this.mContext = ctx
        this.mChannel = MethodChannel(msgr, "oem_barcode_scanner")
        mChannel.setMethodCallHandler(this)
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        init(flutterPluginBinding.applicationContext, flutterPluginBinding.getFlutterEngine().dartExecutor)
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = OemBarcodeScannerPlugin()
            plugin.init(registrar.activeContext(), registrar.messenger())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "scan") {
            scan(call, result)
        }
    }


    private fun scan(call: MethodCall, result: Result) {

        val mEventBus = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    "barcode-read" -> {
                        result.success(intent.getStringExtra("barCode"))
                    }
                    "barcode-manual" -> {
                        result.success("user_manual_input")
                    }
                }
            }
        }

        LocalBroadcastManager.getInstance(mContext)
                .registerReceiver(mEventBus, IntentFilter().apply {
                    addAction("barcode-read")
                    addAction("barcode-manual")
                })

        call.argument<String>("color")?.let { color ->
            mContext.startActivity(Intent(mContext, BarCodeScannerActivity::class.java).apply {
                putExtra("color", color)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            })
        }

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel.setMethodCallHandler(null)
    }
}
