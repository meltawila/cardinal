#pragma once

#include "GeneralPostprocessor.h"
#include "NekRSMesh.h"

class NekMeshInfoPostprocessor;

template <>
InputParameters validParams<NekMeshInfoPostprocessor>();

/**
 * This postprocessor is used strictly for testing the construction
 * of NekRSMesh in terms of the number of elements constructed and the
 * node coordinates of those elements. This object solely exists because
 * MOOSE's unit testing system is difficult to adapt to test objects that
 * depend on a mesh (including the mesh objects themselves). See
 *
 * https://github.com/idaholab/moose/discussions/16181
 *
 * for more information on the motivation for this object.
 */
class NekMeshInfoPostprocessor : public GeneralPostprocessor
{
public:
  NekMeshInfoPostprocessor(const InputParameters & parameters);

  virtual void initialize() override {}
  virtual void execute() override {}

  virtual Real getValue() override;

private:
  /// Type of value to compute
  const MooseEnum _test_type;

  /// Base mesh this postprocessor acts on
  const MooseMesh & _mesh;

  /// NekRS mesh this postprocessor acts on
  const NekRSMesh * _nek_mesh;

  /// element for which to read mesh information
  const int * _element;

  /// element-local node for which to read mesh information
  const int * _node;
};
