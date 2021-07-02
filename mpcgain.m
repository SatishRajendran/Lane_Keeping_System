function [Phi_Phi,Phi_F,Phi_R,A_e,B_e,C_e,Phit,Fx,BarRs,Wy] = mpcgain(Ap,Bp,Cp,Nc,Np,ny,n,weight_y)
%% Augmented matriced are derived
%
[m1]=size(Cp,1);
[n1,n_in]=size(Bp);
A_e=eye(n1+m1,n1+m1);
A_e(1:n1,1:n1)=Ap;
A_e(n1+1:n1+m1,1:n1)=Cp*Ap;
B_e=zeros(n1+m1,n_in);
B_e(1:n1,:)=Bp;
B_e(n1+1:n1+m1,:)=Cp*Bp;
C_e=zeros(m1,n1+m1);
C_e(:,n1+1:n1+m1)=eye(m1,m1);

%% Phi matrix calculation
Phi = zeros(ny*Np,Nc);
for i=1:ny*Np
    if i <= Nc
    for j=1:i 
        if i == j
        Phi(((i-1)*ny)+1:i*ny,j)=C_e*B_e;
        else
        Phi((i-1)*ny+1:i*ny,j)=C_e*(A_e)^(i-j)*B_e;
        end
    end 
    else
        for j=1:Nc
          Phi((i-1)*ny+1:i*ny,j)=C_e*(A_e)^(i-j)*B_e;
        end
    end
end

for i=1:ny*Np
    F(((i-1)*ny)+1:i*ny,1:ny+n)=C_e*A_e^i;
end
%% coreesponding weight matrix for outputs
dum4 = zeros(ny,ny);
    
    for i = 1:(ny*Np)
        for j = 1:(ny*Np)
            n_row_beg = (i-1)*ny+1;
            n_row_end = i*ny;
            n_col_beg = (j-1)*ny+1;
            n_col_end = j*ny;
            if i == j
                Wy(n_row_beg:n_row_end,n_col_beg:n_col_end) = weight_y;
            else
                Wy(n_row_beg:n_row_end,n_col_beg:n_col_end) = dum4;
            end
        end
    end
%% Corresponding variable for Delta_u calculation
BarRs=ones(((ny^2)*Np),1);
Phi_Phi= Phi'*Phi;
Phi_F= Phi'*F;
Phi_R=Phi'*BarRs;
Phit = Phi;
Fx = F;

end
