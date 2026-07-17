package com.itsbryce.penfold

import com.google.mlkit.common.MlKitException
import com.google.mlkit.vision.digitalink.recognition.DigitalInkRecognitionModel
import com.google.mlkit.vision.digitalink.recognition.DigitalInkRecognitionModelIdentifier
import com.google_mlkit_commons.GenericModelManager
import com.google_mlkit_digital_ink_recognition.DigitalInkRecognizer
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Wraps upstream [DigitalInkRecognizer] and fixes empty manageModel (0.15.0 bug)
 * so Dart downloadModel/isModelDownloaded Futures complete.
 */
class PenfoldDigitalInkRecognizer : MethodChannel.MethodCallHandler {
    private val delegate = DigitalInkRecognizer()
    private val genericModelManager = GenericModelManager()

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        if (call.method == MANAGE) {
            manageModel(call, result)
            return
        }
        delegate.onMethodCall(call, result)
    }

    private fun manageModel(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val tag = call.argument<String>("model")
        val model = getModel(tag!!, result) ?: return
        genericModelManager.manageModel(model, call, result)
    }

    private fun getModel(
        tag: String,
        result: MethodChannel.Result,
    ): DigitalInkRecognitionModel? {
        val modelIdentifier =
            try {
                DigitalInkRecognitionModelIdentifier.fromLanguageTag(tag)
            } catch (e: MlKitException) {
                result.error("Failed to create model identifier", e.toString(), null)
                return null
            }

        if (modelIdentifier == null) {
            result.error("Model Identifier error", "No model was found", null)
            return null
        }

        return DigitalInkRecognitionModel.builder(modelIdentifier).build()
    }

    companion object {
        private const val MANAGE = "vision#manageInkModels"
    }
}
