# ======================================================================================
# Cardinal Makefile
# ======================================================================================
#
# Required environment Variables:
# * NEK_CASEDIR : Dir with Nek5000 input deck (.usr, SIZE, and .rea files)
# * NEK_CASENAME : Name of the Nek5000 .usr and .rea files
#
# Optional environment variables:
# * CARDINAL_DIR : Top-level Cardinal src dir (default: this Makefile's dir)
# * CONTRIB_DIR : Dir with third-party src (default: $(CARDINAL_DIR)/contrib)
# * MOOSE_SUBMODULE : Top-level MOOSE src dir (default: $(CONTRIB_DIR)/moose)
# * NEK5_DIR : Top-level Nek5000 src dir (default: $(CONTRIB_DIR)/Nek5000)
# * LIBP_DIR : Top-level libparanumal src dir (default: $(CONTRIB_DIR)/libparanumal
# * NEK_LIBP_DIR : Top-level nek-libp src dir (default: $(CONTRIB_DIR)/NekGPU/nek-libp
#
# ======================================================================================

CARDINAL_DIR    := $(abspath $(dir $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))))
CONTRIB_DIR     := $(CARDINAL_DIR)/contrib
MOOSE_SUBMODULE ?= $(CONTRIB_DIR)/moose
NEKRS_DIR       ?= $(CONTRIB_DIR)/nekRS
OPENMC_DIR      ?= $(CONTRIB_DIR)/openmc
PETSC_DIR       ?= $(MOOSE_SUBMODULE)/petsc/arch-moose
PETSC_ARCH      ?=
LIBMESH_DIR     ?= $(MOOSE_SUBMODULE)/libmesh/installed/
HYPRE_DIR       ?= $(PETSC_DIR)
CONTRIB_INSTALL_DIR ?= $(CARDINAL_DIR)/install

HDF5_INCLUDE_DIR ?= $(HDF5_ROOT)/include
HDF5_LIBDIR ?= $(HDF5_ROOT)/lib
HDF5_INCLUDES := -I$(HDF5_INCLUDE_DIR) -I$(HDF5_ROOT)/include

# BUILD_TYPE will be passed to CMake via CMAKE_BUILD_TYPE
ifeq ($(METHOD),opt)
	BUILD_TYPE := Release
else 
	BUILD_TYPE := Debug
endif

OCCA_CUDA_ENABLED=0
OCCA_HIP_ENABLED=0
OCCA_OPENCL_ENABLED=0

NEKRS_BUILDDIR := $(CARDINAL_DIR)/build/nekrs
NEKRS_INSTALL_DIR := $(CONTRIB_INSTALL_DIR)
NEKRS_INCLUDES := \
	-I$(NEKRS_DIR)/src \
	-I$(NEKRS_DIR)/src/core \
	-I$(NEKRS_INSTALL_DIR)/gatherScatter \
	-I$(NEKRS_INSTALL_DIR)/include \
	-I$(NEKRS_INSTALL_DIR)/libparanumal/include \
	-I$(NEKRS_INSTALL_DIR)/include/libP/parAlmond \
	-I$(NEKRS_INSTALL_DIR)/include/linAlg
NEKRS_LIBDIR := $(NEKRS_INSTALL_DIR)/lib
NEKRS_LIB := $(NEKRS_LIBDIR)/libnekrs.so
# This needs to be exported
export NEKRS_HOME=$(CARDINAL_DIR)

OPENMC_BUILDDIR := $(CARDINAL_DIR)/build/openmc
OPENMC_INSTALL_DIR := $(CONTRIB_INSTALL_DIR)
OPENMC_INCLUDES := -I$(OPENMC_INSTALL_DIR)/include
OPENMC_LIBDIR := $(CONTRIB_INSTALL_DIR)/lib
OPENMC_LIB := $(OPENMC_LIBDIR)/libopenmc.so

# This is used in $(FRAMEWORK_DIR)/build.mk
ADDITIONAL_CPPFLAGS := $(HDF5_INCLUDES) $(OPENMC_INCLUDES) $(NEKRS_INCLUDES)

# ======================================================================================
# PETSc
# ======================================================================================

# Use compiler info discovered by PETSC
include $(PETSC_DIR)/$(PETSC_ARCH)/lib/petsc/conf/petscvariables

# ======================================================================================
# MOOSE core objects
# ======================================================================================

# Use the MOOSE submodule if it exists and MOOSE_DIR is not set
ifneq ($(wildcard $(MOOSE_SUBMODULE)/framework/Makefile),)
	MOOSE_DIR        ?= $(MOOSE_SUBMODULE)
else
	MOOSE_DIR        ?= $(shell dirname `pwd`)/moose
endif

# framework
FRAMEWORK_DIR      := $(MOOSE_DIR)/framework
include $(FRAMEWORK_DIR)/build.mk
include $(FRAMEWORK_DIR)/moose.mk

# ======================================================================================
# MOOSE modules
# ======================================================================================

ALL_MODULES         := no

CHEMICAL_REACTIONS  := no
CONTACT             := no
FLUID_PROPERTIES    := no
HEAT_CONDUCTION     := yes
MISC                := no
NAVIER_STOKES       := no
PHASE_FIELD         := no
RDG                 := no
RICHARDS            := no
SOLID_MECHANICS     := no
STOCHASTIC_TOOLS    := no
TENSOR_MECHANICS    := no
XFEM                := no
POROUS_FLOW         := no

include $(MOOSE_DIR)/modules/modules.mk

# ======================================================================================
# External apps
# ======================================================================================

# libmesh_CXX, etc, were defined in build.mk
export CXX := $(libmesh_CXX)
export CC  := $(libmesh_CC)
export FC  := $(libmesh_F90)
export FFLAGS := $(libmesh_FFLAGS)
export CFLAGS := $(libmesh_CFLAGS)
export CXXFLAGS := $(libmesh_CXXFLAGS)
export CPPFLAGS := $(libmesh_CPPFLAGS)
export LDFLAGS := $(libmesh_LDFLAGS)
export LIBS := $(libmesh_LIBS)

export CARDINAL_DIR

APPLICATION_DIR    := $(CARDINAL_DIR)
APPLICATION_NAME   := cardinal
BUILD_EXEC         := yes
GEN_REVISION       := no

include            $(CARDINAL_DIR)/config/nekrs.mk
include            $(CARDINAL_DIR)/config/openmc.mk

# ======================================================================================
# Building app objects defined in app.mk
# ======================================================================================

# ADDITIONAL_LIBS are used for linking in app.mk
# CC_LINKER_SLFLAG is from petscvariables
ADDITIONAL_LIBS := \
	-L$(CARDINAL_DIR)/lib \
	-L$(NEKRS_LIBDIR) \
	-L$(OPENMC_LIBDIR) \
	-lnekrs \
	-lopenmc \
	-locca \
	-lhdf5_hl \
	$(CC_LINKER_SLFLAG)$(CARDINAL_DIR)/lib \
	$(CC_LINKER_SLFLAG)$(NEKRS_LIBDIR) \
	$(CC_LINKER_SLFLAG)$(OPENMC_LIBDIR)

include            $(FRAMEWORK_DIR)/app.mk

# app_objects are defined in moose.mk and built according to the rules in build.mk
# We need to build these first so we get include dirs
$(app_objects): build_nekrs build_openmc
$(test_objects): build_nekrs build_openmc

CARDINAL_EXTERNAL_FLAGS := \
	-L$(CARDINAL_DIR)/lib \
	-L$(NEKRS_LIBDIR) \
	-L$(OPENMC_LIBDIR) \
	-L$(HDF5_LIBDIR) \
	-lnekrs \
	-lopenmc \
	$(CC_LINKER_SLFLAG)$(CARDINAL_DIR)/lib \
	$(CC_LINKER_SLFLAG)$(NEKRS_LIBDIR) \
	$(CC_LINKER_SLFLAG)$(OPENMC_LIBDIR) \
	$(CC_LINKER_SLFLAG)$(HDF5_LIBDIR) \
	$(BLASLAPACK_LIB) \
	$(PETSC_EXTERNAL_LIB_BASIC)

# EXTERNAL_FLAGS are for rules in app.mk
$(app_LIB): EXTERNAL_FLAGS := $(CARDINAL_EXTERNAL_FLAGS)
$(app_test_LIB): EXTERNAL_FLAGS := $(CARDINAL_EXTERNAL_FLAGS)
$(app_EXEC): EXTERNAL_FLAGS := $(CARDINAL_EXTERNAL_FLAGS)
