clc;
close all;
clear;

Vn = 24;    % Nominal Voltage  [V]
wm = 1500;  % Top Speed [rpm]
Pn = 135;   % Nominal Power [kW]
kT = 0.129; % Torque constant [Nm/A]
J = 0.0011; % Inertia [kg/m3]
Ra = 0.5;   % Armature resistance [Ohm]
La = 7.2;   % Armature Inductance [mH]

% ---- Data manipulation
kE = kT;
Jeq = 2 * J;
Ra_20 = Ra;
La = La * 10^-3;   % Armature Inductance [H]
Ia_rated = Pn / (wm * pi / 30) / kT;

tau_a = La / Ra_20;
tau_m = Ra_20 * Jeq / (kT * kE); 

% ----- Input
Vdc = 24;
k_pe = 0.5;

Va = Vdc * k_pe;
k_load = 0.01;

T_sim = 10 * max(tau_a, tau_m);

Sol = sim('BlockDiagram_DCmotor_lecture20_loadQuad', T_sim);

figure;
hold all;
plot(Sol.tout, Sol.yout.signals(1).values * 30 / pi, 'r');
xlabel('Time');
ylabel('Speed [rpm]')

figure;
hold all;
plot(Sol.tout, Sol.yout.signals(2).values, 'b');
plot(Sol.tout, Ia_rated * ones(size(Sol.tout)), 'b--');
xlabel('Time');
ylabel('Armature Current')

NptW = 100;
w_plot = linspace(1.5* min(Sol.yout.signals(1).values), 1.5* max(Sol.yout.signals(1).values), NptW);

figure;
hold all;
plot(Sol.yout.signals(1).values * 30 / pi, kT * Sol.yout.signals(2).values, 'r-o');
plot(w_plot * 30 / pi, k_load * w_plot.^2, 'r--');
xlim([1.5* min(Sol.yout.signals(1).values * 30 / pi), 1.5 * max(Sol.yout.signals(1).values * 30 / pi)]);
ylabel('Torque [Nm]');
xlabel('Speed [rpm]')


figure;
hold all;
plot(Sol.yout.signals(1).values * 30 / pi, kT * Sol.yout.signals(2).values .* Sol.yout.signals(1).values, 'b-o');
plot(w_plot * 30 / pi, k_load * w_plot.^3, 'b--');
xlim([1.5* min(Sol.yout.signals(1).values * 30 / pi), 1.5 * max(Sol.yout.signals(1).values * 30 / pi)]);
ylabel('Power [W]');
xlabel('Speed [rpm]')


