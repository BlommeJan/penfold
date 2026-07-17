# Google ML Kit — keep native entry points if R8/minify is enabled later.
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

-keep class com.google_mlkit_digital_ink_recognition.** { *; }
-keep class com.google_mlkit_commons.** { *; }

-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
