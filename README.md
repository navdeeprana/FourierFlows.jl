# FourierFlows.jl

<p align="left">
    <a href="https://buildkite.com/julialang/fourierflows-dot-jl">
        <img alt="Buildkite CPU+GPU build status" src="https://img.shields.io/buildkite/4d921fc17b95341ea5477fb62df0e6d9364b61b154e050a123/master?logo=buildkite&label=Buildkite%20CPU%2BGPU">
    </a>
    <a href="https://ci.appveyor.com/project/navidcy/fourierflows-jl">
        <img alt="Build Status for Windows" src="https://img.shields.io/appveyor/ci/navidcy/fourierflows-jl/master?label=Window&logo=appveyor&logoColor=white">
    </a>
    <a href="https://FourierFlows.github.io/FourierFlowsDocumentation/stable">
        <img alt="stable docs" src="https://img.shields.io/badge/documentation-stable%20release-blue">
    </a>
    <a href="https://FourierFlows.github.io/FourierFlowsDocumentation/dev">
        <img alt="latest docs" src="https://img.shields.io/badge/documentation-in%20development-orange">
    </a>
    <a href="https://codecov.io/gh/FourierFlows/FourierFlows.jl">
        <img src="https://codecov.io/gh/FourierFlows/FourierFlows.jl/branch/master/graph/badge.svg" title="codecov">
    </a>
    <a href="https://github.com/SciML/ColPrac">
      <img alt="ColPrac: Contributor's Guide on Collaborative Practices for Community Packages" src="https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet">
    </a>
    <a href="https://doi.org/10.5281/zenodo.1161724">
        <img alt="doi" src="https://zenodo.org/badge/DOI/10.5281/zenodo.1161724.svg" alt="DOI">
    </a>
</p>


## Overview

This software provides tools for partial differential equations on periodic domains using 
Fourier-based pseudospectral methods. A central intent of the software's design is also to 
provide a framework for writing new, fast solvers for new physical problems. The code is 
written in [Julia][].

For more details refer to the [documentation](https://fourierflows.github.io/FourierFlowsDocumentation/stable/).


## Installation

To install, simply do

```julia
] add FourierFlows
```

The most recent version of FourierFlows.jl requires Julia v1.5 or later.

The latest version that is compatible with Julia v1.0.5 (the current long-term-release) is FourierFlows.jl v0.4.5.


## Usage

See the documentation for tutorials on (i) how [construct grids](https://fourierflows.github.io/FourierFlowsDocumentation/stable/grids/) and use Fourier transform to compute derivatives and (ii) how to [set up a PDE](https://fourierflows.github.io/FourierFlowsDocumentation/stable/problem/), time-step it forward. and visualize the output.


## Scalability

For now, FourierFlows.jl is restricted to run on either a single CPU or single GPU. Multi-threading
can enhance performance for the Fourier transforms. By default, FourierFlows.jl will use the 
maximum number of threads available on your machine. You can set the number of threads used by
FourierFlows.jl by setting the environment variable, e.g.,

```
$ export JULIA_NUM_THREADS=4
```

For more information on multi-threading users are directed to the [Julia Documentation](https://docs.julialang.org/en/v1/manual/multi-threading/).

If your machine has more than one GPU available, then functionality within CUDA.jl package 
enables the user to choose the GPU device that FourierFlows.jl should use. The user is referred
to the [CUDA.jl Documentation](https://juliagpu.github.io/CUDA.jl/stable/lib/driver/#Device-Management);
in particular, [`CUDA.devices`](https://juliagpu.github.io/CUDA.jl/stable/lib/driver/#CUDA.devices) 
and [`CUDA.CuDevice`](https://juliagpu.github.io/CUDA.jl/stable/lib/driver/#CUDA.CuDevice).


## Example(s)

An example for coding up and solving the linear shallow water equations is [documented](https://fourierflows.github.io/FourierFlowsDocumentation/stable/generated/OneDShallowWaterGeostrophicAdjustment/).

See also the child packages [GeophysicalFlows.jl][] for example usage of FourierFlows.jl for 
problems in Geophysical Fluid Dynamics.


## Developers

FourierFlows is currently being developed by [Gregory L. Wagner][] (@glwagner)
and [Navid C. Constantinou][] (@navidcy).


## Cite

The code is citable via [zenodo](https://zenodo.org). Please cite as:

> Navid C. Constantinou & Gregory L. Wagner. (2021). FourierFlows/FourierFlows.jl: FourierFlows v0.6.15 (Version v0.6.15). Zenodo.  [http://doi.org/10.5281/zenodo.1161724](http://doi.org/10.5281/zenodo.1161724)


[Julia]: https://julialang.org/
[Navid C. Constantinou]: http://www.navidconstantinou.com
[Gregory L. Wagner]: https://glwagner.github.io
[GeophysicalFlows.jl]: https://github.com/FourierFlows/GeophysicalFlows.jl
