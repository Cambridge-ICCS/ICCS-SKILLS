---
name: mesc
description: Use this skill when working with the MESC soil carbon cycle model
disable-model-invocation: false
---

# What I do

This skill provides guidance on working with the MESC soil carbon cycle model.

# When to use this skill

Use this skill whenever a user mentions MESC, sometimes referred to as MES-C.

# Details

* MESC is a Fortran model.
* It is a microbial-explicit model

## Code structure

* Source code can be found in the `src/` subdirectory.
* Testing code can be found in the `test/` subdirectory.
* Auxiliary code in the `auxil/` subdirectory can be ignored.
* Pre-processing code in the `pre-processing/` subdirectory can be ignored.
* Post-processing code in the `post-processing/` subdirectory can be ignored.

## Model configuration

* MESC is configured via namelist files containing various parameters:
  * `runcase`: integer in the range 1-4 that specifes the run mode.
  * Model options:
    * `jglobal`: binary integer for whether global output is requested.
    * `kinetics`: integer in the range 1-3 that specifies kinetics approach
      (1: forward MM, 2: reverse MM, 3: MES-C specific mixed forward/reverse MM).
    * `bgcopt`: integer biogeochemical type to simulate.
    * `jopt`: binary integer toggling between forward simulation vs SCE-UA
      optimisation.
    * `jrestart`: binary integer toggling between a cold start and reading
      `frestart_in`.
    * `jmodel`: integer in the range 1-3 that specifies the model used for
      forcing (1: CABLE, 2: ORCHIDEE, 3: ORCHIDEE + modis NPP)
  * Common files:
    * `frestart_in`: Restart filename to read in
    * `frestart_out`: Restart filename to write out
    * `foutput`: Output filename.
    * `fparameter`: Filename for further configuration.
  * Further runcase-specific parameters.

# Quick start

## Building the MESC model

To build MESC, navigate to the `mesc/` submodule and run `./build.sh`.

## Running the MESC test suite

To run the MESC test suite, build the model as described above, and then
navigate to the `test/` subdirectory and run `./run_main.sh`.

# Core concepts

* MESC code should be developed such that it has a modular, clear structure, to
  facilitate coupling to land surface models such as ORCHIDEE and CABLE.
* The test suite should always be run when source or build system code is
  altered.
* The Fortitude linter should always be applied when adding or modifying Fortran
  source code.

## See Also

- [MESC repository](https://github.com/CALIPSO-MESC/MESC)
