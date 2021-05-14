clc;
close all; 
clear;

s = tf('s');

w0 = 200;
xi = 1.6;

H = w0^2/(s^2+2*w0*xi*s+w0^2);

% num = w0^2;
% den = [1, 2*w0*xi, w0^2];
% H = tf(num, den);

figure;
stepplot(H)

figure;
bode(H)
grid on;

figure;
rlocus(H)
grid on;

llllllllllllllllllll

%% ===== Parametrization    Xi

w0 = 200;
Damp = linspace(0.4, 2, 9);

figure;
for x = 1:size(Damp, 2)
    xi = Damp(x);
    H = w0^2/(s^2+2*w0*xi*s+w0^2);
    stepplot(H);
    hold all;    
end

figure;
for x = 1:size(Damp, 2)
    xi = Damp(x);
    H = w0^2/(s^2+2*w0*xi*s+w0^2);
    bode(H);
    hold all;    
end
grid on;

close all;
%% ===== Parametrization     w0

xi = 0.7; 
W0 = logspace(0.1, 5, 10);

figure;
for x = 1:size(W0, 2)
    w0 = W0(x);
    H = w0^2/(s^2+2*w0*xi*s+w0^2);
    stepplot(H);
    hold all;    
end

figure;
for x = 1:size(W0, 2)
    w0 = W0(x);
    H = w0^2/(s^2+2*w0*xi*s+w0^2);
    bode(H);
    hold all;    
end
grid on;






