%% Lander with AMEID and control - Numerical caculation
%Date:2020/11/19
%Code writter: Yi-Lun Hsu <r07921067@ntu.edu.tw>
%Professor: Cheng-Wei Chen <cwchenee@ntu.edu.tw>
%All rights reserved.
%----------------------------------------------------------------------------------

clear;clc;close all;
%% PID parameters setting-----The digital P-controller is implemented using the so-called velocity form.
Kp = 1000;
Kd = 0;
%% initialf states setting
qi =[0 11 0.8 0.8 -1.1];        %I.C. of generalized coordinates: qi = [x(to) z(to) l1(to)];
% x z l1 l2 theta
ui =[0 0 0 0 0];          %I.C. of generalized velocities:  ui = [x_dot(to) z_dot(to) l1_dot(to)];
xmi  =[0 0 0];        %I.C. of AMEID states: xmi = [
lenq=length(qi);
%% Parameters setting
%% 1-D Lander parameters
mb = 10;               %(kg)- Mass of the lander body
m1 = 0.5;              %(kg)- Mass of leg
m2 = 0.5;
mp = 0.2;              %(kg)- Mass of VCM
Ig = 3.7309;
mc = mp + mb;          %(kg)- Mass of mp+mb
k = 7000;              %(N/m)- Buffer spring stiffness
c = k/20;              %(N.s/m)- Buffer damper coefficient
lss = 0.8;             %(m)- Length of the buffer

W = 1;                 %(m)- Width of the body
H = 1;                 %(m)- Height of the body
R = sqrt(2);
gamma = pi/4;
alpha = pi/3;
S = 1.3856;
%% Gravity & Ground Properties
g = 9.80665;           %(m/s^2)-Standard gravity-the nominal gravitational acceleration of an object in a vacuum near the surface of the Earth
kf = 7.5e4;            %(N/m)-Ground spring stiffness
cf = 130;              %(N.s/m)-Ground damper coefficient
uk = 0.3;              %kinetic friction coefficient
%% AMEID parameter values
md=0.5;                %(kg)
mp=0.2;                %(kg)
La=6.4e-3;             %(H)
Ra=5.2;                %(Ohm)
kv=17;                 %(V.s/m)
kF=17;                 %(N/A)
L_stroke=0.5;          %(m)
%% Ameid state-space matrix
%pair(A,B,C)
Aam = [-Ra/La 0 -kv/La;0 0 1;kF/(mp+md) 0 0];
Bam = [1/La;0;0];
Cam = [kF 0 0];
%% Simulation condition
T = 5;                     %Simulation time
dt = 0.0005;               %Sampling time
N = floor(T/dt);           %Steps
t = (0:1:N)'*dt;
%% Definition of lander states
qn = zeros(N+1,lenq);      %Generalized coordinates
un = zeros(N+1,lenq);      %Generalized velocities

q1n = zeros(N+1,2);        %Footpad Mass coordinates
u1n = zeros(N+1,2);        %Footpad Mass velocities

q2n = zeros(N+1,2);        %Footpad Mass coordinates
u2n = zeros(N+1,2);        %Footpad Mass velocities

F_impactn = zeros(N+1,1);  %Footpad impact force
F_impactn_1 = zeros(N+1,1);
F_impactn_2 = zeros(N+1,1);
%% Definition of AMEID states
%xm = zeros(N+1,3);
xml = zeros(N+1,3);
xmr = zeros(N+1,3);
%Input
%V = zeros(N+1,1);
Vl = zeros(N+1,1);
Vr = zeros(N+1,1);
%PID error matrix
ek = zeros(N+2,1);
ekr = zeros(N+2,1);
ekl = zeros(N+2,1);

%AMEID Force matrix
Fmeidl = zeros(N+1,1);
Fmeidr = zeros(N+1,1);
%setting initialf condition
qn(1,:) = qi;
un(1,:) = ui;
xml(1,:) = xmi;
xmr(1,:) = xmi;
Launch_l = false;
Launch_r = false;
ialf = 0;
iarf = 0;

%num = 0; % L_stroke constraint
num_l = 0;
num_r = 0;
%count=0; % launch time
count_l=0;
count_r=0;
tic;

for i = 1:1:N  
    xbf = qn(i,1);
    zbf = qn(i,2);
    l1f = qn(i,3);
    l2f = qn(i,4);
    thetaf = qn(i,5);
    
    xb_dotf = un(i,1);
    zb_dotf = un(i,2);
    l1_dotf = un(i,3);
    l2_dotf = un(i,4);
    theta_dotf = un(i,5);
    
    q1n(i,:) =...
        [xbf - cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) - l1f*cos(alpha)*cos(thetaf) + l1f*sin(alpha)*sin(thetaf)
        zbf + cos(thetaf)*(H/2 - S*sin(alpha)) - sin(thetaf)*(W/2 + S*cos(alpha)) - l1f*cos(alpha)*sin(thetaf) - l1f*sin(alpha)*cos(thetaf)
        ];
    q2n(i,:) =...
        [xbf + cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf)
        zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)
        ];
    u1n(i, :) =...
        [xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)
        zb_dotf - theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) - l1_dotf*cos(alpha)*sin(thetaf) - l1_dotf*sin(alpha)*cos(thetaf) - l1f*theta_dotf*cos(alpha)*cos(thetaf) + l1f*theta_dotf*sin(alpha)*sin(thetaf)
        ];
    u2n(i,:) =...
        [xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf)
        zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)
        ];
   
        Mn = [
            [                                                                                                                                                                                                                                                            m1 + m2 + mc,                                                                                                                                                                                                                                                                       0,                                                                                                                                                                                                                                                                                                                (m1*(2*sin(alpha)*sin(thetaf) - 2*cos(alpha)*cos(thetaf)))/2,                                                                                                                                                                                                                                                                                                                (m2*(2*sin(alpha)*sin(thetaf) + 2*cos(alpha)*cos(thetaf)))/2,                                                                                                                                                                                                                                                                (m1*(2*sin(thetaf)*(W/2 + S*cos(alpha)) - 2*cos(thetaf)*(H/2 - S*sin(alpha)) + 2*l1f*cos(alpha)*sin(thetaf) + 2*l1f*sin(alpha)*cos(thetaf)))/2 - (m2*(2*cos(thetaf)*(H/2 - S*sin(alpha)) + 2*sin(thetaf)*(W/2 + S*cos(alpha)) + 2*l2f*cos(alpha)*sin(thetaf) - 2*l2f*sin(alpha)*cos(thetaf)))/2]
            [                                                                                                                                                                                                                                                                       0,                                                                                                                                                                                                                                                            m1 + m2 + mc,                                                                                                                                                                                                                                                                                                               -(m1*(2*cos(alpha)*sin(thetaf) + 2*sin(alpha)*cos(thetaf)))/2,                                                                                                                                                                                                                                                                                                                (m2*(2*cos(alpha)*sin(thetaf) - 2*sin(alpha)*cos(thetaf)))/2,                                                                                                                                                                                                                                                                (m2*(2*cos(thetaf)*(W/2 + S*cos(alpha)) - 2*sin(thetaf)*(H/2 - S*sin(alpha)) + 2*l2f*cos(alpha)*cos(thetaf) + 2*l2f*sin(alpha)*sin(thetaf)))/2 - (m1*(2*cos(thetaf)*(W/2 + S*cos(alpha)) + 2*sin(thetaf)*(H/2 - S*sin(alpha)) + 2*l1f*cos(alpha)*cos(thetaf) - 2*l1f*sin(alpha)*sin(thetaf)))/2]
            [                                                                                                                                                                                                                    m1*(sin(alpha)*sin(thetaf) - cos(alpha)*cos(thetaf)),                                                                                                                                                                                                                   -m1*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf)),                                                                                                                                                                                                                                                             m1*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf))^2 + m1*(sin(alpha)*sin(thetaf) - cos(alpha)*cos(thetaf))^2,                                                                                                                                                                                                                                                                                                                                                                           0,                                                                                                                                                                                    m1*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf))*(cos(thetaf)*(W/2 + S*cos(alpha)) + sin(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*cos(thetaf) - l1f*sin(alpha)*sin(thetaf)) + m1*(sin(alpha)*sin(thetaf) - cos(alpha)*cos(thetaf))*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf))]
            [                                                                                                                                                                                                                    m2*(sin(alpha)*sin(thetaf) + cos(alpha)*cos(thetaf)),                                                                                                                                                                                                                    m2*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf)),                                                                                                                                                                                                                                                                                                                                                                           0,                                                                                                                                                                                                                                                             m2*(sin(alpha)*sin(thetaf) + cos(alpha)*cos(thetaf))^2 + m2*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf))^2,                                                                                                                                                                                    m2*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf))*(cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf)) - m2*(sin(alpha)*sin(thetaf) + cos(alpha)*cos(thetaf))*(cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf))]
            [ m1*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)) - m2*(cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), m2*(cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf)) - m1*(cos(thetaf)*(W/2 + S*cos(alpha)) + sin(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*cos(thetaf) - l1f*sin(alpha)*sin(thetaf)), m1*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf))*(cos(thetaf)*(W/2 + S*cos(alpha)) + sin(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*cos(thetaf) - l1f*sin(alpha)*sin(thetaf)) + m1*(sin(alpha)*sin(thetaf) - cos(alpha)*cos(thetaf))*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), m2*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf))*(cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf)) - m2*(sin(alpha)*sin(thetaf) + cos(alpha)*cos(thetaf))*(cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), Ig + m1*(cos(thetaf)*(W/2 + S*cos(alpha)) + sin(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*cos(thetaf) - l1f*sin(alpha)*sin(thetaf))^2 + m1*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf))^2 + m2*(cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf))^2 + m2*(cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf))^2]
            ];
        %Mn_inv = inv(Mn);
        
        
        hn = ...
            [
            
            0
            - g*m1 - g*m2 - g*mc
            m1*(theta_dotf*cos(alpha)*sin(thetaf) + theta_dotf*sin(alpha)*cos(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)) - l1_dotf*(m1*(theta_dotf*cos(alpha)*sin(thetaf) + theta_dotf*sin(alpha)*cos(thetaf))*(sin(alpha)*sin(thetaf) - cos(alpha)*cos(thetaf)) + m1*(theta_dotf*cos(alpha)*cos(thetaf) - theta_dotf*sin(alpha)*sin(thetaf))*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf))) - theta_dotf*(m1*(theta_dotf*cos(alpha)*sin(thetaf) + theta_dotf*sin(alpha)*cos(thetaf))*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)) + m1*(theta_dotf*cos(alpha)*cos(thetaf) - theta_dotf*sin(alpha)*sin(thetaf))*(cos(thetaf)*(W/2 + S*cos(alpha)) + sin(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*cos(thetaf) - l1f*sin(alpha)*sin(thetaf)) + m1*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)) - m1*(sin(alpha)*sin(thetaf) - cos(alpha)*cos(thetaf))*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf))) - (k*(2*l1f - 2*lss))/2 - c*l1_dotf - m1*xb_dotf*(theta_dotf*cos(alpha)*sin(thetaf) + theta_dotf*sin(alpha)*cos(thetaf)) + m1*zb_dotf*(theta_dotf*cos(alpha)*cos(thetaf) - theta_dotf*sin(alpha)*sin(thetaf)) + g*m1*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf)) + m1*(theta_dotf*cos(alpha)*cos(thetaf) - theta_dotf*sin(alpha)*sin(thetaf))*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf))
            m2*(theta_dotf*cos(alpha)*cos(thetaf) + theta_dotf*sin(alpha)*sin(thetaf))*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)) - theta_dotf*(m2*(theta_dotf*cos(alpha)*cos(thetaf) + theta_dotf*sin(alpha)*sin(thetaf))*(cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf)) + m2*(theta_dotf*cos(alpha)*sin(thetaf) - theta_dotf*sin(alpha)*cos(thetaf))*(cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)) - m2*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf)) + m2*(sin(alpha)*sin(thetaf) + cos(alpha)*cos(thetaf))*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf))) - l2_dotf*(m2*(theta_dotf*cos(alpha)*cos(thetaf) + theta_dotf*sin(alpha)*sin(thetaf))*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf)) - m2*(theta_dotf*cos(alpha)*sin(thetaf) - theta_dotf*sin(alpha)*cos(thetaf))*(sin(alpha)*sin(thetaf) + cos(alpha)*cos(thetaf))) - (k*(2*l2f - 2*lss))/2 - m2*(theta_dotf*cos(alpha)*sin(thetaf) - theta_dotf*sin(alpha)*cos(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf)) - c*l2_dotf + m2*xb_dotf*(theta_dotf*cos(alpha)*sin(thetaf) - theta_dotf*sin(alpha)*cos(thetaf)) - m2*zb_dotf*(theta_dotf*cos(alpha)*cos(thetaf) + theta_dotf*sin(alpha)*sin(thetaf)) - g*m2*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf))
            theta_dotf*(m1*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf))*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)) - m1*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf))*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)) + m1*(cos(thetaf)*(W/2 + S*cos(alpha)) + sin(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*cos(thetaf) - l1f*sin(alpha)*sin(thetaf))*(theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)) - m2*(cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf))*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)) + m2*(cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf))*(theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l2_dotf*cos(alpha)*cos(thetaf) - l2_dotf*sin(alpha)*sin(thetaf) + l2f*theta_dotf*cos(alpha)*sin(thetaf) - l2f*theta_dotf*sin(alpha)*cos(thetaf)) - m1*(cos(thetaf)*(W/2 + S*cos(alpha)) + sin(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*cos(thetaf) - l1f*sin(alpha)*sin(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)) + m2*(cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf)) + m2*(cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf))*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf))) - zb_dotf*(m1*(theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)) - m2*(theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l2_dotf*cos(alpha)*cos(thetaf) - l2_dotf*sin(alpha)*sin(thetaf) + l2f*theta_dotf*cos(alpha)*sin(thetaf) - l2f*theta_dotf*sin(alpha)*cos(thetaf))) - l1_dotf*(m1*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)) - m1*(sin(alpha)*sin(thetaf) - cos(alpha)*cos(thetaf))*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)) - m1*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf))*(theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)) + m1*(sin(alpha)*sin(thetaf) - cos(alpha)*cos(thetaf))*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf))) - xb_dotf*(m1*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)) - m2*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf))) + l2_dotf*(m2*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf)) - m2*(sin(alpha)*sin(thetaf) + cos(alpha)*cos(thetaf))*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)) + m2*(sin(alpha)*sin(thetaf) + cos(alpha)*cos(thetaf))*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)) + m2*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf))*(theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l2_dotf*cos(alpha)*cos(thetaf) - l2_dotf*sin(alpha)*sin(thetaf) + l2f*theta_dotf*cos(alpha)*sin(thetaf) - l2f*theta_dotf*sin(alpha)*cos(thetaf))) + g*m1*(cos(thetaf)*(W/2 + S*cos(alpha)) + sin(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*cos(thetaf) - l1f*sin(alpha)*sin(thetaf)) - g*m2*(cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf)) + m1*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)) - m2*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf))*(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf)) - m2*(theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l2_dotf*cos(alpha)*cos(thetaf) - l2_dotf*sin(alpha)*sin(thetaf) + l2f*theta_dotf*cos(alpha)*sin(thetaf) - l2f*theta_dotf*sin(alpha)*cos(thetaf))*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)) - m1*(theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf))*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf))
            ];
    
            
            P = ...
                [
                
                uk*sign(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf))*(kf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)) - cf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*min(-sign(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf))) - uk*sign(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf))*(kf*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)) - cf*min(sign(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf))) - uk*sign(xb_dotf)*(kf*zbf*min(sign(zbf), 0) - cf*zb_dotf*min(sign(zb_dotf), 0)*min(sign(zbf), 0))
                kf*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)) - kf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)) + kf*zbf*min(sign(zbf), 0) + cf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*min(-sign(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)) - cf*min(sign(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)) - cf*zb_dotf*min(sign(zb_dotf), 0)*min(sign(zbf), 0)
                (kf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)) - cf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*min(-sign(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)))*(cos(alpha)*sin(thetaf) + sin(alpha)*cos(thetaf)) + uk*sign(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf))*(kf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)) - cf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*min(-sign(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)))*(sin(alpha)*sin(thetaf) - cos(alpha)*cos(thetaf))
                (kf*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)) - cf*min(sign(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)))*(cos(alpha)*sin(thetaf) - sin(alpha)*cos(thetaf)) - uk*sign(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf))*(kf*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)) - cf*min(sign(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)))*(sin(alpha)*sin(thetaf) + cos(alpha)*cos(thetaf))
                (kf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)) - cf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*min(-sign(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)))*(cos(thetaf)*(W/2 + S*cos(alpha)) + sin(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*cos(thetaf) - l1f*sin(alpha)*sin(thetaf)) + (kf*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)) - cf*min(sign(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)))*(cos(thetaf)*(W/2 + S*cos(alpha)) - sin(thetaf)*(H/2 - S*sin(alpha)) + l2f*cos(alpha)*cos(thetaf) + l2f*sin(alpha)*sin(thetaf)) + uk*sign(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf))*(kf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)) - cf*min(-sign(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) - zbf + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)), 0)*min(-sign(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*(theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - zb_dotf + theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l1_dotf*cos(alpha)*sin(thetaf) + l1_dotf*sin(alpha)*cos(thetaf) + l1f*theta_dotf*cos(alpha)*cos(thetaf) - l1f*theta_dotf*sin(alpha)*sin(thetaf)))*(sin(thetaf)*(W/2 + S*cos(alpha)) - cos(thetaf)*(H/2 - S*sin(alpha)) + l1f*cos(alpha)*sin(thetaf) + l1f*sin(alpha)*cos(thetaf)) + uk*sign(xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf))*(kf*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)) - cf*min(sign(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)), 0)*min(sign(zbf + cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf)), 0)*(zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)))*(cos(thetaf)*(H/2 - S*sin(alpha)) + sin(thetaf)*(W/2 + S*cos(alpha)) + l2f*cos(alpha)*sin(thetaf) - l2f*sin(alpha)*cos(thetaf))
                ];
            %%%% ------------------AMEID force------------------------%%%%
            if Launch_r == false
                if xmr(i,2)<0
                    xmr(i,2)=0;
                end
                xmr(i+1,:) = ((Aam*dt+eye(3))*(xmr(i,:))')';
              
                
            elseif Launch_r == true
                count_r = count_r + 1;
                %%%% Control Law %%%%
                %ek(i+2) = un(i,2);
                %ekr(i+2) = max(qn(i,5),0);
                ekr(i+2) = qn(i,5);
                Vr(i+1) = Vr(i) + Kp*(ekr(i+2)-ekr(i+1)) + Kd*(ekr(i+2)-ekr(i+1))/dt;
                %%%%
                
                if xmr(i,2)<0
                    xmr(i,2)=0;
                end
                
                xmr(i+1,:) = ((Aam*dt+eye(3))*(xmr(i,:))'+Bam*dt*Vr(i+1))';
                
            end
            if Launch_l == false
                if xml(i,2)<0
                    xml(i,2)=0;
                end
                
                xml(i+1,:) = ((Aam*dt+eye(3))*(xml(i,:))')';
              
            elseif Launch_l == true
                count_l = count_l + 1;
                %%%% Control Law %%%%
                %ek(i+2) = un(i,2);
                %ekl(i+2) = max(-qn(i,5),0);
                ekl(i+2) = -qn(i,5);
                Vl(i+1) = Vl(i) + Kp*(ekl(i+2)-ekl(i+1)) + Kd*(ekl(i+2)-ekl(i+1))/dt;
                %%%%
                
                if xml(i,2)<0
                    xml(i,2)=0;
                end
                
                xml(i+1,:) = ((Aam*dt+eye(3))*(xml(i,:))'+Bam*dt*Vl(i+1))';
              
            end
            %-------L_stroke constraint------
            if (xmr(i,2) >= L_stroke) || (num_r >= 1)
                xmr(i,2) = L_stroke;
                xmr(i+1,3) = 0;
                Launch_r = false;
                num_r = num_r + 1;
            end
            if (xml(i,2) >= L_stroke) || (num_l >= 1)
                xml(i,2) = L_stroke;
                xml(i+1,3) = 0;
                Launch_l = false;
                num_l = num_l + 1;
            end
            %--------------------------------
            %hu = [Fx;Fz;Fl];
            iarf = xmr(i+1, 1);
            ialf = xml(i+1, 1);
            
            hr = [ iarf*kF*sin(thetaf)
                -iarf*kF*cos(thetaf)
                0
                0
                -iarf*kF*(W + cos(alpha)*(S + l1f))];
            
            hl = [ialf*kF*sin(thetaf)
                -ialf*kF*cos(thetaf)
                0
                0
                ialf*kF*(W + cos(alpha)*(S + l2f))];
            
            %---Euler's method (Solve DAE)---
            un(i+1,:) = un(i,:) + (Mn\(hn+P+hr+hl)*dt)';
            qn(i+1,:) = qn(i,:) + un(i,:)*dt;
            %--------------------------------
            
            xbf = qn(i+1,1);
            zbf = qn(i+1,2);
            l1f = qn(i+1,3);
            l2f = qn(i+1,4);
            thetaf = qn(i+1, 5);
            
            xb_dotf = un(i+1,1);
            zb_dotf = un(i+1,2);
            l1_dotf = un(i+1,3);
            l2_dotf = un(i+1,4);
            theta_dotf = un(i+1,5);
            %{
u1n(i+1,:) = [ xb_dotf ,...
             zb_dotf - l1_dotf];
            %}
            
            u1n(i+1, :) =...
                [xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) + theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) - l1_dotf*cos(alpha)*cos(thetaf) + l1_dotf*sin(alpha)*sin(thetaf) + l1f*theta_dotf*cos(alpha)*sin(thetaf) + l1f*theta_dotf*sin(alpha)*cos(thetaf)
                zb_dotf - theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) - l1_dotf*cos(alpha)*sin(thetaf) - l1_dotf*sin(alpha)*cos(thetaf) - l1f*theta_dotf*cos(alpha)*cos(thetaf) + l1f*theta_dotf*sin(alpha)*sin(thetaf)
                ];
            u2n(i+1,:) =...
                [xb_dotf - theta_dotf*cos(thetaf)*(H/2 - S*sin(alpha)) - theta_dotf*sin(thetaf)*(W/2 + S*cos(alpha)) + l2_dotf*cos(alpha)*cos(thetaf) + l2_dotf*sin(alpha)*sin(thetaf) - l2f*theta_dotf*cos(alpha)*sin(thetaf) + l2f*theta_dotf*sin(alpha)*cos(thetaf)
                zb_dotf + theta_dotf*cos(thetaf)*(W/2 + S*cos(alpha)) - theta_dotf*sin(thetaf)*(H/2 - S*sin(alpha)) + l2_dotf*cos(alpha)*sin(thetaf) - l2_dotf*sin(alpha)*cos(thetaf) + l2f*theta_dotf*cos(alpha)*cos(thetaf) + l2f*theta_dotf*sin(alpha)*sin(thetaf)
                ];
            %-----Does Lander contact to the ground?---------
            %if (u1n(i+1,2)*u1n(i,2)<0)
            if (un(i+1,2)*un(i,2)<0) && (qn(i+1, 5)>=0)
                if (xmr(i,2)<L_stroke)
                    Launch_r = true;
                    %fprintf("Launch r\n");
                    
                else
                    Launch_r = false;
                end
            end
            
            %if (u2n(i+1,2)*u2n(i,2)<0)
            if (un(i+1,2)*un(i,2)<0) && (qn(i+1, 5)<=0)
                if (xml(i,2)<L_stroke)
                    Launch_l = true;
                    %fprintf("Launch l\n");
                    
                else
                    Launch_l = false;
                end
            end
            
            
            F_impactn(i) = -k*(qn(i,3)-lss)-c*un(i,3);
            F_impactn_1(i) = -k*(qn(i,3)-lss)-c*un(i,3);
            F_impactn_2(i) = -k*(qn(i,4)-lss)-c*un(i,4);
            
end
xmr(end,2) = xmr(end-1,2);
xml(end,2) = xml(end-1,2);
%Fmax=max(F_impactn);
Fmax_1=max(F_impactn_1);
Fmax_2=max(F_impactn_2);

toc;

if abs(un(end,2))<=1e-2 && min(qn(:, 2)>H/2)
    flag='stable';
else
    flag='unstable';
end





%% Plot non-linear result
figure(1);
subplot(3,1,1);
plot(t,qn(:,2)); %zb(t)
hold on;
%plot(t,qn(:,1)); %xb(t)
plot(t,qn(:,3)); %l1(t)
plot(t,qn(:,4)); %l2(t)
hold off;
L0=legend('$z_{b}$(t) [m]','$l_{1}$(t) [m]','Interpreter','Latex');
set(L0,'FontSize',10);
grid on;
xlabel('Time [s]','Interpreter','Latex');
ylabel('Response','Interpreter','Latex');
title({'2D Lander Free Fall Landing';['xb(t0)=',num2str(qn(1,1)),'[m],','zb(t0)=',num2str(qn(1,2)),'[m],',...
    '$l_{1}$(t0)=',num2str(qn(1,3)),'[m]', '$l_{2}$(t0)=',num2str(qn(1,4)),'[m]', '$theta$(t0)=',num2str(qn(1,5)),'[rad]'];...
    ['  $\dot{xb}$(t0)=',num2str(un(1,1)),'[m/s],','$\dot{zb}$(t0)=',num2str(un(1,2)),'[m/s],','$\dot{l_{1}}$(t0)=',num2str(un(1,3)),'[m/s].',...
    '$\dot{l_{2}}$(t0)=',num2str(un(1,4)),'[m/s].', '$\dot{theta}$(t0)=',num2str(un(1,5)),'[rad/s].']},'Interpreter','Latex');
%set(findall(gcf,'type','line'),'linewidth',2);
%kfig(2)=figure;
subplot(3,1,2);
%plot(t,F_impactn);hold on;
plot(t,F_impactn_1);hold on;
plot(t,F_impactn_2);
L0=legend('F [N](Impact Force on The Footpad)','Interpreter','Latex');
set(L0,'FontSize',10);
grid on;
xlabel('Time [s]','Interpreter','Latex');
ylabel('Impact Force','Interpreter','Latex');
%title(['Fmax:',num2str(Fmax),'[N]'],'Interpreter','Latex');
title(['Fmax:',num2str(max(Fmax_1, Fmax_2)),'[N]'],'Interpreter','Latex');
subplot(3,1,3);
plot(t,un(:,2)); %zb_dot(t)
L0=legend('$\dot{zb}$(t) [m/s]','Interpreter','Latex','Location','Southeast');
set(L0,'FontSize',10);
grid on;
xlabel('Time [s]','Interpreter','Latex');
ylabel('Velocity Response','Interpreter','Latex');
sgtitle(['\bf Lander Landing status : ',flag],'FontSize',10,'Interpreter','Latex');
set(findall(gcf,'type','line'),'linewidth',2);
%saveas(gcf, sprintf("images/%s_Kp_%d_Kd_%.4f.png", datestr(now, 'mmdd_HHMMSSFFF'), Kp, Kd));

figure(2);
%stairs(t,V);hold on;
stairs(t,Vl);hold on;
stairs(t,Vr);
L0=legend('$V$(t) [V]','Interpreter','Latex');
set(L0,'FontSize',10);
grid on;

xlabel('Time [s]','Interpreter','Latex');
ylabel('Voltage','Interpreter','Latex');
title('Control Effort','Interpreter','Latex');
set(findall(gcf,'type','stair'),'linewidth',2);

figure(3);
%plot(t,xm(:,2));
plot(t,xml(:,2));hold on; % xp, extension of leg
plot(t,xmr(:,2));
L0=legend('$xp$(t) [m]','Interpreter','Latex');
set(L0,'FontSize',10);
grid on;

xlabel('Time [s]','Interpreter','Latex');
ylabel('VCM Plate Position [m]','Interpreter','Latex');
title('AMEID-VCM Plate Position','Interpreter','Latex');
set(findall(gcf,'type','line'),'linewidth',2);


%% -------------Animation----------------
for i = 1:40:N
    x = qn(i, 1);
    z = qn(i, 2);
    theta = qn(i, 5);
    q1x = q1n(i, 1);
    q1z = q1n(i, 2);
    q2x = q2n(i, 1);
    q2z = q2n(i, 2);
    animation(x,z,theta,q1x,q1z,q2x,q2z);
end
