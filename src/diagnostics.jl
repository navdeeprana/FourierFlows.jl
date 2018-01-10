import Base: resize!

export AbstractDiagnostic, Diagnostic
export resize!, update!, increment!


abstract type AbstractDiagnostic end




""" A diagnostic type associated with FourierFlows.Problem types """
mutable struct Diagnostic{T} <: AbstractDiagnostic
  calc::Function
  prob::Problem
  num::Int
  data::Array{T, 1}
  time::Array{Float64, 1}
  step::Array{Int64, 1}
  value::T
  count::Int
  freq::Int
end

""" Constructor for the ProblemDiagnostic type. """
function Diagnostic(calc::Function, prob::FourierFlows.Problem; freq=1,
  nsteps=1, num=ceil(Int, (nsteps+1)/freq))

  value = calc(prob)
  T = typeof(value)

  data = Array{T}(num)
  time = Array{Float64}(num)
  step = Array{Int64}(num)

  data[1] = value
  time[1] = prob.t
  step[1] = prob.step

  Diagnostic{T}(calc, prob, num, data, time, step, value, 1, freq)
end




""" Resize the diagnostic data and time arrays. """
function resize!(diag::AbstractDiagnostic, newnum::Int)
  resize!(diag.data, newnum)
  resize!(diag.time, newnum)
  resize!(diag.step, newnum)
  nothing
end





""" Update the current value of the diagnostic. """
function update!(diag::AbstractDiagnostic)
  diag.data[diag.count] = diag.calc(diag.prob)
  diag.time[diag.count] = diag.prob.t
  diag.step[diag.count] = diag.prob.step
  diag.value = diag.data[diag.count]
  nothing
end

function update!(diags::AbstractArray)
  for diag in diags
    update!(diag)
  end
  nothing
end




""" Increment a diagnostic by calculating a new value. """
function increment!(diag::AbstractDiagnostic)
  if diag.count < diag.num
    diag.data[diag.count+1] = diag.calc(diag.prob)
    diag.time[diag.count+1] = diag.prob.t
    diag.step[diag.count+1] = diag.prob.step
  else
    push!(diag.data, diag.calc(diag.prob))
    push!(diag.time, diag.prob.t)
    push!(diag.step, diag.prob.step)
    diag.num += 1
  end
  diag.count += 1
  diag.value = diag.data[diag.count]
  nothing
end



""" Increment an array of diagnostics. """
function increment!(diags::AbstractArray)
  for d in diags
    increment!(d)
  end
  nothing
end
