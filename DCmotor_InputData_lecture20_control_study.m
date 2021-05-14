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
s = tf('s');
w0 = 1 / sqrt(tau_a * tau_m);
xi = 1 / (2 * w0 * tau_a);

Hem = 1/kE * w0^2/(s^2+2*w0*xi*s+w0^2);
Hpe = 1/(1 + s * tau_pe);

Hplant = Hem * Hpe;

figure;
stepplot(Hplant)

figure;
hold all;
bode(Hem);
bode(Hpe);
bode(Hplant)
grid on;

figure;
rlocus(Hplant)
grid on;

% ----- Control Settings
se = - xi * w0 * (1 + sqrt(1 - 1/xi^2));
sm = - xi * w0 * (1 - sqrt(1 - 1/xi^2));

kP = 200;
kI = kP * sm;

sz = - kI / kP;

Hc_p = kP;
Hc_pi = kP / s * (s + sz);

figure;
hold all;
bode(Hplant)
bode(Hc_pi)
bode(Hplant * Hc_pi)
grid on;

figure;
hold all;
bode(Hplant)
bode(Hplant * Hc_pi)
bode(Hplant * Hc_pi/(1 + Hplant * Hc_pi))
grid on;

figure;
rlocus(Hplant * Hc_pi)
grid on;
