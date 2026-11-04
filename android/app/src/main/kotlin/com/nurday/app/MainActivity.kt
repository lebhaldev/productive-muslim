package com.nurday.app

import android.hardware.GeomagneticField
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FragmentActivity so the fingerprint/PIN dialog (local_auth) can show.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Magnetic declination from Android's built-in World Magnetic Model,
        // so the live Qibla compass points to true north. Nothing leaves
        // the phone.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nurday/geomag")
            .setMethodCallHandler { call, result ->
                if (call.method == "declination") {
                    val lat = call.argument<Double>("lat") ?: 0.0
                    val lon = call.argument<Double>("lon") ?: 0.0
                    val field = GeomagneticField(
                        lat.toFloat(), lon.toFloat(), 0f, System.currentTimeMillis()
                    )
                    result.success(field.declination.toDouble())
                } else {
                    result.notImplemented()
                }
            }
    }
}
