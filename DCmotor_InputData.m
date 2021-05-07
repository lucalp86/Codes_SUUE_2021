clc;
close all;
clear;

kE = 0.5;
kT = 0.5;
Jeq = 1;
Ra = 0.02;
La = 0.2;


Sol = sim('BlockDiagram_DCmotor_noControl', 200);


figure;
plot(Sol.tout, Sol.wm_Ia.signals(1).values);
xlabel('Time');
ylabel('Speed')

figure;
plot(Sol.tout, Sol.wm_Ia.signals(2).values);
xlabel('Time');
ylabel('Armature Current')
