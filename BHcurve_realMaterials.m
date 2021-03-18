clc;close all;clear;
load('BHcurves_students.mat');


A=zeros(1,2);

figure;hold all;
A(1,1) = plot(H_M19,B_M19, 'r');

A(1,2) = plot(H_Hoganas,B_Hoganas, 'b');

legend(A, {'M-19', 'Hoganas'});
xlabel('H [A/m]')
ylabel('B [T]')
xlim([0 1.5*10^4]);
