%2-D spacecraft lander modeling
%109-1 Control System
%Code writter: Yi-Lun Hsu <r07921067@ntu.edu.tw>
%Professor: Cheng-Wei Chen <cwchenee@ntu.edu.tw>
%All rights reserved.
%----------------------------------------------------------------------------------

clear;clc;close all;
%% -----------Start of the dynamics-----------
%% kinetic energy function
% function yke=ke(m,u) %kinetic energy
% L=length(u);
% yke=0;
% for i=1:L
%     yke=yke+0.5*m*(u(i))^2;
% end
%% Gravity potential energy function
% function ygpe=gpe(m,g,h) %Gravity potential energy
% ygpe=m*g*h;
%% Spring potential energy function
% function yspe=spe(k,x)   %Spring potential energy
% yspe=0.5*k*(x^2);
%-------------------------------------------------

%parameters

%%%% syms x
%%%% creates a symbolic variable x in the MATLAB workspace with the value x assigned to the variable x.
%% variables
syms xbf zbf l1f l2f thetaf
syms xb_dotf zb_dotf l1_dotf l2_dotf theta_dotf
syms q1f u1f q2f u2f
%replaced by
syms xb(t) zb(t) l1(t) l2(t) theta(t)
syms xb_dot(t) zb_dot(t) l1_dot(t) l2_dot(t) theta_dot(t)
syms q1(t) u1(t) q2(t) u2(t)

xb_dot(t) = diff(xb,t);
zb_dot(t) = diff(zb,t);
l1_dot(t) = diff(l1,t);
l2_dot(t) = diff(l2,t);
theta_dot(t) = diff(theta,t);
%{
%% 1-D Lander parameters
mb = 10;       %(kg)- Mass of the lander body
m1 = 0.5;      %(kg)- Mass of leg
m2 = 0.5;
Ig = 3.7309;
mp = 0.2;      %(kg)- Mass of VCM
mc = mp + mb;  %(kg)- Mass of mp+mb
k = 7000;      %(N/m)- Buffer spring stiffness
c = k/20;      %(N.s/m)- Buffer damper coefficient
lss = 0.8;     %(m)- Length of the buffer
lss = 0.8;
W = 1;         %(m)- Width of the body
H = 1;         %(m)- Height of the body
R = sqrt(2);
gamma = pi/4;
alpha = pi/3;
S = 1.3856;
%% 1-D AMEID parameters
L_stroke = 0.5;%(m)- Guide length
md = 0.5;      %(kg)- Damper mass
%% Gravity & Ground Properties

g = 9.80665;   %(m/s^2)-Standard gravity-the nominal gravitational acceleration of an object in a vacuum near the surface of the Earth
kf = 7.5e4;    %(N/m)-Ground spring stiffness
cf = 130;      %(N.s/m)-Ground damper coefficient
uk = 0.3;      %kinetic friction coefficient
%}
syms mb mp m1 m2 Ig mc k c lss g
syms W H R gamma alpha S
syms L_stroke md kf cf uk
%% Generalized coordinates q=[xb,zb,l1]'
q = [xbf;zbf;l1f;l2f;thetaf];
%% q(t)
qt = subs(q,{xbf,zbf,l1f,l2f,thetaf},{xb,zb,l1,l2,theta}); % f(t)

%%%% syms a b
%%%% subs(a + b, a, 4)
%%%% Replace a with 4 in this expression.
%% Generalized velocities u=dq/dt=[xb_dot,zb_dot,l1_dot]'
u = [xb_dotf;zb_dotf;l1_dotf;l2_dotf;theta_dotf];
%% u(t)
ut = subs(u,{xb_dotf,zb_dotf,l1_dotf,l2_dotf,theta_dotf},{xb_dot,zb_dot,l1_dot,l2_dot,theta_dot}); % f(t)

lenq = length(q);
%vectors
qb = [xbf;zbf];
ra1_c = [S*cos(alpha)+W/2; S*sin(alpha)-H/2];
ra2_c = [-S*cos(alpha)-W/2; S*sin(alpha)-H/2];
ql1_c = [l1f*cos(alpha); l1f*sin(alpha)];
ql2_c = [-l2f*cos(alpha); l2f*sin(alpha)];
Rc = [cos(thetaf) -sin(thetaf); sin(thetaf) cos(thetaf)];
ra1 = Rc*ra1_c;
ra2 = Rc*ra2_c;
%ql1 = [0;l1f];
ql1 = Rc*ql1_c;
ql2 = Rc*ql2_c;
ub = [xb_dotf;zb_dotf];
%q1f = qb - ql1;
q1f = qb - ra1 - ql1; %xbf, zbf, thetaf, l1f
q2f = qb - ra2 - ql2;

q1 = subs(q1f, {xbf, zbf, l1f, l2f, thetaf}, {xb, zb, l1, l2, theta}); % f(t)
q2 = subs(q2f, {xbf, zbf, l1f, l2f, thetaf}, {xb, zb, l1, l2, theta}); % f(t)
u1 = diff(q1,t); % f(t)
u2 = diff(q2,t); % f(t)

u1f = subs(u1, {xb(t), zb(t), l1(t), l2(t), theta(t), diff(xb(t),t), diff(zb(t),t), diff(l1(t),t), diff(l2(t),t), diff(theta(t), t)}, {xbf, zbf, l1f, l2f, thetaf, xb_dotf, zb_dotf, l1_dotf, l2_dotf, theta_dotf});
u2f = subs(u2, {xb(t), zb(t), l1(t), l2(t), theta(t), diff(xb(t),t), diff(zb(t),t), diff(l1(t),t), diff(l2(t),t), diff(theta(t), t)}, {xbf, zbf, l1f, l2f, thetaf, xb_dotf, zb_dotf, l1_dotf, l2_dotf, theta_dotf});

% Kinetic Energy
Tf = ke(mc,ub)+ke(m1,u1f)+ke(m2,u2f)+ke(Ig, theta_dotf);
% Potential Energy
Vf = gpe(mc,g,qb(2)) + gpe(m1,g,q1f(2)) + gpe(m2,g,q2f(2)) + spe(k,l1f-lss) + spe(k,l2f-lss);
% Dissipative Energy
Wf = spe(c,l1_dotf) + spe(c,l2_dotf);
%Lagrangian
Lf = Tf-Vf;
%M
Mf1 = [diff(Tf,u(1));diff(Tf,u(2));diff(Tf,u(3));diff(Tf,u(4));diff(Tf,u(5))];
Mf = [diff(Mf1,u(1)) diff(Mf1,u(2)) diff(Mf1,u(3)) diff(Mf1,u(4)) diff(Mf1,u(5))];

%M^(-1)
Mf_inv = inv(Mf);
Mf_invt=subs(Mf_inv,{xbf,zbf,l1f,l2f,thetaf,xb_dotf,zb_dotf,l1_dotf,l2_dotf,theta_dotf},{xb,zb,l1,l2,theta,xb_dot,zb_dot,l1_dot,l2_dot,theta_dot});
%% Force matrix
%h0 = [diff(Tf,u(1));diff(Tf,u(2));diff(Tf,u(3));diff(Tf,u(4));diff(Tf,u(5))];
h0 = [diff(Tf,q(1));diff(Tf,q(2));diff(Tf,q(3));diff(Tf,q(4));diff(Tf,q(5))];
h1 = [diff(Tf,q(1));diff(Tf,q(2));diff(Tf,q(3));diff(Tf,q(4));diff(Tf,q(5))];   %(dTf/dq)'
h2 = [diff(Vf,q(1));diff(Vf,q(2));diff(Vf,q(3));diff(Vf,q(4));diff(Vf,q(5))];   %(dVf/dq)'
%h3 = [diff(h0,q(1)) diff(h0,q(2)) diff(h0,q(3)) diff(h0,q(4)) diff(h0,q(5))]*u; %(ddTf/dudq)'*u
h3 = [diff(h0,u(1)) diff(h0,u(2)) diff(h0,u(3)) diff(h0,u(4)) diff(h0,u(5))]*u;
Qd = [diff(Wf,u(1));diff(Wf,u(2));diff(Wf,u(3));diff(Wf,u(4));diff(Wf,u(5))];
hf=-Qd+h1-h2-h3;
ht=subs(hf,{xbf,zbf,l1f,l2f,thetaf,xb_dotf,zb_dotf,l1_dotf,l2_dotf,theta_dotf},{xb,zb,l1,l2,theta,xb_dot,zb_dot,l1_dot,l2_dot,theta_dot});
ht=simplify(ht);
%------------------------------------------
%% minimize symbolic function
symmin=@(x,y)feval(symengine,'min',x,y);
%---------------------------------------------
%% Contact force
%contact distance (normal)
syms gNb gN1 gN2       %zb(t) q1(2)
%contact velocity (normal)
syms rNb rN1 rN2      %zb_dot(t) u1(2)
%contact distance (tangential)
syms gTb gT1 gT2      %xb(t) q1(1)
%contact velocity (tangential)
syms rTb rT1 rT2      %xb_dot(t) u1(1)
syms kf cf         %ground spring and damper
syms uk            %kinetic friction coefficient
gNb = q(2);
gN1 = q1f(2);
gN2 = q2f(2);
gN = [gN1 gN2 gNb];

rNb = u(2);
rN1 = u1f(2);
rN2 = u2f(2);
rN = [rN1 rN2 rNb];

gTb = q(1);
gT1 = q1f(1);
gT2 = q2f(1);

rTb = u(1);
rT1 = u1f(1);
rT2 = u2f(1);
rT = [rT1 rT2 rTb];
%% Gravity & Ground Properties
%{
g = 9.80665;             %(m/s^2)-Standard gravity-the nominal gravitational acceleration of an object in a vacuum near the surface of the Earth
kf = 7.5e4;              %(N/m)-Ground spring stiffness
cf = 130;                %(N.s/m)-Ground damper coefficient
uk = 0.3;                %kinetic friction coefficient
kk = 10;
beta = 20;
%}
syms kk beta

LambdaN1 = kf*gN1*symmin(sign(gN1),0) - cf*rN1*symmin(sign(rN1),0)*symmin(sign(gN1),0);
LambdaN2 = kf*gN2*symmin(sign(gN2),0) - cf*rN2*symmin(sign(rN2),0)*symmin(sign(gN2),0);
%LambdaNb = kf*gNb*symmin(sign(gNb),0) - 10*cf*rNb*symmin(sign(rNb),0)*symmin(sign(gNb),0);
LambdaNb = kf*gNb*symmin(sign(gNb),0) - cf*rNb*symmin(sign(rNb),0)*symmin(sign(gNb),0);  %I delete the 10 which was multiplied before cf
LambdaN = [LambdaN1;LambdaN2;LambdaNb];
%
LambdaT1 = -uk*LambdaN1*sign(rT1);
LambdaT2 = -uk*LambdaN2*sign(rT2);
LambdaTb = -uk*LambdaNb*sign(rTb);
LambdaT = [LambdaT1;LambdaT2;LambdaTb];
%
WN = [diff(gN,q(1));diff(gN,q(2));diff(gN,q(3));diff(gN,q(4));diff(gN,q(5))];
WT = [diff(rT,u(1));diff(rT,u(2));diff(rT,u(3));diff(rT,u(4));diff(rT,u(5))];
P = WN*LambdaN+WT*LambdaT;

Pt=subs(P,{xbf,zbf,l1f,l2f,thetaf,xb_dotf,zb_dotf,l1_dotf,l2_dotf,theta_dotf},{xb,zb,l1,l2,theta,xb_dot,zb_dot,l1_dot,l2_dot,theta_dot});

%--------------------------------
%% Without Ameid
%M_bar = Mf_invt*(Pt+ht);  %Withot Ameid
%--------------------------------
%% With Ameid
%AMEID dynamic
%parameters
syms kF mp md La kv Ra
%states
syms iarf ialf xprf xplf xpr_dotf xpl_dotf
syms iar(t) ial(t) xpr(t) xpl(t) xpr_dot(t) xpl_dot(t)     %xmeidt(t)=[ia(t) xp(t) xp_dot(t)]';
%input
syms Vr Vl dt

xpr_dot(t)=diff(xpr,t);
xpl_dot(t)=diff(xpl,t);
xmeidrf = [iarf;xprf;xpr_dotf];
xmeidlf = [ialf;xplf;xpl_dotf];
xmeidrt = subs(xmeidrf,{iarf,xprf,xpr_dotf},{iar,xpr,xpr_dot}); % f(t)
xmeidlt = subs(xmeidlf,{ialf,xplf,xpl_dotf},{ial,xpl,xpl_dot}); % f(t)
%{
%parameter values
md=0.5;                %(kg)
mp=0.2;                %(kg)
La=6.4e-3;             %(H)
Ra=5.2;                %(Ohm)
kv=17;                 %(V.s/m)
kF=17;                 %(N/A)
%}
%% Ameid state-space matrix
Aam = [-Ra/La 0 -kv/La;0 0 1;kF/(mp+md) 0 0];
Bam = [1/La;0;0];
Cam = [kF 0 0];

Fmeidr = Cam*xmeidrf;
Fmeidl = Cam*xmeidlf;
%% AMEID force matrix - right
%Fxr = sin(thetaf)*Fmeidr;
%Fzr = -cos(thetaf)*Fmeidr;
dWr = (S+l1f)*cos(alpha);
%Tr = (-W-dWr)*Fmeidr;
hr = [sin(thetaf);-cos(thetaf);sym(0);sym(0);-W-dWr]*Fmeidr;
hrt = subs(hr,{iarf, thetaf, l1f}, {iar, theta, l1});

%% AMEID force matrix - left
%Fxl = sin(thetaf)*Fmeidl;
%Fzl = -cos(thetaf)*Fmeidl;
dWl = (S+l2f)*cos(alpha);
%Tl = (W+dWl)*Fmeidl;
hl = [sin(thetaf);-cos(thetaf);sym(0);sym(0);W+dWl]*Fmeidl;
hlt = subs(hl,{ialf, thetaf, l2f},{ial, theta, l2});
%--------------------------------
M_bar_u=Mf_invt*(Pt+ht+hrt+hlt); %With AMEID   %dimension: 3x1
M_bar = M_bar_u;

if 0
    q1f
    q2f
    u1f
    u2f
    Mf
    hf
    P
    hr
    hl
end
%%----------------------------------------------------------------------------------
%%----------------------------------------------------------------------------------

%{
%% Non-linear ode
%non-linear odes
ode1 = diff(ut(1)) == M_bar(1);
ode2 = diff(ut(2)) == M_bar(2);
ode3 = diff(ut(3)) == M_bar(3);
ode4 = diff(ut(4)) == M_bar(4);
ode5 = diff(ut(5)) == M_bar(5);
ode6 = diff(xmeidrt) == Aam*xmeidrt + Bam*Vr;
ode7 = diff(xmeidlt) == Aam*xmeidlt + Bam*Vl;
odes=[ode1;ode2;ode3;ode4;ode5;ode6;ode7];

%% non-linear fuction
[Veq,Seq] = odeToVectorField(odes);
Meq = matlabFunction(Veq,'vars', {'t','Y'});

%% Simuation calculation
Tf=10;  %simulation time
tspan=[0 Tf]; %simulation horizon
dt=.0005; %time step
x0=[lss 0 lss 0 6 0 6 0 0 0];  %initial condition
% l1 l1_dot l2 l2_dot xb xb_dot zb zb_dot theta theta_dot
options = odeset('Mass',eye(6),'RelTol',1e-4,'AbsTol',[1e-5 1e-5 1e-5 1e-5 1e-5 1e-5]);
[t,sol] = ode45(Meq,tspan,x0); %use ode45,ode23,ode15s solver to solve the equation
t0 = (0:dt:Tf)';
sol0 = interp1(t,sol,t0,'makima');   %interpolation for equal dt

F_impact= -k.*(sol0(:,1)-lss)-k.*(sol0(:,3)-lss)-c.*(sol0(:,2))-c.*(sol0(:,4));
Fmax=max(F_impact);

%% Plot non-linear result
kfig(1)=figure;
subplot(3,1,1);
plot(t0,sol0(:,7)); %zb(t)
hold on;
plot(t0,sol0(:,1)); %l1(t)
hold off;
L0=legend('$z_{b}$(t)','$l_{1}$(t)','Interpreter','Latex');
set(L0,'FontSize',10);
grid on;
xlabel('Time [s]','Interpreter','Latex');
ylabel('Response [m]','Interpreter','Latex');
title({'Response without AMEID';['$x_{b}$(t0)=',num2str(x0(3)),'[m],','$z_{b}$(t0)=',num2str(x0(5)),'[m],',...
    '$l_{1}$(t0)=',num2str(x0(1)),'[m]'];['  $\dot{xb}$(t0)=',num2str(x0(4)),'[m/s],','$\dot{zb}$(t0)=',num2str(x0(6)),'[m/s],','$\dot{l_{1}}$(t0)=',num2str(x0(2)),'[m/s].']},'Interpreter','Latex');
%set(findall(gcf,'type','line'),'linewidth',2);
%kfig(2)=figure;
subplot(3,1,2);
plot(t0,F_impact);
L0=legend('F(force on leg)','Interpreter','Latex');
set(L0,'FontSize',10);
grid on;
xlabel('Time [s]','Interpreter','Latex');
ylabel('[N]','Interpreter','Latex');
title(['Impact Force,','Fmax:',num2str(Fmax),'[N]'],'Interpreter','Latex');
%set(findall(gcf,'type','line'),'linewidth',2);
%kfig(3)=figure;
subplot(3,1,3);
plot(t0,sol0(:,6)); %zb_dot(t)
hold on;
plot(t0,sol0(:,4));%xb_dot(t)
hold off;
L0=legend('$\dot{zb}$(t)','$\dot{xb}$(t)','Interpreter','Latex');
set(L0,'FontSize',10);
grid on;
xlabel('Time [s]','Interpreter','Latex');
ylabel('Velocity Response [m/s]','Interpreter','Latex');
set(findall(gcf,'type','line'),'linewidth',2);

%}