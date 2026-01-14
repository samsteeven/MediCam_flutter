package com.example.easypharma

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val METHOD_CHANNEL = "easypharma/deeplink"
	private val EVENT_CHANNEL = "easypharma/deeplink_stream"

	private var eventSink: EventChannel.EventSink? = null
	private var initialLink: String? = null

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		initialLink = intent?.dataString
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"getInitialLink" -> result.success(initialLink)
				else -> result.notImplemented()
			}
		}

		EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
			override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
				eventSink = events
			}

			override fun onCancel(arguments: Any?) {
				eventSink = null
			}
		})
	}

	override fun onNewIntent(intent: Intent) {
		super.onNewIntent(intent)
		val link = intent.dataString
		eventSink?.success(link)
	}
}
