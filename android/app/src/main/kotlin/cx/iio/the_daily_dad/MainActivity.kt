package cx.iio.the_daily_dad

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "cx.iio.the_daily_dad/auto_media"

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Start the Android Auto media service
        val serviceIntent = Intent(this, AutoMediaService::class.java)
        startService(serviceIntent)
        android.util.Log.d("MainActivity", "AutoMediaService start requested")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            android.util.Log.d("MainActivity", "Received method call: ${call.method}")
            val service = getAutoMediaService()
            if (service == null) {
                android.util.Log.e("MainActivity", "AutoMediaService instance is null! Starting service...")
                val serviceIntent = Intent(this, AutoMediaService::class.java)
                startService(serviceIntent)
                // Wait a bit for service to start
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    getAutoMediaService()?.let { s ->
                        handleMethodCall(call, result, s)
                    } ?: run {
                        android.util.Log.e("MainActivity", "Service still null after delay")
                        result.error("SERVICE_NOT_READY", "AutoMediaService not available", null)
                    }
                }, 500)
            } else {
                handleMethodCall(call, result, service)
            }
        }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result, service: AutoMediaService) {
        when (call.method) {
            "setNewsItems" -> {
                val items = call.arguments as? List<Map<String, Any>> ?: emptyList()
                android.util.Log.d("MainActivity", "Setting news items: ${items.size}")
                service.setCategoryItems("news", items)
                result.success(null)
            }
            "setJokes" -> {
                val items = call.arguments as? List<Map<String, Any>> ?: emptyList()
                android.util.Log.d("MainActivity", "Setting jokes: ${items.size}")
                service.setCategoryItems("jokes", items)
                result.success(null)
            }
            "setFactoids" -> {
                val items = call.arguments as? List<Map<String, Any>> ?: emptyList()
                android.util.Log.d("MainActivity", "Setting factoids: ${items.size}")
                service.setCategoryItems("factoids", items)
                result.success(null)
            }
            "setQuotes" -> {
                val items = call.arguments as? List<Map<String, Any>> ?: emptyList()
                android.util.Log.d("MainActivity", "Setting quotes: ${items.size}")
                service.setCategoryItems("quotes", items)
                result.success(null)
            }
            "setTrivia" -> {
                val items = call.arguments as? List<Map<String, Any>> ?: emptyList()
                android.util.Log.d("MainActivity", "Setting trivia: ${items.size}")
                service.setCategoryItems("trivia", items)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getAutoMediaService(): AutoMediaService? {
        // The service will be accessed via a singleton pattern
        // For now, we'll use a static reference
        return AutoMediaService.instance
    }
}
