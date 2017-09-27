__precompile__()

module TwoDTurb

using FourierFlows

export Params,
       Vars,
       Equation

export set_q!, updatevars!




# P A R A M S
type Params <: AbstractParams
  nu::Float64                     # Vorticity viscosity
  nun::Int                        # Vorticity hyperviscous order
end




# E Q U A T I O N S
type Equation <: AbstractEquation
  LC::Array{Complex{Float64}, 2}  # Element-wise coeff of the eqn's linear part
  calcNL!::Function               # Function to calculate eqn's nonlinear part
end

function Equation(p::Params, g::TwoDGrid)
  # Function calcNL! is defined below.
  LC = -p.nu * g.KKrsq.^(0.5*p.nun)
  Equation(LC, calcNL!)
end




# V A R S
type Vars <: AbstractVars

  t::Float64
  sol::Array{Complex128, 2}

  # Auxiliary vars
  q::Array{Float64, 2}
  U::Array{Float64, 2}
  V::Array{Float64, 2}
  Uq::Array{Float64, 2}
  Vq::Array{Float64, 2}
  psi::Array{Float64, 2}

  # Solution
  qh::Array{Complex128, 2}
  Uh::Array{Complex128, 2}
  Vh::Array{Complex128, 2}
  Uqh::Array{Complex128, 2}
  Vqh::Array{Complex128, 2}
  psih::Array{Complex128, 2}

end

function Vars(g::TwoDGrid)
  # Initialize with t=0
  t = 0.0
  sol  = zeros(Complex128, g.nkr, g.nl)

  # Vorticity auxiliary vars
  q    = zeros(Float64, g.nx, g.ny)
  U    = zeros(Float64, g.nx, g.ny)
  V    = zeros(Float64, g.nx, g.ny)
  Uq   = zeros(Float64, g.nx, g.ny)
  Vq   = zeros(Float64, g.nx, g.ny)
  psi  = zeros(Float64, g.nx, g.ny)

  qh   = zeros(Complex128, g.nkr, g.nl)
  Uh   = zeros(Complex128, g.nkr, g.nl)
  Vh   = zeros(Complex128, g.nkr, g.nl)
  Uqh  = zeros(Complex128, g.nkr, g.nl)
  Vqh  = zeros(Complex128, g.nkr, g.nl)
  psih = zeros(Complex128, g.nkr, g.nl)

  # Random initial condition
  sol = exp.( 2.0*pi*im*rand(g.nkr, g.nl) )

  return Vars(t, sol, q, U, V, Uq, Vq, psi, qh, Uh, Vh, Uqh, Vqh, psih)
end




# S O L V E R S
function calcNL!(NL::Array{Complex{Float64}, 2}, sol::Array{Complex{Float64}, 2},
  t::Float64, v::Vars, p::Params, g::TwoDGrid)

  # This copy is necessary because calling A_mul_B(v.q, g.irfftplan, sol) 
  # a few lines below destroys sol when using Julia's FFTW.
  v.qh .= sol

  A_mul_B!(v.q, g.irfftplan, sol)

  v.Uh .=    im .* g.Lr .* g.invKKrsq .* v.qh
  v.Vh .= (-im) .* g.Kr .* g.invKKrsq .* v.qh
 
  A_mul_B!(v.U, g.irfftplan, v.Uh)
  A_mul_B!(v.V, g.irfftplan, v.Vh)

  v.Uq .= v.U.*v.q
  v.Vq .= v.V.*v.q

  A_mul_B!(v.Uqh, g.rfftplan, v.Uq)
  A_mul_B!(v.Vqh, g.rfftplan, v.Vq)

  NL .= (-im) .* g.Kr.*v.Uqh .- im .* g.Lr.*v.Vqh

end




# H E L P E R   F U N C T I O N S
function updatevars!(v::Vars, g::TwoDGrid)

  v.qh .= v.sol

  # We don't use A_mul_B here because irfft destroys its input.
  # A_mul_B!(v.q, g.irfftplan, v.qh)
  v.q = irfft(v.qh, g.nx)

  v.psih .= .- v.qh .* g.invKKrsq

  v.Uh .=    im .* g.Lr .* g.invKKrsq .* v.qh
  v.Vh .= (-im) .* g.Kr .* g.invKKrsq .* v.qh
 
  # We don't use A_mul_B here because irfft destroys its input.
  #A_mul_B!(v.U, g.irfftplan, v.Uh)
  #A_mul_B!(v.V, g.irfftplan, v.Vh)
  v.U = irfft(v.Uh, g.nx)
  v.V = irfft(v.Vh, g.nx)

  v.Uq .= v.U .* v.q
  v.Vq .= v.V .* v.q

  A_mul_B!(v.Uqh, g.rfftplan, v.Uq)
  A_mul_B!(v.Vqh, g.rfftplan, v.Vq)

end




function set_q!(v::Vars, g::TwoDGrid, q::Array{Float64, 2})
  # Set vorticity
  A_mul_B!(v.sol, g.rfftplan, q)
  updatevars!(v, g)
end




""" Make a field of mature turbulence on a square grid.

  Args:
    nx: grid resolution
    Lx: grid extent
    qf: final maximum vorticity
    q0: initial maximum vorticity
    nnu: order of hyperviscosity
    maxsteps: maximum number of steps to take
    dt: time step
    nu: hyperviscosity
    k0: initial wavenumber

  Returns
    q: The vorticity field
"""
function makematureturb(nx::Int, Lx::Real; qf=0.1, q0=0.2, nnu=4, 
  maxsteps=10000, dt=nothing, nu=nothing, k0=nothing)

  # Number of substeps between vorticity-checking
  substeps = 100
  
  # Defaults
  if k0 == nothing; k0 = nx/2;                       end
  if dt == nothing; dt = 0.1/q0;                     end
  if nu == nothing; nu = 0.1/(dt*(0.65*nx/Lx)^nnu);  end

  g  = TwoDTurb.Grid(nx, Lx)
  pr = TwoDTurb.Params(nu, nnu)
  vs = TwoDTurb.Vars(g)
  eq = TwoDTurb.Equation(pr, g)
  ts = ETDRK4TimeStepper(dt, eq.LC)

  q0 = FourierFlows.peaked_isotropic_spectrum(nx, k0; maxval=q0)
  TwoDTurb.set_q!(vs, g, q0)
  maxq = maximum(abs.(vs.q))

  @printf("\nMaking a mature turbulence field with max(q) = %.2f...\n", qf)
  while maxq > qf && ts.step < maxsteps
    stepforward!(vs, substeps, ts, eq, pr, g)
    TwoDTurb.updatevars!(vs, g)
    maxq = maximum(abs.(vs.q))

    @printf("  step: %d, t*q0: %.2e, max Ro: %.3f, CFL: %.3f\n", 
      ts.step, vs.t*q0, maxq, maximum([vs.U; vs.V])*ts.dt/g.dx)
  end

  return vs.q
end







end
# E N D   T W O D T U R B >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
