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
import com.journeyapps.barcodescanner.ViewfinderView
import kotlinx.android.synthetic.main.activity_bar_code_scanner.*


class QRCodeScannerActivity : AppCompatActivity() {

    private fun askCameraPermission() {
        if (ContextCompat.checkSelfPermission(this, CAMERA) == PackageManager.PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(this, arrayOf(CAMERA), 0x0)
        }
    }

    private fun changeBackgroundColor(bgColor: String) {
        val bg = ResourcesCompat.getDrawable(resources, R.drawable.btn_background, null)
        bg?.setColorFilter(Color.parseColor(bgColor), PorterDuff.Mode.SRC_ATOP)
    }

    private fun changeQRCodeText(text: String) {
        findViewById<TextView>(R.id.textView).text = text
    }

    private val mBeeper by lazy {
        BeepManager(this)
    }

    private var mQRCode = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_qr_code_scanner)

        intent?.getStringExtra("color")?.let { color ->
            changeBackgroundColor(color)
        }
        intent?.getStringExtra("text")?.let { text ->
            changeQRCodeText(text)
        }

        go_back_tbn.setOnClickListener {
            finish()
        }

        askCameraPermission()
        findViewById<ViewfinderView>(R.id.zxing_viewfinder_view).setLaserVisibility(false)

        barcodeSurface.setStatusText("")

        barcodeSurface.decodeSingle { qrCode ->
            if (qrCode.text != null && qrCode.text != mQRCode) {
                mQRCode = qrCode.text
                mBeeper.playBeepSound()
                LocalBroadcastManager.getInstance(this)
                        .sendBroadcast(Intent("barcode-read").apply {
                            putExtra("barCode", qrCode.text)
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
