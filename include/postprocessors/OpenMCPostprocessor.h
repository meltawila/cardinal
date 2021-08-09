//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "GeneralPostprocessor.h"
#include "OpenMCCellAverageProblem.h"

class OpenMCPostprocessor;

template <>
InputParameters validParams<OpenMCPostprocessor>();

/**
 * Base class for providing common information to postprocessors
 * operating directly on the OpenMC solution and geometry.
 */
class OpenMCPostprocessor : public GeneralPostprocessor
{
public:
  static InputParameters validParams();

  OpenMCPostprocessor(const InputParameters & parameters);

  virtual void initialize() override {}
  virtual void execute() override {}

protected:
  // Underlying problem
  const OpenMCCellAverageProblem * _openmc_problem;
};