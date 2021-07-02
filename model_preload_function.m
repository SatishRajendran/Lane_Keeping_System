% model_preload_function.m
%
% Modellparameter im MATLAB Workspace setzen
%
% letzte Aenderung: 22.5.2019

% Streckendaten
global X;
global Y;
global l_v;
global l_h;
global w_ltr;
global l_l0;
global old_index_i;
global iii;
global iiii;
global l_ltr;
iii = 1;
iiii = 1;
l_ltr = [];

%% variable declaration for MPC
global Am;
global Bmm;
global Cm;
global Ap;
global Bp;
global Cp;
global Dp;
global u_init;
global xm;
global Np;
global Nc;
global r;
global sol;
global Xf;
global nu;
global ny;
global umax;
global umin;
global dumax; 
global dumin;
global k;
global Wu;
global weight_y;
global kfinal;
global n;
global delta_t;
% Fahrzeugmasse
% Symbol: m, Einheit: kg
m = 1450;

% c_w - Wert des Fahrzeugs
% Symbol: c_w, Einheit: [dimensionslos]
c_w = 0.28;

% Luftdichte
% Symbol: rho_luft, Einheit: kg/(m^3)
rho_luft = 1.204;

% "Angriffsfläche" fuer die Luft
% Symbol: A, Einheit: m^2
A = 1.9;

% Traegheitsmoment und die z-Achse
% Symbol: theta, Einheit: kg m
theta = 1920;

% Abstand Gesamtschwerpunkt - Vorderachse
% Symbol: l_v, Einheit: m
l_v = 1.3;

% Abstand Gesamtschwerpunkt - Hinterachse
% Symbol:  l_h, Einheit: m
l_h = 1.45;

% Schraeglaufsteifigkeit - Vorderrad
% Symbol:  c_v, Einheit: N / rad
c_v = 100000;

% Schraeglaufsteifigkeit - Hinterrad
% Symbol:  c_h, Einheit: N / rad
c_h = 100000;


% Startgeschwindigkeit
% Symbol: v_0, Einheit: m/s
v_0 = 10;

% Sollgeschwindigkeit
% Symbol: v_soll, Einheit: m/s
v_soll = 10;

% Polverteilung Geschwindigkeitsregelung
pv_1  = -0.1;
pv_2  = -4.8; 

% Reglerparameter Geschwindigkeitsregelung
kpv = -pv_1-pv_2;
kiv = pv_1*pv_2;


% Startposition des Fahrzeugs (x)
% Symbol:  x_0
% Einheit: m
x_0 = 00;


% Startposition des Fahrzeugs (y)
% Symbol:  y_0
% Einheit: m
y_0 = 1.5;


% Startwinkel des Fahrzeugs
% Symbol:  psi_0
% Einheit: rad
psi_0 = 0;


% Abstand zum Punkt "P"
% Symbol:  l_l0
% Einheit: m
l_l0 = 10;


% Seitlicher Wunschabstand
% Symbol:  w_ltr
% Einheit: m
w_ltr = 0;

% Polverteilung Querdynamikregelung
pq_1  = -3;
pq_2  = -5;
pq_3  = -15; 

% Reglerparameter Querdynamikregelung
alpha_q_ = -1 * pq_1 * pq_2 * pq_3; 
alpha_q0 = pq_1*pq_2 + pq_1*pq_3 + pq_2*pq_3;
alpha_q1 = -1 * (pq_1 + pq_2 + pq_3);

% Positionsindex fuer X[i] bzw. Y[i]
old_index_i = 1; 

% Variablen fuer Trajektorie initialisieren
trajectory_init;
% Trajektorie generieren
trajectory_generate;

X = X_mitte_rechts;
Y = Y_mitte_rechts;

%model_pre_load_fcn;


%% MPC ALGORITHM
%% State Space eqaution form
% Parameters definition
% State variables
% x1 = beta(slip angle);
% x2 = psi;
% x3 = psi_dot
Am =  [((c_h - c_v)/(m*v_0))                 0              (((c_h*l_h) -(c_v*l_v))/(m*v_0^2));
                 0                           0                          1;
      ((l_h*c_h)-(l_v*c_v))/theta            0        -(((c_v*l_v^2) + (c_h * l_h^2))/(v_0*theta))];
Bm =  [c_v/(m*v_0)           0;
       0                     0;
      (l_v*c_v)/theta        0];
Bmm =  Bm(:,1); 
Cm  =  eye(size(Am,1));
Dm  =  zeros(size(Cm,1),size(Bmm,2));

%% State space formulation
sys = ss(Am,Bmm,Cm,Dm);

%% Time definition
k = 1;
delta_t = 0.01;
t_final = 140;
time_vector = 0:delta_t:t_final;      % time vector  
kfinal = length(time_vector);         % final value of k and no of intervals
set_param ('einspurmodell','StopTime','t_final','Fixedstep','delta_t');     %parameters set here for simulink
r = zeros(kfinal,size(Cm,1));                  % R vector matrix for Mpc calculation and setpoint value
%r(:,1) = zeros(kfinal,1);                    % Set point vector for first state varaible
%r(:,1) = psi_ref(:,1);
%r(:,2) = psi_ref(:,1);
%r(:,3) = psi_ref(:,1);
%% Conversion into discrete system from continuous system
sysmod = c2d(sys,delta_t);

%% Data transfered to corresponding variables
[Ap,Bp,Cp,Dp] = ssdata(sysmod);

%% Definition of control and prediction horizon   %fixed values 50 and 25
Np=50;
Nc=25;

%% Inputs and Outputs
nu = size(Bmm,2);                         %no of input
ny = size(Cm,1);                          %no of output            

%% Augmented state space system
n = size(Am,1);                       %no of states
nn = size(Bm,1)+ny;                   %Size for Xf matrix augmented state

xm = zeros(n,1);
%xm = [0;0;0;0];                    % Initial state
Xf = zeros(nn,1);                   % augmented matrix for receding horizon control

%% Constrains values
umax = 5;                    % maximum value of manipulated input 10(given)
umin = -5;                   % minimum value of manipulated input -10
dumax = 2;                    % u(k+1)-u(k)=delta_u 
dumin = -2;                   % u(k+1)-u(k)=delta_u 
%% Intialisation of Input
u_init= 0;                     % u(k-1) =0

%% Weighting matrix
%weighing matrix for Control variable
weight_u = 3;   
Wu = weight_u*eye(Nc,Nc);                    

%weighing matrix for outputs
weight_y = zeros(size(Am,1));
weight_y(1,1) = 10;
weight_y(2,2) = 5;
weight_y(3,3) = 15;

%% For changing between sol to get constrained and unconstrained values
sol = 1;                       % sol = 1 to get unconstrained
%sol = 2;                      % sol = 2 or 0 to get constrained 
%}



