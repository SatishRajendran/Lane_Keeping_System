function [Del_u] = del_u_calc(Phi_Phi,Phi_R,r,Phi_F,BarRs,Fx,Xf,u,Nc,nu,Phit,Wu,Wy,umax,umin,dumax,dumin,sol)            

%% Unconstrained delta_u value
if sol == 1
    [Del_u] = (Phit'*Wy*Phit+Wu)\(Phit'*Wy*(r*BarRs - Fx*Xf));     %del u value without constrains
    Del_u = Del_u(1,1);
    
%% constrained delta_u value
else
    e_free = r*BarRs - Fx*Xf;

        b1 = u - umin;      % for manipulated input constraints // MPC Book Page:52
        b2 = umax - u;      % for manipulated input constraints
        b1_vec = b1;
        b2_vec = b2;
        vl_vec = dumin;      % for constraints on delta_u
        vu_vec = dumax;      % for constraints on delta_u
    
        for i = 2:Nc
            b1_vec = [b1_vec;b1];
            b2_vec = [b2_vec;b2];
            vl_vec = [vl_vec;dumin];
            vu_vec = [vu_vec;dumax];
        end
    
        for i = 1:Nc % control horizon
            for j = 1:Nc
                n_row_beg = (i-1)*nu+1;
                n_row_end = i*nu;
                n_col_beg = (j-1)*nu+1;
                n_col_end = j*nu;
                if i >= j
                    A2(n_row_beg:n_row_end,n_col_beg:n_col_end) = eye(nu,nu);
                else
                    A2(n_row_beg:n_row_end,n_col_beg:n_col_end) = zeros(nu,nu);
                end
            end
        end
   
        A1 = -A2;
        A_cons = [A1; A2];
        b = [b1_vec; b2_vec];
       
        H = Phit'*Wy*Phit + Wu; 
        f = -1*Phit'*Wy*e_free;
        
        duvec = quadprog(H,f,A_cons,b,[],[],vl_vec,vu_vec);
        Del_u = duvec(1:length(u));
        
end