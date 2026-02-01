# Pause it - ProGuard Rules
# Add project specific ProGuard rules here.

# Keep Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Keep SQLite (sqflite)
-keep class io.flutter.plugins.** { *; }

# Keep Receive Sharing Intent
-keep class com.bhikadia.receive_sharing_intent.** { *; }

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
