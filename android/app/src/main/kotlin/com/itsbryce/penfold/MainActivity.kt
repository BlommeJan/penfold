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

    private fun isStylusEvent(event: MotionEvent): Boolean {
        if (event.pointerCount == 0) return false
        return event.getToolType(0) == MotionEvent.TOOL_TYPE_STYLUS
    }

    private fun stylusButtonPressed(event: MotionEvent): Boolean {
        if (!isStylusEvent(event)) return false
        val buttons = event.buttonState
        return (buttons and MotionEvent.BUTTON_STYLUS_PRIMARY) != 0 ||
            (buttons and MotionEvent.BUTTON_STYLUS_SECONDARY) != 0
    }

    private fun syncStylusButton(event: MotionEvent) {
        if (isStylusEvent(event)) {
            sendButtonState(stylusButtonPressed(event))
        }
    }

    override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_HOVER_ENTER,
            MotionEvent.ACTION_HOVER_MOVE,
            MotionEvent.ACTION_HOVER_EXIT,
            MotionEvent.ACTION_BUTTON_PRESS,
            MotionEvent.ACTION_BUTTON_RELEASE,
            MotionEvent.ACTION_CANCEL -> syncStylusButton(event)
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
            MotionEvent.ACTION_BUTTON_RELEASE -> syncStylusButton(event)
        }
        return super.dispatchTouchEvent(event)
    }
}
