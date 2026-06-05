# Suppress warning for missing TensorFlow Lite GPU delegate options class,
# as we do not bundle the GPU delegate library and it's not needed at runtime.
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
