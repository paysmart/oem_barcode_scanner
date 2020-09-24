package br.com.paysmart.oem.scanner.oem_barcode_scanner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class OemBarcodeScannerPlugin
    : FlutterPlugin, EventChannel.StreamHandler, MethodCallHandler {

    private lateinit var mContext: Context
    private lateinit var mChannel: MethodChannel
    private lateinit var mEventBus: BroadcastReceiver
    private lateinit var mEventChannel: EventChannel

    private fun init(ctx: Context, msgr: BinaryMessenger) {
        this.mContext = ctx
        this.mChannel = MethodChannel(msgr, "oem_barcode_scanner")
        this.mEventChannel = EventChannel(msgr, "oem_barcode_scanner/events")
        mChannel.setMethodCallHandler(this)
        mEventChannel.setStreamHandler(this)
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        init(flutterPluginBinding.applicationContext, flutterPluginBinding.getFlutterEngine().dartExecutor)
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            with(OemBarcodeScannerPlugin()) {
                init(registrar.activeContext(), registrar.messenger())
            }
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
        }

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel.setMethodCallHandler(null)
        mEventChannel.setStreamHandler(null)
    }


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        mEventBus = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    "barcode-read" -> {
                        events?.success(intent.getStringExtra("barCode"))
                    }
                    "barcode-manual" -> {
                        events?.success("user_manual_input")
                    }
                }
            }
        }

        LocalBroadcastManager.getInstance(mContext)
                .registerReceiver(mEventBus, IntentFilter().apply {
                    addAction("barcode-read")
                    addAction("barcode-manual")
                })
    }

    override fun onCancel(arguments: Any?) {
        LocalBroadcastManager.getInstance(mContext)
                .unregisterReceiver(mEventBus)
    }


}
