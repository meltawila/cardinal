height = 0.5               # total height of the domain
pin_diameter = 0.97e-2     # pin outer diameter
pin_pitch = 1.28e-2        # pin pitch
Df = 0.825e-2              # fuel diameter
num_layers = 25            # number of layers

Rf = ${fparse Df / 2.0}
R = ${fparse pin_diameter / 2.0}

[Mesh]
  [pin]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 8
    num_sectors_per_side = '8 8 8 8 8 8 8 8'
    ring_radii = '${fparse 0.75 * Rf} ${fparse 0.85 * Rf} ${fparse 0.95 * Rf} ${Rf} ${R}'
    ring_intervals = '1 1 1 1 2'
    ring_block_ids = '2 2 2 2 3'
    polygon_size = ${fparse pin_pitch / 2.0}
    background_block_ids = '1'
    quad_center_elements = true
  []
  [delete_background]
    type = BlockDeletionGenerator
    input = pin
    block = '1'
  []
  [fluid]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 4
    num_sectors_per_side = '10 10 10 10'
    ring_radii = '${R}'
    ring_intervals = '1'
    ring_block_ids = '500'
    polygon_size = ${fparse pin_pitch / 2.0}
    background_block_ids = '1'
    background_intervals = 3
  []
  [delete_pin]
    type = BlockDeletionGenerator
    input = fluid
    block = '500'
  []
  [combine]
    type = CombinerGenerator
    inputs = 'delete_background delete_pin'
  []
  [extrude]
    type = AdvancedExtruderGenerator
    input = combine
    heights = ${height}
    num_layers = ${num_layers}
    direction = '0 0 1'
  []
  [rotate]
    type = TransformGenerator
    input = extrude
    transform = ROTATE
    vector_value = '45.0 0.0 0.0'
  []

  # We want boundary 5 to be the clad surface, because at the time we made this tutorial
  # that is what the reactor module named this boundary (so we drew that boundary in
  # some figures). If you are making a mesh from scratch, you dont need to go through
  # these gynmastics.
  [delete_5]
    type = BoundaryDeletionGenerator
    input = rotate
    boundary_names = '5'
  []
  [name_5]
    type = RenameBoundaryGenerator
    input = delete_5
    old_boundary = '9'
    new_boundary = '5'
  []
[]

# The following content is adding postprocessor(s) to check sideset areas.
# The reactor module is unfortunately quite brittle in its assignment of sideset
# IDs, so we want to be extra sure that any changes to sideset numbering are detected
# in our test suite.
[Problem]
  type = FEProblem
  solve = false
[]

[Postprocessors]
  [area_5] # should approximate 0.015236724369910496
    type = AreaPostprocessor
    boundary = '5'
  []
[]

[Executioner]
  type = Steady
[]

[Outputs]
  csv = true
[]
