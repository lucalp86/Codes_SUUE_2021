% # ==========================================================================
% # Copyright (C) 2021 Dr. Luca Papini
% #
% # This file is part of the codes developed for the 
% # University of Pisa - 2021 module of 
% # "Systems of utilisation of electrical energy"
% #
% # This code is free: you can redistribute it and/or modify
% # it under the terms of the GNU General Public License as published by
% # the Free Software Foundation, either version 3 of the License, or
% # (at your option) any later version.
% #
% # This code is distributed in the hope that it will be useful,
% # but WITHOUT ANY WARRANTY; without even the implied warranty of
% # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% # GNU General Public License for more details.
% #
% # You should have received a copy of the GNU General Public License
% # along with Foobar.  If not, see 
% #
% #             http://www.gnu.org/licenses/
% #
% # ==============================================================================
%% # ======================= Electromagnet - FEMM ================================                  
% # ==============================================================================
clc;close all;clear;

mu0 = 4*pi*10^-7;             % Vacuum magnetic permeability [H/m]
Res20_Cu = 1.68*10^-8;        % Resistivity copper [ohm*m] @ 20 [C]
alphaT_Cu = 0.004041;         % Temperature-resistivity coefficient copper [1/C]

% =========================================================================
%% ================ Material Input Data (linear)
% =========================================================================

% ------ Air gap
Mu_X_AG=1;              % Air gap fluid X-Relative magnetic permeability
Mu_Y_AG=Mu_X_AG;        % Air gap fluid Y-Relative magnetic permeability
Sigma_AG=0;             % Conductivity air gap fluid in [MS/m]

% ------ Stator Conductor 
Temp_ConductStat=20;                                           % Operative temperature Stator Conductor  
Rho_ConductStat=Res20_Cu*(1+alphaT_Cu*(Temp_ConductStat-20));   % Resistivity Conductor stator [ohm*m]

Mu_X_CuStat=1;                                    % Stator Copper X-Relative magnetic permeability
Mu_Y_CuStat=Mu_X_CuStat;                          % Stator Copper Y-Relative magnetic permeability
Sigma_CuStat=1/Rho_ConductStat*10^-6;             % Conductivity Stator Copper in [MS/m]

% ------ Stator (C-core) Soft-Fe
Mu_X_FeStat=5000;           % Stator iron X-Relative magnetic permeability
Mu_Y_FeStat=Mu_X_FeStat;    % Stator iron Y-Relative magnetic permeability
Sigma_FeStat=0;             % Conductivity Stator iron in [MS/m]

% ------ Mover (flat bar) ) Soft-Fe
Mu_X_FeRot=5000;            % Rotor iron X-Relative magnetic permeability
Mu_Y_FeRot=Mu_X_FeRot;      % Rotor iron Y-Relative magnetic permeability
Sigma_FeRot=0;              % Conductivity Rotor iron in [MS/m]

% =========================================================================
%% ================ Geometry Input Data 
% =========================================================================
NonLinear = 1;
active_length = 100;

% ---- Mover dimensions
eps_mover = 5;
width_mover = 20;

% ---- Stator & Coil dimensions
air_gap = 0.5;
tooth_width = width_mover / 4;
opening_width = width_mover - 2 * tooth_width;
tooth_heigth = tooth_width;

coil_heigth = tooth_heigth/3*2;

% -------- Coil and Current settings
turns = 100;
current = linspace(0, 20, 11);

% -------- Mesh settings
SizeMesh_Air = 0.5;
SizeMesh_Mover = 1;
SizeMesh_Stator = 1;
SizeMesh_Coil = 2;
SizeMesh_Air_out = 8;

% ------- Post Processing
Npoint_Bsampling = 100;
PositionY = 0;

% =========================================================================
%% ================ Initialise the FEMM application
% =========================================================================

% ----- Select the path of the m.file for the femm application
addpath('C:\femm42\mfiles');

% ----- Open femm application
openfemm;

% ----- Create new document
newdocument(0);

% ----- Problem definition
mi_probdef(0,'millimeters','planar',1.e-8, active_length ,30);

showpointprops;
main_resize(800,800);
main_restore;

%% ------ Create FEMM material
mi_addmaterial('Air', Mu_X_AG, Mu_Y_AG, 0, 0, Sigma_AG, 0, 0, 1, 0, 0, 0);

mi_addmaterial('Stator_Coil', Mu_X_CuStat, Mu_Y_CuStat, 0, 0, Sigma_CuStat, 0, 0, 1, 0, 0, 0);

mi_addmaterial('Stator_Fe', Mu_X_FeStat, Mu_Y_FeStat, 0, 0, Sigma_FeStat, 0, 0, 1, 0, 0, 0);

mi_addmaterial('Mover_Fe', Mu_X_FeRot, Mu_Y_FeRot, 0, 0, Sigma_FeRot, 0, 0, 1, 0, 0, 0);

if NonLinear == 1
    load('BHcurves_students.mat');

    for k = 1 : size(B_M19,1)
        mi_addbhpoint('Stator_Fe', B_M19(k,1), H_M19(k,1));
    end
    
%     for k = 1 : size(B_Hoganas,1)
%         mi_addbhpoint("Stator_Fe", B_Hoganas(k,1), H_Hoganas(k,1))
%     end
    
end

% =========================================================================
%% ================ Design Geometry 
% =========================================================================

% ===== Group definition
% -----   0: stator
% -----   1: motion elements
% -----   2: winding

%% ********************* Mover
mi_drawline([-width_mover/2 0], [+width_mover/2 0]);
mi_drawline([-width_mover/2 -eps_mover], [+width_mover/2 -eps_mover]);
mi_drawline([+width_mover/2 0], [+width_mover/2 -eps_mover]);
mi_drawline([-width_mover/2 0], [-width_mover/2 -eps_mover]);

% ----- Create mover region
mi_addblocklabel(0,-eps_mover/2);
mi_selectlabel(0,-eps_mover/2);
mi_setblockprop('Mover_Fe', 0, SizeMesh_Mover, 0, 0, 0, 0);
mi_setgroup(1);
mi_clearselected;
    
mi_selectsegment(0, 0)
mi_selectsegment(0, -eps_mover)
mi_selectsegment(eps_mover/2, -eps_mover/2)
mi_selectsegment(-eps_mover/2, -eps_mover/2)
mi_setgroup(1);
mi_clearselected;

%% ********************* Stator Core

mi_drawline([-width_mover/2 +air_gap], [(-width_mover/2+tooth_width) +air_gap]);
mi_drawline([+width_mover/2 +air_gap], [(+width_mover/2-tooth_width) +air_gap]);

mi_drawline([-width_mover/2 +air_gap], [-width_mover/2 (+air_gap+tooth_heigth+tooth_width)]);
mi_drawline([+width_mover/2 +air_gap], [+width_mover/2 (+air_gap+tooth_heigth+tooth_width)]);

mi_drawline([(-width_mover/2+tooth_width) +air_gap], [(-width_mover/2+tooth_width) (+air_gap+tooth_heigth)]);
mi_drawline([(+width_mover/2-tooth_width) +air_gap], [(+width_mover/2-tooth_width) (+air_gap+tooth_heigth)]);


mi_drawline([(-width_mover/2+tooth_width) (+air_gap+tooth_heigth)], [(+width_mover/2-tooth_width) (+air_gap+tooth_heigth)]);
mi_drawline([-width_mover/2 (+air_gap+tooth_heigth+tooth_width)], [+width_mover/2 (+air_gap+tooth_heigth+tooth_width)]);

% ----- Create mover region
mi_addblocklabel(0,+air_gap+tooth_heigth+tooth_width/2);
mi_selectlabel(0,+air_gap+tooth_heigth+tooth_width/2);
mi_setblockprop('Stator_Fe', 0, SizeMesh_Stator, 0, 0, 0, 0);
mi_setgroup(0);
mi_clearselected;


%% ********************* Stator Coil
% ------ Plus side
mi_drawline([(-width_mover/2+tooth_width) +air_gap+tooth_heigth-coil_heigth], [(+width_mover/2-tooth_width) +air_gap+tooth_heigth-coil_heigth]);

mi_addcircprop('Coil', current, 1);

% ----- Create coil plus region
mi_addblocklabel(0,+air_gap+tooth_heigth-coil_heigth/2);
mi_selectlabel(0,+air_gap+tooth_heigth-coil_heigth/2);
mi_setblockprop('Stator_Coil', 0, SizeMesh_Coil, 'Coil', 0, 3, turns);
mi_setgroup(2);
mi_clearselected;

% ------ Minus side
mi_drawline([(-width_mover/2+tooth_width) +air_gap+tooth_heigth+tooth_width+coil_heigth], [(+width_mover/2-tooth_width) +air_gap+tooth_heigth+tooth_width+coil_heigth]);
mi_drawline([(-width_mover/2+tooth_width) +air_gap+tooth_heigth+tooth_width], [(-width_mover/2+tooth_width) +air_gap+tooth_heigth+tooth_width+coil_heigth]);
mi_drawline([(+width_mover/2-tooth_width) +air_gap+tooth_heigth+tooth_width], [(+width_mover/2-tooth_width) +air_gap+tooth_heigth+tooth_width+coil_heigth]);

% ----- Create coil minus region
mi_addblocklabel(0,+air_gap+tooth_heigth+tooth_width+coil_heigth/2);
mi_selectlabel(0,+air_gap+tooth_heigth+tooth_width+coil_heigth/2);
mi_setblockprop('Stator_Coil', 0, SizeMesh_Coil, 'Coil', 0, 3, -turns);
mi_setgroup(2);
mi_clearselected;


%% ********************* Air-Gap
mi_drawline([-width_mover/2 0], [-width_mover/2 +air_gap]);
mi_drawline([+width_mover/2 0], [+width_mover/2 +air_gap]);

% ----- Create mover region
mi_addblocklabel(0,+air_gap);
mi_selectlabel(0,+air_gap);
mi_setblockprop('Air', 0, SizeMesh_Air, 0, 0, 0, 0);
mi_clearselected;



%% ********************* Outer Air
mi_drawline([-2*width_mover 2*width_mover], [-2*width_mover -2*width_mover]);
mi_drawline([2*width_mover 2*width_mover], [2*width_mover -2*width_mover]);
mi_drawline([2*width_mover 2*width_mover], [-2*width_mover 2*width_mover]);
mi_drawline([2*width_mover -2*width_mover], [-2*width_mover -2*width_mover]);

% ----- Create mover region
mi_addblocklabel(-2*width_mover+1,2*width_mover-1);
mi_selectlabel(-2*width_mover+1,2*width_mover-1);
mi_setblockprop('Air', 0, SizeMesh_Air_out, 0, 0, 0, 0);
mi_clearselected;

mi_saveas('Electromagnet.fem');
mi_zoomnatural();

% ================= SOLUTION OF THE PROBLEM
Field = zeros(14, Npoint_Bsampling,size(current,2));
FluxLinkage = zeros(1 ,size(current,2));   
Energy = zeros(1 ,size(current,2));   
Coenergy = zeros(1 ,size(current,2));   

for c = 1:size(current,2)

    mi_modifycircprop('Coil', 1, current(1,c));
    mi_analyze;
    
    % ================= POST-PROCESSING
    mi_loadsolution();

    x_Bsampling = linspace(-width_mover/2, width_mover/2, Npoint_Bsampling);

    % ----- Post processing / Field sampling 
    y_pos = air_gap/2;

    for f = 1 : size(x_Bsampling,2)
        x_pos = x_Bsampling(1,f);

        Field(1:14, f, c)=mo_getpointvalues(x_pos,y_pos);
        %	1: A_z           2: B_x      3: B_y
        %   4: Sigma (Conductivity)      5: En (Energy)
        %   5: H_x           6: H_y
        %   7: Jeddy (Eddy current losses)      
        %   9: Jsource (Source current density)
        %   10: Mu_x         11: Mu_y
        %   12: P_ohm (Ohmic losses)     13: P_hyst (Hysteresis losses)

    end
    
    % ----- Post processing / Circuit solution 
    CircuitSolution = mo_getcircuitproperties('Coil'); 
    FluxLinkage(1,c) = CircuitSolution(1,3);
        
    % ----- Post processing / Energy    
    mo_selectblock(0, air_gap/2);
    Coenergy(1, c) = mo_blockintegral(2);    % Pag 93 of the Manuale for the other values
    Energy(1, c) = FluxLinkage(1,c) * current (1,c) - Coenergy(1, c);
end

figure;hold all;
plot(x_Bsampling, squeeze(Field(2, :, 2)));
plot(x_Bsampling, squeeze(Field(3, :, 2)));
xlabel('x [mm]')
ylabel('Flux Density [T]')


figure;hold all;
plot(current, FluxLinkage);
xlabel('Current [A]')
ylabel('Flux Linkage [Wb]')

figure;hold all;
plot(current, FluxLinkage./current);
xlabel('Current [A]')
ylabel('Inductance [H]')

figure;hold all;
plot(current, 0.5*FluxLinkage.*current, 'k');
plot(current, Energy, 'r');
plot(current, Coenergy);
xlabel('Current [A]')
ylabel('Energy [J]')
