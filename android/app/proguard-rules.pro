# 喵喵召唤术 - R8/ProGuard 规则

# ---- Flutter 引擎（反射调用，必须保留）----
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# GeneratedPluginRegistrant 通过反射注册，必须保留
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# ---- just_audio / audio_session / audio_service（ExoPlayer 反射）----
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audio_session.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-dontwarn com.ryanheise.audioservice.**

# ExoPlayer（just_audio 依赖）内部反射较多
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.exoplayer.** { *; }
-keep class androidx.media3.common.** { *; }
-keep class androidx.media3.session.** { *; }
-dontwarn androidx.media3.**
-dontwarn com.google.android.exoplayer2.**

# ---- MediaBrowserService / 组件由系统反射实例化 ----
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver

# Flutter 引擎引用 Google Play Core split-install（本 App 不使用动态模块），
# 这些类在 release 依赖中不存在，R8 会因 Missing class 报错，此处显式忽略。
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication

# ---- Kotlin 协程（audio_session 依赖）----
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**