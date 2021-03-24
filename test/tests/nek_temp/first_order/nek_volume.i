[Problem]
  type = NekRSProblem
[]

[Mesh]
  type = NekRSMesh
  order = FIRST
  volume = true
[]

[AuxVariables]
  [analytic]
  []
  [error_temp]
    order = CONSTANT
    family = MONOMIAL
  []
  [difference]
  []
[]

[ICs]
  [analytic]
    type = FunctionIC
    variable = analytic
    function = analytic
  []
[]

[AuxKernels]
  [error_temp]
    type = ElementL2ErrorFunctionAux
    variable = error_temp
    coupled_variable = temp
    function = analytic
  []
  [difference]
    type = ParsedAux
    variable = difference
    args = 'analytic temp'
    function = 'temp-analytic'
  []
[]

[Executioner]
  type = Transient

  [TimeStepper]
    type = NekTimeStepper
  []
[]

[Functions]
  [analytic]
    type = ParsedFunction
    value = 'exp(x)+sin(y)+x*y*z'
  []
[]

[Postprocessors]
  [l2_error_in_nek_temp]
    type = ElementL2Error
    variable = temp
    function = analytic
  []
  [max_diff]
    type = NodalExtremeValue
    variable = difference
    value_type = max
  []
  [min_diff]
    type = NodalExtremeValue
    variable = difference
    value_type = min
  []
  [flux_integral]
    type = Receiver
  []
  [source_integral]
    type = Receiver
  []
[]

[Outputs]
  exodus = true
  execute_on = 'final'
  hide = 'flux_integral source_integral heat_source'
[]