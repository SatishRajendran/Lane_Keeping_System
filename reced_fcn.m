function [control_value] = reced_fcn(ymeas_out)
%%
global Am;
global Bmm;
global Cm;
global Ap;
global Bp;
global Cp;
global u_init;
global xm;
global Np;
global Nc;
global r;
global sol;
global nu;
global ny;
global umax;
global umin;
global dumax; 
global dumin;
global k;
global Xf;
global Wu;
global weight_y;
global u;
global kfinal;
global Wy;
global n;
%% mpc gain values are being calculated
[Phi_Phi,Phi_F,Phi_R,A_e,B_e,C_e,Phit,Fx,BarRs,Wy] = mpcgain(Ap,Bp,Cp,Nc,Np,ny,n,weight_y);  % mpc gain values are being calculated
%[Phi_Phi,Phi_F,Phi_R,A_e,B_e,C_e,Phit,Fx,BarRs,Wy] = mpcgain(Am,Bmm,Cm,Nc,Np,ny,n,weight_y); 
%%  Simulation starts here
%%  Used built in matlab function - Quadprog - Constrained value
    if (k > 1) && (k < kfinal+1)
    [del_u] = del_u_calc(Phi_Phi,Phi_R,r(k),Phi_F,BarRs,Fx,Xf(:,k),u(:,k-1),Nc,nu,Phit,Wu,Wy,umax,umin,dumax,dumin,sol);
    else
    [del_u]= del_u_calc(Phi_Phi,Phi_R,r(k),Phi_F,BarRs,Fx,Xf(:,k),u_init,Nc,nu,Phit,Wu,Wy,umax,umin,dumax,dumin,sol);                                                         
    end
    delta_u = del_u(1,1);

%% convert to actual applied control action, u
    if k > 1
        u(:,k) = u(:,k-1) + delta_u;      % control input | u = u_old + del_u 
    else
        u(:,k) = u_init+ delta_u;
    end
        control_value = u(:,k);
%% Mpc calulation for state space equation

xm_old=xm(:,k);                           %old value is replaced
xm(:,k+1)=Ap*xm(:,k)+Bp*u(:,k);           %x(k+1) = Ax(k)+Bu(k)  
y(:,k+1)=Cp*xm(:,k+1);                    %y = Cx(k)
y(:,k)= ymeas_out;                        %measured output of y is copied to previous part
Xf(:,k+1)=[xm(:,k+1)-xm_old;y(:,k)];      %state variable used in feedback mechanism.
k = k+1;
end




