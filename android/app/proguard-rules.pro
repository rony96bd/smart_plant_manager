# TensorFlow Lite rules
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }

# Flutter specific
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Google Play Core (for deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep all classes in the main package
-keep class com.rony.smart_plant_manager.** { *; }

# General rules
-keepattributes SourceFile,LineNumberTable
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,EnclosingMethod
-keep class * extends java.lang.annotation.Annotation { *; }

# Keep data for serialization
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keepattributes RuntimeVisibleAnnotations,RuntimeVisibleParameterAnnotations

# Keep all classes that might be used in JSON serialization
-keepattributes Annotation,InnerClasses,EnclosingMethod,Signature
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations

# Keep all classes with @JsonSerializable annotation (if any)
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepattributes AnnotationDefault

# Keep data models
-keep class * extends java.io.Serializable { *; }
