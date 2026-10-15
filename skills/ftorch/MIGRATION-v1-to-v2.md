# Migrating from FTorch v1 to v2

FTorch v2.0 introduced a small number of breaking changes to the Fortran API.
Load this file when working with code written for FTorch v1.x — typical
symptoms are compile errors mentioning `get_rank`, an unexpected `layout`
argument, `ftorch_int`, or missing `assert_allclose`/`assert_isclose`.

## 1. `torch_tensor_from_array` signature change

The positional `layout` argument was replaced by an optional `permute_dims`
keyword argument with semantics matching `torch.permute()`.

```fortran
! v1
call torch_tensor_from_array(tensor, array, [1, 2], torch_kCPU)

! v2 — in many cases the layout argument can simply be dropped
call torch_tensor_from_array(tensor, array, torch_kCPU)

! v2 — to keep the old non-default layout behaviour, use permute_dims
call torch_tensor_from_array(tensor, array, torch_kCPU, permute_dims=[2, 1])
```

The old signature remains available via the deprecated
`torch_tensor_from_array_legacy(tensor, array, layout, device)`, which is still
exported from the `ftorch` module but will be removed in a future release.

## 2. Type-bound methods renamed (`get_` prefix dropped)

The type-bound methods of `torch_tensor` were renamed to match the Torch API:

| Old (v1)                    | New (v2)                |
|-----------------------------|-------------------------|
| `tensor%get_rank()`         | `tensor%rank()`         |
| `tensor%get_shape()`        | `tensor%shape()`        |
| `tensor%get_stride()`       | `tensor%stride()`       |
| `tensor%get_dtype()`        | `tensor%dtype()`        |
| `tensor%get_device_type()`  | `tensor%device_type()`  |
| `tensor%get_device_index()` | `tensor%device_index()` |

Only the type-bound (`%`) names changed. The standalone module procedures such
as `torch_tensor_get_rank(tensor)` and `torch_tensor_get_shape(tensor)` retain
their original names and are unaffected.

If you see compile errors reporting that a tensor has no type-bound procedure
named, e.g., `get_rank` after upgrading, apply the renames above.

## 3. Integer kinds

The `ftorch_int` kind was removed. FTorch now uses explicit Fortran integer
kinds from `iso_fortran_env` rather than C types:

- Tensor shapes and strides: `int64`
- Dimension counts (`ndims`), `device_index`, `permute_dims`: default (32-bit)
  integers
- Loss-reduction enums (`torch_kNone`/`torch_kMean`/`torch_kSum`):
  `integer(c_int)` to match the C API

Update any declarations that used `ftorch_int` accordingly.

## 4. Test utilities

- `assert_isclose` and `assert_allclose` were removed in v2.
- Use `isclose` and `allclose` from the `ftorch_test_utils` module instead.
- These helpers are **no longer re-exported** from the `ftorch` module —
  import them explicitly:

```fortran
use ftorch_test_utils, only: allclose, isclose
```

## 5. C++ standard bumped to C++20

Building FTorch v2 (and codes that link against it) requires a C++20-capable
C++ compiler — GCC ≥ 11 (GCC 9/10 are no longer supported), or a recent
Clang/AppleClang. Update toolchains and `-DCMAKE_CXX_STANDARD` overrides as
needed.
