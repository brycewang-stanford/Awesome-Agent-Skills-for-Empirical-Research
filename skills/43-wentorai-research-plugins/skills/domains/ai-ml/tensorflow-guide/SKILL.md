---
name: tensorflow-guide
description: "TensorFlow best practices for tf.function, GPU memory, and deployment"
metadata:
  openclaw:
    emoji: "🧮"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["TensorFlow", "tf.function", "GPU", "SavedModel", "distributed training", "XLA"]
    source: "https://github.com/tensorflow/tensorflow"
---

# TensorFlow Guide

## Overview

TensorFlow is a production-grade machine learning framework that excels at deployment, distributed training, and hardware acceleration. While PyTorch dominates pure research prototyping, TensorFlow remains the standard in industry ML systems and is heavily used in applied research where models must move from experiment to production.

TensorFlow 2.x unified eager execution with graph-mode performance through `tf.function`, but this hybrid approach introduces subtle pitfalls. Understanding when and how TensorFlow traces functions, manages GPU memory, and distributes computation is essential for writing correct and efficient code.

This guide covers the key patterns that trip up researchers: `tf.function` tracing semantics, GPU memory management, distributed strategies, model export, and the ecosystem of tools (TFX, TensorBoard, TF Serving) that make TensorFlow uniquely powerful for end-to-end ML workflows.

## tf.function: The Critical Abstraction

### How Tracing Works

```python
import tensorflow as tf

@tf.function
def add(a, b):
    print("Tracing!")  # Runs only during tracing, NOT every call
    tf.print("Executing!")  # Runs every call (TF op)
    return a + b

# First call with float32 shape (2,) -- traces
add(tf.constant([1.0, 2.0]), tf.constant([3.0, 4.0]))  # Prints "Tracing!" + "Executing!"

# Second call with same signature -- reuses trace
add(tf.constant([5.0, 6.0]), tf.constant([7.0, 8.0]))  # Prints only "Executing!"

# Third call with different dtype -- re-traces!
add(tf.constant([1, 2]), tf.constant([3, 4]))  # Prints "Tracing!" + "Executing!"
```

### Common tf.function Pitfalls

```python
# PITFALL 1: Python side effects in tf.function
counter = 0

@tf.function
def increment():
    global counter
    counter += 1  # Only runs during tracing! counter stays at 1 forever.
    return counter

# FIX: Use tf.Variable for mutable state
counter = tf.Variable(0)

@tf.function
def increment():
    counter.assign_add(1)
    return counter

# PITFALL 2: Creating variables inside tf.function
@tf.function
def bad_function(x):
    w = tf.Variable(tf.random.normal([3, 3]))  # ERROR on second call!
    return x @ w

# FIX: Create variables outside, pass as arguments or use Keras layers
w = tf.Variable(tf.random.normal([3, 3]))

@tf.function
def good_function(x):
    return x @ w

# PITFALL 3: Python lists that grow
@tf.function
def bad_accumulate(dataset):
    results = []
    for x in dataset:
        results.append(x * 2)  # Creates new trace on every iteration!
    return results

# FIX: Use tf.TensorArray
@tf.function
def good_accumulate(dataset):
    results = tf.TensorArray(tf.float32, size=0, dynamic_size=True)
    for i, x in enumerate(dataset):
        results = results.write(i, x * 2)
    return results.stack()
```

### Input Signatures for Stable Tracing

```python
@tf.function(input_signature=[
    tf.TensorSpec(shape=[None, 224, 224, 3], dtype=tf.float32),
    tf.TensorSpec(shape=[None], dtype=tf.int64),
])
def train_step(images, labels):
    """Fixed signature prevents re-tracing on different batch sizes."""
    with tf.GradientTape() as tape:
        predictions = model(images, training=True)
        loss = loss_fn(labels, predictions)
    gradients = tape.gradient(loss, model.trainable_variables)
    optimizer.apply_gradients(zip(gradients, model.trainable_variables))
    return loss
```

## GPU Memory Management

```python
# Problem: TensorFlow grabs ALL GPU memory by default
# Solution: Enable memory growth

gpus = tf.config.list_physical_devices("GPU")
for gpu in gpus:
    tf.config.experimental.set_memory_growth(gpu, True)

# Alternative: Set a hard memory limit
tf.config.set_logical_device_configuration(
    gpus[0],
    [tf.config.LogicalDeviceConfiguration(memory_limit=8192)]  # 8 GB
)

# Monitor memory usage
print(tf.config.experimental.get_memory_info("GPU:0"))
```

## Distributed Training Strategies

| Strategy | GPUs | Machines | Sync | Use Case |
|----------|------|----------|------|----------|
| `MirroredStrategy` | Multiple | 1 | Sync | Most common multi-GPU |
| `MultiWorkerMirroredStrategy` | Multiple | Multiple | Sync | Multi-node training |
| `TPUStrategy` | TPU cores | 1 pod | Sync | TPU training |
| `ParameterServerStrategy` | Multiple | Multiple | Async | Very large models |

```python
# Multi-GPU training with MirroredStrategy
strategy = tf.distribute.MirroredStrategy()
print(f"Number of devices: {strategy.num_replicas_in_sync}")

with strategy.scope():
    model = build_model()
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001 * strategy.num_replicas_in_sync),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )

# Global batch size = per_replica_batch * num_replicas
global_batch_size = 32 * strategy.num_replicas_in_sync
dataset = dataset.batch(global_batch_size)
model.fit(dataset, epochs=10)
```

## Model Export and Serving

```python
# SavedModel: The universal export format
model.save("saved_model/my_model")

# Load with full TF capabilities
loaded = tf.saved_model.load("saved_model/my_model")
infer = loaded.signatures["serving_default"]

# TF Lite for mobile/edge deployment
converter = tf.lite.TFLiteConverter.from_saved_model("saved_model/my_model")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open("model.tflite", "wb") as f:
    f.write(tflite_model)

# TensorFlow.js for browser deployment
# Command line:
# tensorflowjs_converter --input_format=tf_saved_model saved_model/my_model web_model/
```

## Performance Optimization with XLA

```python
# XLA (Accelerated Linear Algebra) compiles tf.functions for hardware
@tf.function(jit_compile=True)
def fast_matmul(a, b):
    return tf.matmul(a, b)

# Enable XLA globally for Keras
tf.config.optimizer.set_jit(True)

# Benchmark XLA vs non-XLA
import time
a = tf.random.normal([1024, 1024])
b = tf.random.normal([1024, 1024])

# Warm up
fast_matmul(a, b)

start = time.time()
for _ in range(1000):
    fast_matmul(a, b)
print(f"XLA matmul: {time.time() - start:.3f}s")
```

## Debugging and Profiling

```python
# Enable eager mode for debugging
tf.config.run_functions_eagerly(True)

# TensorBoard profiler integration
log_dir = "logs/profile"
tf.profiler.experimental.start(log_dir)
# ... run training steps ...
tf.profiler.experimental.stop()
# View: tensorboard --logdir logs/profile

# Check for numerical issues
tf.debugging.enable_check_numerics()  # Raises on NaN/Inf
```

## Best Practices

- **Set memory growth before any TF operations.** It must be the first GPU-related call.
- **Use `tf.function` with explicit `input_signature`** to prevent re-tracing in production.
- **Avoid Python control flow inside `tf.function`** unless you use `tf.cond` / `tf.while_loop`.
- **Profile with TensorBoard** before optimizing; identify whether you are CPU-bound, GPU-bound, or I/O-bound.
- **Use mixed precision** via `tf.keras.mixed_precision.set_global_policy("mixed_float16")` for modern GPUs.
- **Pin TF version in Docker images** for reproducible research -- different versions can produce different numerical results.

## References

- [TensorFlow documentation](https://www.tensorflow.org/guide) -- Official guides and API reference
- [Better performance with tf.function](https://www.tensorflow.org/guide/function) -- Tracing semantics deep dive
- [Distributed training guide](https://www.tensorflow.org/guide/distributed_training) -- Multi-GPU and multi-node patterns
- [TensorFlow Model Garden](https://github.com/tensorflow/models) -- Reference implementations of SOTA models
- [XLA documentation](https://www.tensorflow.org/xla) -- Hardware-accelerated compilation
