---
name: ukca
description: Use this skill when working with the UKCA atmospheric chemistry model
disable-model-invocation: false
---

# What I do

This skill provides guidance on how to work with the United Kingdom Chemistry
and Aerosols (UKCA) model for atmospheric chemistry and aerosol micro-physics.

# When to use this skill

Use this skill whenever a user mentions UKCA.

# Details

UKCA is written in Fortran.

UKCA is comprised of three main submodels:
* Atmospheric chemistry model, ASAD
* Aerosol micro-physics model, GLOMAP
* Photolysis model, FAST-JX

The main driver subroutine can be found in
`src/control/core/top_level/ukca_main1-ukca_main1.F90`.

## ASAD details

### Solver strategy

#### Method

* For a given time window to be integrated over, the most common configuration
  of ASAD applies the Implicit Euler timestepping scheme to a chunk of data
  points with a default timestep.
* In each iteration, it applies a Newton solver and in each nonlinear iteration
  it applies a full LU factorisation to solve the linear system.
* If any grid-boxes in the chunk fail to solve with the current timestep, the
  timestep is halved and another attempt is made until convergence is attained.

#### Code

* The ASAD code can be found in the `src/science/core/chemistry/asad/`
  subdirectory.
* Most variables are defined and initialised in the `asad_mod` module in
  `asad_mod.F90`.
* The entry-point for calling the ASAD solver is the `asad_cdrive` subroutine in
  `asad_cdrive.F90`.
* `asad_cdrive` sets up the model inputs and then - in the more common configurations -
  calls `asad_spmjpdriv`.
* `asad_spmjpdriv` drives the timestepping scheme, including handling the
  adaptive timestepping.
* `asad_spmjpdriv` calls `asad_spimpmjp`, which drives the nonlinear solver.
* `asad_spimpmjp`, in turn, calls the `splinlsv2` subroutine from
  `asad_sparse_vars`, which is the linear solver.

### Chunking strategy

The main chunking approaches for ASAD are:
* By horizontal level, with entry point
  `src/science/core/chemistry/ukca_chemistry_ctl.F90`
* By vertical column, with entry point
  `src/science/core/chemistry/ukca_chemistry_ctl_col_mod.F90`
* By passing all grid-boxes on the MPI rank, with entry point
  `src/science/core/chemistry/ukca_chemistry_ctl_full_mod.F90`

## See Also

- [UKCA website](https://www.ukca.ac.uk)
- [UKCA repository](https://github.com/MetOffice/ukca)
