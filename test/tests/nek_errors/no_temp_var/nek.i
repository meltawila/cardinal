[Mesh]
  type = NekRSMesh
  boundary = '6'
[]

[Problem]
  type = NekProblem
[]

[Executioner]
  type = Transient

  [./TimeStepper]
    type = NekTimeStepper
  [../]
[]

[Outputs]
  exodus = true
[]