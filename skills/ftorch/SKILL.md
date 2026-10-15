---
name: ftorch
description: Use this skill when working with the FTorch library - a Fortran library for coupling PyTorch machine learning models to Fortran code. Load when editing, creating, or debugging FTorch code, examples, or tests.
---

# What I do

I help use the FTorch library for coupling PyTorch machine learning models to Fortran. FTorch provides Fortran bindings to PyTorch's LibTorch C++ API, enabling tensor operations, model inference, and training from Fortran code.

# When to use this skill

Use this skill when:
- Writing Fortran code that uses FTorch (`use ftorch`)
- Creating or modifying FTorch examples or tests
- Working with `torch_tensor`, `torch_model`, `torch_optim`, or `torch_loss` types
- Building FTorch projects with CMake
- Debugging FTorch tensor operations or model inference

This skill targets **FTorch v2.x**. For v1 code (errors about `get_rank`,
`layout`, `ftorch_int`, `assert_allclose`), see `MIGRATION-v1-to-v2.md` in this
skill's directory.

# Prerequisites

- FTorch installed and available in your build system
- LibTorch (PyTorch C++ API) installed
- `ftorch_utils` Python utility installed using `pip`
- CMake available for building FTorch projects
- A `.pt` (TorchScript) model file for inference

# Quick Start

Basic FTorch inference pattern on CPU:

```fortran
use, intrinsic :: iso_fortran_env, only : sp => real32
use ftorch, only: torch_model, torch_tensor, torch_kCPU, &
                  torch_tensor_from_array, torch_model_load, &
                  torch_model_forward, torch_delete

integer, parameter :: wp = sp
type(torch_model) :: model
type(torch_tensor), dimension(1) :: in_tensors, out_tensors
real(wp), dimension(5), target :: in_data, out_data

in_data = [0.0_wp, 1.0_wp, 2.0_wp, 3.0_wp, 4.0_wp]

call torch_tensor_from_array(in_tensors(1), in_data, torch_kCPU)
call torch_tensor_from_array(out_tensors(1), out_data, torch_kCPU)
call torch_model_load(model, "model.pt", torch_kCPU)
call torch_model_forward(model, in_tensors, out_tensors)

call torch_delete(model)
call torch_delete(in_tensors)
call torch_delete(out_tensors)
```

# Core Types

## `torch_tensor`

Represents a PyTorch tensor. Operations support `real32`, `real64`, and integer types. Tensors support up to 5 dimensions, although this is easily extensible via the `fypp` Fortran Preprocessor syntax in `src/ftorch_tensor.fypp`.

### Constructors

- `torch_tensor_from_array(tensor, array, device)` - Create from a Fortran array (zero-copy, no data copy). Most common pattern.
- `torch_tensor_from_array(tensor, array, device, permute_dims=[n, ..., 1])` - From array with dimensions permuted (optional keyword; semantics match `torch.permute()`).
- `torch_tensor_from_array_legacy(tensor, array, layout, device)` - Deprecated v1 signature with required positional `layout`. Will be removed in a future version.
- `torch_tensor_empty(tensor, ndims, shape, dtype, device)` - Uninitialized tensor with given shape.
- `torch_tensor_zeros(tensor, ndims, shape, dtype, device)` - Tensor filled with zeros.
- `torch_tensor_ones(tensor, ndims, shape, dtype, device)` - Tensor filled with ones.
- `torch_tensor_from_blob(tensor, ...)` - Create from raw memory pointer (advanced).

### Operators

Overloaded for natural syntax: `+`, `-`, `*`, `/`, `**`, `=`, unary `-`.

```fortran
c = a + b          ! Addition
d = a * b          ! Multiplication
e = a ** 2         ! Power
f = -a             ! Negation
c = d              ! Assignment
```

### `tensor` methods

- `tensor%shape()` - Returns shape as a freshly allocated `int64` array.
- `tensor%stride()` - Returns stride as a freshly allocated `int64` array.
- `tensor%rank()` - Returns number of dimensions.
- `tensor%dtype()` - Returns data type enum.
- `tensor%device_type()` - Returns device enum.
- `tensor%device_index()` - Returns device index.
- `tensor%requires_grad()` - Returns logical gradient flag.
- `tensor%print()` - Print tensor contents.
- `tensor%zero()` - Zero out tensor data.
- `tensor%zero_grad()` - Zero gradients.

Standalone equivalents exist: `tensor%shape()` ≡ `torch_tensor_get_shape(tensor)`,
`tensor%rank()` ≡ `torch_tensor_get_rank(tensor)`, etc.

### `tensor` utility functions

- `torch_tensor_print(tensor)` - Print tensor contents.
- `torch_tensor_to(source, target, [non_blocking])` - Copy `source` into existing `target` (matching shape), adopting `target`'s device/dtype.
- `torch_tensor_sum(result, tensor)` - Sum all elements.
- `torch_tensor_mean(result, tensor)` - Mean of all elements.
- `torch_tensor_backward(tensor)` - Backward pass (computes gradients).
- `torch_tensor_backward(tensor, retain_graph=.true.)` - Retain computation graph.
- `torch_tensor_get_gradient(grad_tensor, source_tensor)` - Extract gradient.
- `torch_tensor_backward(tensor, external_gradient)` - Backward with external gradient tensor.
- `torch_tensor_delete(tensor)` - Optional; finalizer runs automatically.

## `torch_model`

Represents a TorchScript model (serialized PyTorch module).

### Load, Save, and Forward

```fortran
type(torch_model) :: model

! Load a TorchScript model
call torch_model_load(model, "model.pt", torch_kCPU)
call torch_model_load(model, "model.pt", torch_kCUDA, device_index=0)

! Load for training
call torch_model_load(model, "model.pt", torch_kCPU, is_training=.true.)

! Forward pass
call torch_model_forward(model, input_tensors, output_tensors)
call torch_model_forward(model, input_tensors, output_tensors, requires_grad=.true.)

! Extract model parameters
call torch_model_parameters(model, param_tensors)

! Save model
call torch_model_save(model, "saved_model.pt")

! Print parameters (useful for small models)
call model%print_parameters()

! Check training mode
if (model%is_training()) then
  ! ...
end if

! Delete
call torch_model_delete(model)  ! Optional; finalizer runs automatically
```

## `torch_optim`

Optimizer types for training. Supports SGD, Adam, and AdamW.

```fortran
type(torch_optim) :: optimizer

! Create optimizers (all hyperparameters optional with defaults matching Torch)
call torch_optim_SGD(optimizer, params, learning_rate=0.01_r8)
call torch_optim_SGD(optimizer, params, learning_rate=0.01_r8, momentum=0.9_r8, &
                     weight_decay=1.0e-4_r8, dampening=0.0_r8, nesterov=.false.)

call torch_optim_Adam(optimizer, params, learning_rate=0.001_r8)
call torch_optim_AdamW(optimizer, params, learning_rate=0.001_r8)

! Adam/AdamW keywords (weight_decay default differs: 0.0 vs 0.01):
call torch_optim_Adam(optimizer, params, learning_rate=0.001_r8, beta_1=0.9_r8, &
                      beta_2=0.999_r8, eps=1.0e-8_r8, weight_decay=0.0_r8, &
                      amsgrad=.false.)

! Training step
call optimizer%zero_grad()
call optimizer%step()

! Delete
call torch_optim_delete(optimizer)  ! Optional; finalizer runs automatically
```

# Enumerators

## Device Types (`ftorch_devices`)

- `torch_kCPU` - CPU device
- `torch_kCUDA` - CUDA GPU (also used for HIP)
- `torch_kHIP` - AMD ROCm (maps to CUDA internally)
- `torch_kMPS` - Apple Silicon Metal Performance Shaders
- `torch_kXPU` - Intel GPU

## Data Types (`ftorch_types`)

- `torch_kFloat32` - 32-bit float
- `torch_kFloat64` - 64-bit float
- `torch_kInt8`, `torch_kInt16`, `torch_kInt32`, `torch_kInt64` - Integer types

# Loss Functions

```fortran
use ftorch, only: torch_loss_mse, torch_loss_cross_entropy, torch_kMean

call torch_loss_mse(loss, input, target)
call torch_loss_cross_entropy(loss, input, target)
```

Loss functions take an optional positional `reduction_type`:

```fortran
call torch_loss_mse(loss, input, target, torch_kSum)
```

- `torch_kNone` - No reduction; loss keeps input dimensions.
- `torch_kMean` (default) - Mean over the batch.
- `torch_kSum` - Sum over the batch.

# Test Utilities

The `ftorch_test_utils` module provides testing helpers:

```fortran
use ftorch_test_utils, only: allclose, isclose

! Returns logical
passed = allclose(array1, array2, rtol=1e-5, atol=1e-8, test_name="my_test")
```

Note: these helpers are NOT re-exported by the `ftorch` module (they are private
there since v2); import them explicitly from `ftorch_test_utils`. The legacy
`assert_isclose`/`assert_allclose` aliases were removed in v2.

# Training Pattern

Full training loop from `examples/11_Training/training.f90`:

```fortran
use, intrinsic :: iso_fortran_env, only : int64, sp => real32, dp => real64
use ftorch, only: assignment(=), operator(-), operator(**), &
                  torch_kCPU, torch_kFloat32, &
                  torch_tensor, torch_tensor_from_array, torch_tensor_empty, &
                  torch_tensor_mean, torch_tensor_backward, &
                  torch_tensor_get_gradient, &
                  torch_model, torch_model_load, torch_model_parameters, &
                  torch_model_forward, torch_model_save, &
                  torch_optim, torch_optim_SGD

integer, parameter :: wp = sp
real(dp), parameter :: lr = 0.01
integer(int64), dimension(2), parameter :: shape = [5, 5]

real(wp), dimension(5), target :: in_data, out_data, target_data
real(wp), dimension(1), target :: loss_data
type(torch_model) :: model
type(torch_tensor), dimension(1) :: in_t, out_t, target_t, params
type(torch_tensor) :: grad, loss
type(torch_optim) :: optimizer

! Setup
call torch_tensor_from_array(in_t(1), in_data, torch_kCPU)
call torch_tensor_from_array(out_t(1), out_data, torch_kCPU)
call torch_tensor_from_array(target_t(1), target_data, torch_kCPU)
call torch_model_load(model, "model.pt", torch_kCPU, is_training=.true.)
call torch_model_parameters(model, params)
call torch_tensor_empty(grad, size(shape), shape, torch_kFloat32, torch_kCPU)
call torch_optim_SGD(optimizer, params, learning_rate=lr)

! Training loop
do i = 1, n_epochs
  call optimizer%zero_grad()

  ! Forward
  call torch_model_forward(model, in_t, out_t, requires_grad=.true.)

  ! Loss
  call torch_tensor_from_array(loss, loss_data, torch_kCPU)
  call torch_tensor_mean(loss, (out_t(1) - target_t(1)) ** 2)

  ! Backward
  call torch_tensor_backward(loss)
  call torch_tensor_get_gradient(grad, params(1))

  ! Step
  call optimizer%step()
end do

call torch_model_save(model, "trained_model.pt")
```

# Build System (CMake)

FTorch uses CMake. Key variables:

```bash
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=</path/to/libtorch> \
  -DCMAKE_INSTALL_PREFIX=</install/path>
```

| CMake Option | Values | Description |
|---|---|---|
| `CMAKE_PREFIX_PATH` | path | Path to LibTorch installation (C++20-capable C++ compiler required; GCC >= 11) |
| `CMAKE_BUILD_TYPE` | `Release`/`Debug` | Build configuration |
| `BUILD_SHARED_LIBS` | `ON`/`OFF` | Shared vs static library |
| `GPU_DEVICE` | `NONE`/`CUDA`/`HIP`/`XPU`/`MPS` | GPU backend |
| `CMAKE_BUILD_TESTS` | `TRUE`/`FALSE` | Enable test suite |
| `FTORCH_BUILD_UNIT_TESTS` | `ON`/`OFF` | pFUnit tests |
| `FTORCH_BUILD_INTEGRATION_TESTS` | `ON`/`OFF` | Example-based integration tests |

# Memory Layout Gotchas

**CRITICAL**: Fortran uses column-major order; PyTorch uses row-major. This affects tensor strides.

- `torch_tensor_from_array(tensor, array, device)` - Tensor wraps the Fortran array directly (column-major strides). Zero-copy.
- `torch_tensor_empty/zeros/ones` - Tensor allocated by PyTorch (row-major strides).
- To get row-major default layout with `from_array`, use `permute_dims`:
  ```fortran
  call torch_tensor_from_array(tensor, array, torch_kCPU, permute_dims=[2, 1])  ! Row-major for 2D
  ```
- When `requires_grad=.true.` is passed to `torch_model_forward`, the output tensor may become decoupled from the underlying Fortran array due to a shallow copy. Re-create the tensor with `torch_tensor_from_array` after training if you need to read back into the array.

# Common Import Pattern

Import from the main `ftorch` module (which re-exports everything):

```fortran
use ftorch, only: &
    ! Tensors
    torch_tensor, torch_tensor_from_array, torch_tensor_empty, &
    torch_tensor_zeros, torch_tensor_ones, torch_tensor_delete, &
    torch_tensor_mean, torch_tensor_sum, torch_tensor_print, &
    torch_tensor_backward, torch_tensor_get_gradient, torch_tensor_to, &
    assignment(=), operator(+), operator(-), operator(*), operator(/), operator(**), &
    ! Models
    torch_model, torch_model_load, torch_model_delete, &
    torch_model_forward, torch_model_parameters, torch_model_save, &
    ! Optimizers
    torch_optim, torch_optim_SGD, torch_optim_Adam, torch_optim_AdamW, &
    torch_optim_delete, &
    ! Enums
    torch_kCPU, torch_kFloat32, torch_kFloat64
```

Tensor interrogation is normally via type-bound methods (`tensor%rank()`, etc.);
the standalone `torch_tensor_get_*` procedures remain exported if preferred.

It is best practise to only import items that are being used within the module/subroutine/file.

# Examples Reference

The `examples/` directory contains numbered examples:

- `01_Tensor/` - Tensor creation and arithmetic
- `02_SimpleNet/` - Basic model inference
- `03_ResNet/` - ResNet model inference
- `04_Batching/` - Batch processing
- `05_MultiIO/` - Multiple inputs/outputs
- `06_Looping/` - Best practices for looping over tensors
- `07_MultiGPU/` - Multi-GPU inference
- `08_MPI/` - MPI parallel inference
- `09_Autograd/` - Automatic differentiation
- `10_Optimizers/` - Optimizer usage
- `11_Training/` - Full training loop
- `12_Permutation/` - Tensor dimension permutation (`permute_dims`)

# Workflow

1. Import `ftorch` and required entities. Use `real32` (sp) precision - match to model.
2. Declare Fortran arrays with `target` attribute for tensor wrapping.
3. Create tensors with `torch_tensor_from_array` for zero-copy data exchange.
4. Load model with `torch_model_load`, specifying device and training mode.
5. Run forward pass with `torch_model_forward`. For training, use `requires_grad=.true.`.
6. For training: compute loss, backward pass, extract gradients, step optimizer.
7. Clean up with `torch_delete` (optional since finalizers are defined).

## See Also

- [FTorch Repository](https://github.com/Cambridge-ICCS/FTorch)
- [FTorch API Docs](https://cambridge-iccs.github.io/FTorch/)
