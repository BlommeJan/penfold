package com.itsbryce.penfold

import android.view.MotionEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.itsbryce.penfold/spen_button"
    private var eventSink: EventChannel.EventSink? = null
    private var buttonPressed = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    private fun sendButtonState(pressed: Boolean) {
        if (pressed != buttonPressed) {
            buttonPressed = pressed
            eventSink?.success(pressed)
        }
    }

    private fun stylusButtonPressed(event: MotionEvent): Boolean {
        if (event.pointerCount == 0) return false
        if (event.getToolType(0) != MotionEvent.TOOL_TYPE_STYLUS) return false
        return (event.buttonState and MotionEvent.BUTTON_STYLUS_PRIMARY) != 0
    }

    override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean {
        if (stylusButtonPressed(event)) {
            sendButtonState(true)
        } else if (event.getToolType(0) == MotionEvent.TOOL_TYPE_STYLUS &&
            event.actionMasked == MotionEvent.ACTION_HOVER_EXIT
        ) {
            sendButtonState(false)
        }
        return super.dispatchGenericMotionEvent(event)
    }

    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN,
            MotionEvent.ACTION_MOVE,
            MotionEvent.ACTION_UP,
            MotionEvent.ACTION_CANCEL,
            MotionEvent.ACTION_BUTTON_PRESS,
            MotionEvent.ACTION_BUTTON_RELEASE -> {
                if (event.getToolType(0) == MotionEvent.TOOL_TYPE_STYLUS) {
                    sendButtonState(stylusButtonPressed(event))
                }
            }
        }
        return super.dispatchTouchEvent(event)
    }
}
