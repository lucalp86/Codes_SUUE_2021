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

tau_pe = 1e-3;

% ---- Data manipulation
kE = kT;
Jeq = 2 * J;
Ra_20 = Ra;
La = La * 10^-3;   % Armature Inductance [H]
Ia_max = Pn / (wm * pi / 30) / kT;

tau_a = La / Ra_20;
tau_m = Ra_20 * Jeq / (kT * kE); 

% ----- Control Analysis
w0 = 1 / sqrt(tau_a * tau_m);
xi = 1 / (2 * w0 * tau_a);

% ----- Control Settings
se = - xi * w0 * (1 + sqrt(1 - 1/xi^2));
sm = - xi * w0 * (1 - sqrt(1 - 1/xi^2));

kP = 200;
kI = kP * sm;

% ----- Input
T_Load = 0.2;
Vdc = 24;

Wm_ref = 1000;

wm_ref = Wm_ref * pi / 30;
T_sim = 10 * max(tau_a, tau_m);
Sol = sim('BlockDiagram_DCmotor_lecture20_control2', T_sim);

figure;
hold all;
plot(Sol.tout, Sol.yout.signals(1).values * 30 / pi, 'r');
plot(Sol.tout, Wm_ref * ones(size(Sol.tout)), 'r--')
xlabel('Time');
ylabel('Speed [rpm]')

figure;
hold all;
plot(Sol.tout, Sol.yout.signals(2).values, 'b');
xlabel('Time');
ylabel('Armature Current')

figure;
hold all;
A(1) = plot(Sol.P_resp.time, Sol.P_resp.signals.values, 'r', 'DisplayName', 'P - response');
A(2) = plot(Sol.I_resp.time, Sol.I_resp.signals.values, 'b', 'DisplayName', 'I - response');
A(3) = plot(Sol.PI_resp.time, Sol.PI_resp.signals.values, 'color', [0, 0.7,0], 'DisplayName', 'PI - response');
legend(A);
xlabel('Time');
ylabel('Controller Signal')

