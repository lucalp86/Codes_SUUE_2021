# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 10:32:01 2019

@author: Luca Papini
"""

# ==========================================================================
# Copyright (C) 2018 Dr. Luca Papini
#
# This file is part of Pyfemm, Python code for design and analysis of 
# electrical machines
#
# Pyfemm is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pyfemm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see 
#
#             http://www.gnu.org/licenses/
#
# =============================================================================
# ================================ PYFEMM =====================================
# ================================ DESIGN =====================================
# ********************* Active Magnetic Bearing (AMB) *************************
# ************************* Inner Rotor, w/o Sleeve  **************************
# ********************* Single Layer Distributed winding **********************
# =============================================================================
#
# =============================================================================
# Program:      Py_MDfemm.m
# Sub-program:  Py_MDfemm_AMB.m
# Author:       Luca Papini (lpapini)
# Date:         04/11/2019
# Version:      0.1.1
# =============================================================================
import femm 
import numpy as np
import matplotlib.pyplot as plt

plt.close("all")

Colors = np.array([[1,0,0],[0,0,1],[0,0.6,0],[1,0.5,0],[0.05,0.52,0.78],[0.17,0.5,0.34],[0.85,0.16,0],[0.08,0.17,0.55],[0.1,0.31,0.21],[0.75,0,0.75],[0,0.8,0.8],[0.2,0.8,0]])
Colors = np.tile(Colors,[3,1])

pi = np.pi 

mu0 = 4*pi*10**-7          # Vacuum magnetic permeability [H/m]

Res20_Cu = 1.68*10**-8        # Resistivity copper [ohm*m] @ 20 [C]
alphaT_Cu = 0.004041          # Temperature-resistivity coefficient copper [1/C]

# =========================================================================
# ================ Create Model Material (linear)
# =========================================================================

# ------ Air gap
Mu_X_AG = 1              # Air gap fluid X-Relative magnetic permeability
Mu_Y_AG = Mu_X_AG        # Air gap fluid Y-Relative magnetic permeability
Sigma_AG = 0             # Conductivity air gap fluid in [MS/m]

# ------ Stator Conductor 
Temp_ConductStat = 180                                           # Operative temperature Stator Conductor  
Rho_ConductStat = Res20_Cu * (1 + alphaT_Cu * (Temp_ConductStat - 20))   # Resistivity Conductor stator [ohm*m]

Mu_X_CuStat = 1                                    # Stator Copper X-Relative magnetic permeability
Mu_Y_CuStat = Mu_X_CuStat                          # Stator Copper Y-Relative magnetic permeability
Sigma_CuStat = 1/Rho_ConductStat * 10**-6             # Conductivity Stator Copper in [MS/m]

# ------ Stator Iron
#Mu_X_FeStat=float('Inf')   # Stator iron X-Relative magnetic permeability
Mu_X_FeStat = 10**5         # Stator iron X-Relative magnetic permeability
Mu_Y_FeStat = Mu_X_FeStat    # Stator iron Y-Relative magnetic permeability
Sigma_FeStat = 0             # Conductivity Stator iron in [MS/m]

# ------ Rotor Iron
# Mu_X_FeRot=Inf           # Rotor iron X-Relative magnetic permeability
Mu_X_FeRot = 10**5           # Rotor iron X-Relative magnetic permeability
# Mu_FeRot=Inf does not work (yet) with PMs
Mu_Y_FeRot = Mu_X_FeRot      # Rotor iron Y-Relative magnetic permeability
Sigma_FeRot = 0              # Conductivity Rotor iron in [MS/m]


## ------ Create FEMM material
femm.mi_addmaterial('Air', Mu_X_AG, Mu_Y_AG, 0, 0, Sigma_AG, 0, 0, 1, 0, 0, 0)

femm.mi_addmaterial('Stator_Coil', Mu_X_CuStat, Mu_Y_CuStat, 0, 0, Sigma_CuStat, 0, 0, 1, 0, 0, 0)

femm.mi_addmaterial('Stator_Fe', Mu_X_FeStat, Mu_Y_FeStat, 0, 0, Sigma_FeStat, 0, 0, 1, 0, 0, 0)

femm.mi_addmaterial('Mover_Fe', Mu_X_FeRot, Mu_Y_FeRot, 0, 0, Sigma_FeRot, 0, 0, 1, 0, 0, 0)

# =========================================================================
# ================ Geometry Input Data 
# =========================================================================
active_length = 100

eps_mover = 5
width_mover = 20

SizeMesh_Air = 1
SizeMesh_Mover = 2
SizeMesh_Stator = 2
SizeMesh_Coil = 3

# =========================================================================
# ================ Initialise the FEMM application
# =========================================================================
# ----- Open femm application
femm.openfemm() 

# ----- Create new document
#  0 for a magnetics problem, 
#  1 for an electrostatics problem, 
#  2 for a heat flow problem, 
#  3 for a current flow problem

femm.newdocument(0)

femm.main_resize(600,600)

femm.mi_probdef(0, 'meters', 'planar', 10**-8, active_length, 30)

femm.showpointprops
femm.main_restore

# *************************************************************************
# ********************* Design Stator 
# *************************************************************************

# ===== Group definition
# -----   0: stator
# -----   1: motion elements
# -----   2: winding

# ********************* Mover
femm.mi_drawline(-width_mover/2, 0, +width_mover/2, 0)
femm.mi_drawline(-width_mover/2, -eps_mover, +width_mover/2, -eps_mover)
femm.mi_drawline(+width_mover/2, 0, +width_mover/2, -eps_mover)
femm.mi_drawline(-width_mover/2, 0, -width_mover/2, -eps_mover)

# ----- Create mover region
femm.mi_addblocklabel(0, -eps_mover / 2)
femm.mi_selectlabel(0, -eps_mover / 2)
femm.mi_setblockprop('Mover_Fe', 0, SizeMesh_Mover, 0, 0, 0, 0)
femm.mi_setgroup(1)
femm.mi_clearselected()
    
femm.mi_saveas('Electromagnet_python.fem');

Current = np.zeros(1)
       
femm.mi_analyze()
femm.mi_loadsolution()
            
