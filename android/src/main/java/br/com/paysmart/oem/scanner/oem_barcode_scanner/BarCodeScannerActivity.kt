package br.com.paysmart.oem.scanner.oem_barcode_scanner


import kotlinx.android.synthetic.main.activity_bar_code_scanner.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import android.Manifest.permission.CAMERA
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import android.os.Bundle
import android.util.Log
import com.google.zxing.client.android.BeepManager


class BarCodeScannerActivity : AppCompatActivity() {

    private fun askCameraPermission() {
        if (ContextCompat.checkSelfPermission(this, CAMERA) == PackageManager.PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(this, arrayOf(CAMERA), 0x0)
        }
    }

    private val mBeeper by lazy {
        BeepManager(this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bar_code_scanner)

        askCameraPermission()

        barcodeSurface.setStatusText("")
        barcodeSurface.decodeContinuous { barcode ->
            Log.d("________", "Decoder read = ${barcode.text}")
            mBeeper.playBeepSound()
        }

        /*
        intent?.getStringExtra("color")?.let { color ->
            colorHeadline?.text = color
        }*/

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
