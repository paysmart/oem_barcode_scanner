package br.com.paysmart.oem.scanner.oem_barcode_scanner


import android.Manifest.permission.CAMERA
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.PorterDuff
import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.zxing.client.android.BeepManager
import kotlinx.android.synthetic.main.activity_bar_code_scanner.*


class BarCodeScannerActivity : AppCompatActivity() {

    private fun askCameraPermission() {
        if (ContextCompat.checkSelfPermission(this, CAMERA) == PackageManager.PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(this, arrayOf(CAMERA), 0x0)
        }
    }

    private fun changeBackgroundColor(bgColor: String) {
        val bg = ResourcesCompat.getDrawable(resources, R.drawable.btn_background, null)
        bg?.setColorFilter(Color.parseColor(bgColor), PorterDuff.Mode.SRC_ATOP)
        barCodeInputButton.background = bg
    }

    private fun changeBarcodeText(text: String) {
        findViewById<TextView>(R.id.textView).text = "TEste de código de barras"//text
    }

    private val mBeeper by lazy {
        BeepManager(this)
    }

    private var mBarcode = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bar_code_scanner)

        intent?.getStringExtra("color")?.let { color ->
            changeBackgroundColor(color)
        }
        intent?.getStringExtra("text")?.let { text ->
            changeBarcodeText(text)
        }


        barCodeInputButton.setOnClickListener {
            LocalBroadcastManager.getInstance(this)
                    .sendBroadcast(Intent("barcode-manual"))
            finish()
        }

        go_back_tbn.setOnClickListener {
            finish()
        }

        askCameraPermission()

        barcodeSurface.setStatusText("")

        barcodeSurface.decodeSingle { barcode ->
            if (barcode.text != null && barcode.text != mBarcode) {
                mBarcode = barcode.text
                mBeeper.playBeepSound()
                LocalBroadcastManager.getInstance(this)
                        .sendBroadcast(Intent("barcode-read").apply {
                            putExtra("barCode", barcode.text)
                        })
                finish()
            }
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
