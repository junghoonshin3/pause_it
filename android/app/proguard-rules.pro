# Pause it - ProGuard Rules
# Add project specific ProGuard rules here.

# Keep Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Keep SQLite (sqflite)
-keep class io.flutter.plugins.** { *; }

# Keep Receive Sharing Intent
-keep class com.bhikadia.receive_sharing_intent.** { *; }

# Google Play Core (Play Store Split Application)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-dontwarn com.google.android.play.core.**

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
