function [sys,x0,str,ts] = seitlichen_abstand_berechnen(t,x,u,flag)
%SFUNTMPL General M-file S-function template
%   With M-file S-functions, you can define you own ordinary differential
%   equations (ODEs), discrete system equations, and/or just about
%   any type of algorithm to be used within a Simulink block diagram.
%
%   The general form of an M-File S-function syntax is:
%       [SYS,X0,STR,TS] = SFUNC(T,X,U,FLAG,P1,...,Pn)
%
%   What is returned by SFUNC at a given point in time, T, depends on the
%   value of the FLAG, the current state vector, X, and the current
%   input vector, U.
%
%   FLAG   RESULT             DESCRIPTION
%   -----  ------             --------------------------------------------
%   0      [SIZES,X0,STR,TS]  Initialization, return system sizes in SYS,
%                             initial state in X0, state ordering strings
%                             in STR, and sample times in TS.
%   1      DX                 Return continuous state derivatives in SYS.
%   2      DS                 Update discrete states SYS = X(n+1)
%   3      Y                  Return outputs in SYS.
%   4      TNEXT              Return next time hit for variable step sample
%                             time in SYS.
%   5                         Reserved for future (root finding).
%   9      []                 Termination, perform any cleanup SYS=[].
%
%
%   The state vectors, X and X0 consists of continuous states followed
%   by discrete states.
%
%   Optional parameters, P1,...,Pn can be provided to the S-function and
%   used during any FLAG operation.
%
%   When SFUNC is called with FLAG = 0, the following information
%   should be returned:
%
%      SYS(1) = Number of continuous states.
%      SYS(2) = Number of discrete states.
%      SYS(3) = Number of outputs.
%      SYS(4) = Number of inputs.
%               Any of the first four elements in SYS can be specified
%               as -1 indicating that they are dynamically sized. The
%               actual length for all other flags will be equal to the
%               length of the input, U.
%      SYS(5) = Reserved for root finding. Must be zero.
%      SYS(6) = Direct feedthrough flag (1=yes, 0=no). The s-function
%               has direct feedthrough if U is used during the FLAG=3
%               call. Setting this to 0 is akin to making a promise that
%               U will not be used during FLAG=3. If you break the promise
%               then unpredictable results will occur.
%      SYS(7) = Number of sample times. This is the number of rows in TS.
%
%
%      X0     = Initial state conditions or [] if no states.
%
%      STR    = State ordering strings which is generally specified as [].
%
%      TS     = An m-by-2 matrix containing the sample time
%               (period, offset) information. Where m = number of sample
%               times. The ordering of the sample times must be:
%
%               TS = [0      0,      : Continuous sample time.
%                     0      1,      : Continuous, but fixed in minor step
%                                      sample time.
%                     PERIOD OFFSET, : Discrete sample time where
%                                      PERIOD > 0 & OFFSET < PERIOD.
%                     -2     0];     : Variable step discrete sample time
%                                      where FLAG=4 is used to get time of
%                                      next hit.
%
%               There can be more than one sample time providing
%               they are ordered such that they are monotonically
%               increasing. Only the needed sample times should be
%               specified in TS. When specifying than one
%               sample time, you must check for sample hits explicitly by
%               seeing if
%                  abs(round((T-OFFSET)/PERIOD) - (T-OFFSET)/PERIOD)
%               is within a specified tolerance, generally 1e-8. This
%               tolerance is dependent upon your model's sampling times
%               and simulation time.
%
%               You can also specify that the sample time of the S-function
%               is inherited from the driving block. For functions which
%               change during minor steps, this is done by
%               specifying SYS(7) = 1 and TS = [-1 0]. For functions which
%               are held during minor steps, this is done by specifying
%               SYS(7) = 1 and TS = [-1 1].

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.18 $

%
% The following outlines the general structure of an S-function.
%
switch flag,
    
    %%%%%%%%%%%%%%%%%%
    % Initialization %
    %%%%%%%%%%%%%%%%%%
    case 0,
        [sys,x0,str,ts]=mdlInitializeSizes;
    
    %%%%%%%%%%%%%%%
    % Derivatives %
    %%%%%%%%%%%%%%%
    case 1,
        sys=mdlDerivatives(t,x,u);
    
    %%%%%%%%%%
    % Update %
    %%%%%%%%%%
    case 2,
        sys=mdlUpdate(t,x,u);

    %%%%%%%%%%%
    % Outputs %
    %%%%%%%%%%%
    case 3,
        sys=mdlOutputs(t,x,u);

    %%%%%%%%%%%%%%%%%%%%%%%
    % GetTimeOfNextVarHit %
    %%%%%%%%%%%%%%%%%%%%%%%
    case 4,
        sys=mdlGetTimeOfNextVarHit(t,x,u);
    
    %%%%%%%%%%%%%
    % Terminate %
    %%%%%%%%%%%%%
    case 9,
        sys=mdlTerminate(t,x,u);
    
    %%%%%%%%%%%%%%%%%%%%
    % Unexpected flags %
    %%%%%%%%%%%%%%%%%%%%
    otherwise
        error(['Unhandled flag = ',num2str(flag)]);

end

% end punkt_e_berechnen

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes
    
    %
    % call simsizes for a sizes structure, fill it in and convert it to a
    % sizes array.
    %
    % Note that in this example, the values are hard coded.  This is not a
    % recommended practice as the characteristics of the block are typically
    % defined by the S-function parameters.
    %
    sizes = simsizes;
    
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 7;
    sizes.NumInputs      = 3;
    sizes.DirFeedthrough = 1;
    sizes.NumSampleTimes = 1;   % at least one sample time is needed
    
    sys = simsizes(sizes);
    global delta_t;
    %
    % initialize the initial conditions
    %
    x0  = [];
    
    %
    % str is always an empty matrix
    %
    str = [];
    
    %
    % initialize the array of sample times
    %
    ts  = [delta_t 0];
    
% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)

    sys = [];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)
    
    sys = [];
    
% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

    global X;
    global Y;
    global l_l0;
    global old_index_i;
    global iii;
    global r
    global iiii;
    global l_ltr;
    
    pos_x = u(1);
    pos_y = u(2);
    psi   = u(3);
    %% vehicle with a point 'P' at a distance front
   %
   %
    % Punikt P berechnen   
    % Point P calculated
   p_x = pos_x+ l_l0 * cos(psi);
   p_y = pos_y+ l_l0 * sin(psi);
    
    %p_x = pos_x;
    %p_y = pos_y;
   
    % Punkt Q (frueher P')
    % Point Q calculated
    p_strich_x = p_x + 60 * cos(psi-pi/2);
    p_strich_y = p_y + 60 * sin(psi-pi/2);
    
    % Index i laden von vorherigem durchlauf
    i_kleiner = old_index_i;
    i = old_index_i;
    tmp_stop_loop = 0;
    
    % Pruefen, od der Index i erhoehrt werden musss
    % angle condition are found to find the path
    while ((tmp_stop_loop == 0) && (i <= length(X)-1))
        
        i = i + 1;
        winkelbedingung = (p_strich_x - p_x)*(Y(i) - p_y)-(X(i) - p_x)*(p_strich_y - p_y);
        
        if (winkelbedingung <= 0)
            i_kleiner = i_kleiner + 1;
        else  % if (winkelbedingung <= 0)
            tmp_stop_loop = 1;
        end   % if (winkelbedingung <= 0)
        
    end  % while (tmp_stop_loop == 0 && i <= length(X))
    
    % Bereichspruefung
    % Die letzen Punkte werden verwendet, wenn keine weiteren Daten folgen.
    if (i_kleiner >= length(X))
        
        i_kleiner = length(X) - 1;
        
    end  % if (i_kleiner >= length(X))
    
    % i fuer naechsten Durchlauf speichern
    old_index_i = i_kleiner;
    
    % Verbindungsvektor zwischen zwei Punkten der "Randlinie"
    % connection between Ri and Ri+1
    dx1 = X(i_kleiner+1) - X(i_kleiner);
    dy1 = Y(i_kleiner+1) - Y(i_kleiner);
    
    % Verbindungsvektor zwischen p_xy und p_strich_xy
    % connection between P and Q
    dx2 = p_strich_x - p_x;
    dy2 = p_strich_y - p_y;
    
    % Length of the lines are found
    l1 = sqrt(dx1*dx1+dy1*dy1);
    l2 = sqrt(dx2*dx2+dy2*dy2);
  
    % Normalenvektor der Randlinie berechnen
    % normal vector for 'R' line calculated
    nx1 = dy1/l1;
    ny1 = -1.0 * dx1/l1;

    % Normalenvektor der Verbindung zwischen p_xy und p_strich_xy
    % normal vector for 'P' and 'Q' line calculated
    nx2 = dy2/l2;
    ny2 = -1 * dx2/l2;
    
    %disp ('--');
    %disp (nx1);
    %disp (ny1);
    %disp (nx2);
    %disp (ny2);
    
%    if( rank([nx1, nx2; ny2, ny1;], 1e-10) > 1)
        % Vektoren linear unabhaengig
        
        % Abstandsparameter Rho fuer die Hessesche
        % Normalform der beiden Geraden berechnen
        rho1 = nx1 * X(i_kleiner) + ny1 * Y(i_kleiner);
        rho2 = nx2 * p_x + ny2 * p_y;
        
        % Schnittpunkt der Geraden mit Hilfe
        % der Cramerschen Regel berechnen.
        % Cramersche Regel und lineare
        % Gleichnungssysteme siehe:
        % Hoehere Mathematik fuer Ingenieure
        % Burg / Haf / Wille; Band II; Seite 42
        % using Cramers rule point 'E' value  are calculated
        e_x = det([rho1, ny1; rho2, ny2;]) / det([nx1, ny1; nx2 ny2;]);
        e_y = det([nx1, rho1; nx2, rho2;]) / det([nx1, ny1; nx2 ny2;]);
         
        seitlicher_abstand = sqrt((e_x-p_x)^2+(e_y-p_y)^2); 
        
        winkelbedingung = (e_x - pos_x)*(p_y - pos_y)-(p_x - pos_x)*(e_y - pos_y);
        
        if (winkelbedingung <0)
            
            seitlicher_abstand = seitlicher_abstand * (-1);    
        end % if (winkelbedingung <0)
        
        l_ltr(iii,1) = seitlicher_abstand;
        iii = iii+1;
        %% To find the reference angle for MPC reference (set point)
        %% vector are set for find the reference angle
        op = zeros(2,1);                   
        ox = zeros(2,1);     
        %% Vector assigned with values for x-axis and y-axis
        op(1,1) = e_x-pos_x;             
        op(2,1) = e_y-pos_y;    
        %% vector assigned with vales for inertial x-axis and inertial y-axis
        % Here only x axis is considered
        ox(1,1) = 10;
        ox(2,1) = 0;
        %% for finding an angle with vectors the corresponding formula is applied
        const = ((dot(op,ox))/(norm(op)*norm(ox)));
        %% Angle for reference
        psi_calc = acos(const);% - atan(seitlicher_abstand/l_l0);
        %% values fed into the MPC controller as reference
        r(iiii,:) = psi_calc*[1 0 0];
        iiii = iiii+1;

        %% Error
        fehler = 0;
    %}
    
    %% Vehicle at centre of gravity
   %{
    % Punikt P berechnen   
    % Point P calculated
    p_x = pos_x+ 10 * cos(psi+pi/2);
    p_y = pos_y+ 10 * sin(psi+pi/2);
    
   
    % Punkt Q (frueher P')
    % Point Q calculated
    p_strich_x = pos_x + 10 * cos(psi-pi/2);
    p_strich_y = pos_y + 10 * sin(psi-pi/2);
    
    % Index i laden von vorherigem durchlauf
    i_kleiner = old_index_i;
    i = old_index_i;
    tmp_stop_loop = 0;
    
    % Pruefen, od der Index i erhoehrt werden musss
    % angle condition are found to find the path
    while ((tmp_stop_loop == 0) && (i <= length(X)-1))
        
        i = i + 1;
        winkelbedingung = (p_strich_x - p_x)*(Y(i) - p_y)-(X(i) - p_x)*(p_strich_y - p_y);
        
        if (winkelbedingung <= 0)
            i_kleiner = i_kleiner + 1;
        else  % if (winkelbedingung <= 0)
            tmp_stop_loop = 1;
        end   % if (winkelbedingung <= 0)
        
    end  % while (tmp_stop_loop == 0 && i <= length(X))
    
    % Bereichspruefung
    % Die letzen Punkte werden verwendet, wenn keine weiteren Daten folgen.
    if (i_kleiner >= length(X))
        
        i_kleiner = length(X) - 1;
        
    end  % if (i_kleiner >= length(X))
    
    % i fuer naechsten Durchlauf speichern
    old_index_i = i_kleiner;
    
    % Verbindungsvektor zwischen zwei Punkten der "Randlinie"
    % connection between Ri and Ri+1
    dx1 = X(i_kleiner+1) - X(i_kleiner);
    dy1 = Y(i_kleiner+1) - Y(i_kleiner);
    
    % Verbindungsvektor zwischen p_xy und p_strich_xy
    % connection between P and Q
    dx2 = p_strich_x - p_x;
    dy2 = p_strich_y - p_y;
    
    % Length of the lines are found
    l1 = sqrt(dx1*dx1+dy1*dy1);
    l2 = sqrt(dx2*dx2+dy2*dy2);
  
    % Normalenvektor der Randlinie berechnen
    % normal vector for 'R' line calculated
    nx1 = dy1/l1;
    ny1 = -1.0 * dx1/l1;

    % Normalenvektor der Verbindung zwischen p_xy und p_strich_xy
    % normal vector for 'P' and 'Q' line calculated
    nx2 = dy2/l2;
    ny2 = -1 * dx2/l2;
    
    %disp ('--');
    %disp (nx1);
    %disp (ny1);
    %disp (nx2);
    %disp (ny2);
    
%    if( rank([nx1, nx2; ny2, ny1;], 1e-10) > 1)
        % Vektoren linear unabhaengig
        
        % Abstandsparameter Rho fuer die Hessesche
        % Normalform der beiden Geraden berechnen
        rho1 = nx1 * X(i_kleiner) + ny1 * Y(i_kleiner);
        rho2 = nx2 * p_x + ny2 * p_y;
        
        % Schnittpunkt der Geraden mit Hilfe
        % der Cramerschen Regel berechnen.
        % Cramersche Regel und lineare
        % Gleichnungssysteme siehe:
        % Hoehere Mathematik fuer Ingenieure
        % Burg / Haf / Wille; Band II; Seite 42
        % using Cramers rule point 'E' value  are calculated
        e_x = det([rho1, ny1; rho2, ny2;]) / det([nx1, ny1; nx2 ny2;]);
        e_y = det([nx1, rho1; nx2, rho2;]) / det([nx1, ny1; nx2 ny2;]);
        
        %% Chnages made here for finding the Lateral gap
        seitlicher_abstand = (sqrt((e_x-pos_x)^2+(e_y-pos_y)^2)); 
        
        winkelbedingung = (e_y - Y(i))*(X(i+1) - X(i)) - (e_x - X(i)) * (Y(i) - Y(i+1));
        
        if (winkelbedingung <0)
            
            seitlicher_abstand = seitlicher_abstand * (-1);
        
       end % if (winkelbedingung <0)
        l_ltr(iii,1) = seitlicher_abstand;
        iii = iii+1; 
        %% To find the reference angle for MPC reference (set point)
        %% vector are set for find the reference angle
        op = zeros(2,1);                   
        ox = zeros(2,1);     
        %% Vector assigned with values for x-axis and y-axis
        op(1,1) = X(i+1)-pos_x;             
        op(2,1) = Y(i+1)-pos_y;    
        %% vector assigned with vales for inertial x-axis and inertial y-axis
        % Here only x axis is considered
        ox(1,1) = 50;
        ox(2,1) = 0;
        %% for finding an angle with vectors the corresponding formula is applied
        const = ((dot(op,ox))/(norm(op)*norm(ox)));
        %% Angle for reference
        psi_calc = acos(const);
        %% values fed into the MPC controller as reference
        r(iiii,:) = psi_calc*[1 1 1];
        iiii = iiii+1;

        %% Error
        fehler = 0;
     %}
    
    %    else % if( rank([nx1, nx2; ny2, ny1;], 1e-6) > 1)
        % Vektoren linear abhaengig 
        % disp ('Fahler: Vektoren linear abhaengig!');
        
%        xs = 0;
%        ys = 0;
        
%        fehler = 1;
        
%    end  % if( rank([nx1, nx2; ny2, ny1;], 1e-6) > 1)

    sys = [e_x, e_y, p_x, p_y, seitlicher_abstand, fehler, psi_calc];
    
% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
