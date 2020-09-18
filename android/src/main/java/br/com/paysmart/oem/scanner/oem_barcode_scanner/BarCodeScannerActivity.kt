package br.com.paysmart.oem.scanner.oem_barcode_scanner


import android.Manifest.permission.CAMERA
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.drawable.ShapeDrawable
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.zxing.client.android.BeepManager
import kotlinx.android.synthetic.main.activity_bar_code_scanner.*


class BarCodeScannerActivity : AppCompatActivity() {

    private fun askCameraPermission() {
        if (ContextCompat.checkSelfPermission(this, CAMERA) == PackageManager.PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(this, arrayOf(CAMERA), 0x0)
        }
    }

    private fun changeBackgroundColor(bgColor: String) =
            with(barCodeInputButton.background as ShapeDrawable) {
                paint.color = Color.parseColor(bgColor)
            }

    private val mBeeper by lazy {
        BeepManager(this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bar_code_scanner)


        intent?.getStringExtra("color")?.let { color ->
            changeBackgroundColor(color)
        }

        barCodeInputButton.setOnClickListener {
            LocalBroadcastManager.getInstance(this)
                    .sendBroadcast(Intent("barcode-manual"))
            finish()
        }

        askCameraPermission()

        barcodeSurface.setStatusText("")
        barcodeSurface.decodeSingle { barcode ->
            mBeeper.playBeepSound()
            LocalBroadcastManager.getInstance(this)
                    .sendBroadcast(Intent("barcode-read").apply {
                        putExtra("barCode", barcode.text)
                    })
            finish()
        }

    }

    override fun onResume() {
        super.onResume()
        barcodeSurface.resume()
    }

    override fun onPause() {
        super.onPause()
        barcodeSurface.pause()
    }
}
