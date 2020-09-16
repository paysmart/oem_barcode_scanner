package br.com.paysmart.oem.scanner.oem_barcode_scanner

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle

import kotlinx.android.synthetic.main.activity_bar_code_scanner.*


class BarCodeScannerActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bar_code_scanner)

        intent?.getStringExtra("color")?.let { color ->
            colorHeadline?.text = color
        }

    }
}
