---
name: enzyme-fortran
description: Use this skill when working with the Enzyme automatic differentiation framework to differentiate Fortran code.
---

# What I do

I help apply the Enzyme automatic differentiation (AD) framework to
differentiate Fortran code. Enzyme differentiates LLVM, which may be exposed in
Fortran via its Fortran bindings.

# When to use this skill

Use this skill when:
- Writing Fortran code that uses Enzyme (`use enzyme`)
- Creating or modifying Enzyme examples or tests
- Differentiating Fortran code
- Building Enzyme projects with CMake

# Prerequisites

- Enzyme installed and available in your build system
- A LLVM-based Fortran compiler such as Flang or IFX installed
- `opt` optimizer utility such as the one installed with the LLVM project
- `lit` Python testing utility installed using `pip`
- CMake available for building Enzyme projects

# Quick Start

Basic Enzyme reverse mode differentiation pattern:

```fortran
use enzyme, only: enzyme_autodiff

call enzyme_autodiff(procedure, x1, dx1, x2, dx2, ...)
```

where `procedure` is a function or subroutine to be differentiated, `x1` and
`x2` are its arguments, and `dx1` and `dx2` are the corresponding shadow
arguments, which correspond to shadow arguments, i.e., seeds or derivatives.

# Fortran bindings

## Function hooks

### `enzyme_autodiff`

Binds to `__enzyme_autodiff` in C via an alias `f__enzyme_autodiff` using an
implicit `external` interface. The Fortran compiler will put a
`@f__enzyme_autodiff` marker in the LLVM IR, which is handled by Enzyme to apply
reverse-mode AD to the procedure passed as the first argument.

### `enzyme_fwddiff`

Binds to `__enzyme_fwddiff` in C via an alias `f__enzyme_fwddiff` using an
implicit `external` interface. The Fortran compiler will put a
`@f__enzyme_fwddiff` marker in the LLVM IR, which is handled by Enzyme to apply
forward-mode AD to the procedure passed as the first argument.

## Activity descriptors

### `enzyme_const`

Binds to the `enzyme_const` integer in C. When passed in front of a primal
argument pased to a function hook, this indicates that the differentiation
should treat that primal argument as a constant.

### `enzyme_out`

Binds to the `enzyme_out` integer in C. When passed in front of a primal
argument pased to a function hook, this indicates that the differentiation
should treat that primal argument as an output.

### `enzyme_dup`

Binds to the `enzyme_out` integer in C. When passed in front of a primal-shadow
argument pair pased to a function hook, this indicates that the differentiation
should treat the shadow as a seed or derivative, depending on the specified
`intent`.

# Build System

## Building Enzyme

Enzyme uses CMake. Key variables:

```bash
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_DIR=</path/to/llvm/installation> \
  -DLLVM_EXTERNAL_LIT=</path/to/lit/installation> \
  -ENZYME_FORTRAN=ON
```

| CMake Option | Values | Description |
|---|---|---|
| `LLVM_DIR` | path | Path to LLVM installation |
| `LLVM_EXTERNAL_LIT` | path | Path to lit installation |
| `ENZYME_FORTRAN` | `ON`/`OFF` | Toggle building with Fortran bindings |
| `ENZYME_FLANG` | `ON`/`OFF` | Specify use of Flang compiler |
| `ENZYME_IFX` | `ON`/`OFF` | Specify use of IFX compiler |
| `ENZYME_ENABLE_PLUGINS` | `ON`/`OFF` | Enable plugins for simpler builds |
| `CMAKE_C_COMPILER` | compiler | C compiler to build the library with |
| `CMAKE_CXX_COMPILER` | compiler | C++ compiler to build the library with |
| `CMAKE_Fortran_COMPILER` | compiler | Fortran compiler to build the library with |
| `CMAKE_Fortran_FLAGS` | string | Flags to pass to the Fortran compiler |

The LLVM plugin will be installed in the build directory under
`Enzyme/LLVMEnzyme-${VN}.so`, where `${VN}` is the LLVM version.

If `ENZYME_ENABLE_PLUGINS=ON` and `ENZYME_FLANG=ON` then the Flang plugin will
be installed in the build directory under `Enzyme/FlangEnzyme-${VN}.so`, where
`${VN}` is the Flang version.

If `ENZYME_FORTRAN=ON` then the Fortran bindings will be installed into the
build directory under `modules/enzyme.mod`.

## Applying Enzyme

Here we describe how to apply Enzyme to Fortran program in a file `test.f90`,
assuming the Flang compiler is being used. There are two approaches:

### Step-by-step approach

#### 1. Generate an LLVM IR file `input.ll`

Run
```sh
flang test.f90 -S -emit-llvm -o input.ll ${FFLAGS1}
```
where `${FFLAGS1}` should include any Fortran flags, such as include statements
for the bindings.

#### 2. Apply Enzyme

Apply Enzyme via its LLVM plugin via
```sh
opt input.ll -S --load-pass-plugin=/path/to/LLVMEnzyme-${VN}.so -passes=enzyme \
    -o output.ll
```
where `${VN}` specifies the LLVM version.

#### 3. (Optional) apply optimizations

Run
```sh
opt output.ll -S ${OPTFLAGS} -o output_opt.ll
```
to apply any optimizations encoded in `${OPTFLAGS}`.

#### 4. Compile the executable

Run
```sh
flang output_opt.ll ${FCFLAGS2} -o ${EXE}
```
to compile the program as an executable with filename `${EXE}`.

### One-shot approach

Alternatively, we can apply Enzyme and compile the executable in one step via
the Flang plugin with
```sh
flang -fpass-plugin=/path/to/FlangEnzyme-${VN}.so ${FFLAGS} test.f90 -o ${EXE}
```
where `${VN}` is the Flang version and `${EXE}` is the name of the executable.

# Examples Reference

The `enzyme/test/Fortran/` directory contains several tests that can be read as
examples:

- `ReverseMode/square*.f90` - 'Hello, World!' for reverse mode
- `ReverseMode/norm*.f90` - Normalise an array using a sum over entries
- `ReverseMode/dot*.f90` - Compute a dot product of two arrays
- `ReverseMode/allocatable_array_with_bindings*.f90` - Working with allocatable
- `ForwardMode/allocatable_array_with_bindings*.f90` - Working with allocatable
  arrays for forward mode
- `BatchMode/square*.f90` - Compute a square of a batch of scalar values

Note that most of these tests have different variants to account for the
differing levels of support in Enzyme and in the Flang and IFX compilers:

- `*_with_explicit_interface.f90` tests use an explicit interface to handle
  function hooks rather than using the Fortran bindings.
- `*_with_bindings*.f90` tests use the Fortran bindings.
- `*_O0.f90` tests do not consider applying compiler optimizations.
- `*_opt.f90` tests only consider applying compiler optimizations.

# Workflow

1. Import `enzyme`.
2. Declare shadow variables for each argument of the procedure you seek to
   differentiate.
3. Add a call to the relevant function hook (e.g., `enzyme_fwddiff` or
   `enzyme_autodiff`). Arguments are generally interleaved with the
   corresponding shadows.
4. Optionally mark primal-shadow argument pairs with activity descriptors. In
   the cases of `enzyme_const` and `enzyme_out`, there is no need to interleave
   with shadows.

## See Also

**CRITICAL: For up-to-date information, see the [README on Fortran bindings](https://github.com/EnzymeAD/Enzyme/blob/main/enzyme/Fortran/README.md)**

- [Enzyme Repository](https://github.com/EnzymeAD/Enzyme)
- [Enzyme website](https://enzyme.mit.edu/)
