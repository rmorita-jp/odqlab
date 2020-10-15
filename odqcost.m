function Efinal = odqcost(G,Q,d,steptime,plotflag)
%ODQCOST Computing the cost of Optimal Dynamic Quantizer
%
%E = odqcost(G,Q,d,T) computes the cost of Q which quantize interval is d
%aginst G in steptime T. If you do not set T, T is set Inf.
%E = odqcost(G,Q,d,T,plotflag) can determine whether plot transition or
%not. plotflag = 't' is plotting, 'f' is not plotting. Default is 'f'.
%
%See also compg, odq, odqgain, odqreal, odqstb.

%%%%%set default steptime%%%%%
if (nargin==5)
    if isempty(steptime)==1
        steptime=inf;
    end
elseif (nargin==4)
    plotflag='f';
elseif (nargin==3)
    steptime=inf;
    plotflag='f';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isinf(steptime)
    strarch=computer('arch');
    switch strarch
        case {'win64' , 'glnxa64' , 'maci64'}
            steptime=double(intmax('int64'));
        otherwise
            steptime=double(intmax('int32'));
    end
end
finaltime=steptime;      %initialize

G.aa = G.a+G.b2*G.c2;    %convert to closed loop (only G)

%%%%%convert to closed loop (include Q)%%%%%
Abar = [  G.aa                             G.b2*Q.c     ;
        zeros( size(Q.a,1) , size(G.aa,1) ) Q.a+Q.b2*Q.c];
Bbar = [ G.b2  ;
         Q.b2 ];
Cbar = [ G.c1 zeros( size(G.c1,1) , size(Q.a,1) )];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%unstable case%%%%%
%if max(abs(eig(Abar)))>1
%Qcl=ss(Abar,Bbar,Cbar,0)
Qcl=ss(Abar,Bbar,Cbar,0,-1);
Qclmin=minreal(Qcl);
if max(abs(eig(Qclmin.a)))>1
    Efinal=inf;
    return
end
%%%%%%%%%%%%%%%%%%%%%%%

sum_CAB = zeros( size( G.c1 , 1 ) , size( G.b2 , 2 ) );     %initialize

%T = zeros(steptime,1); %initialize
%E = zeros(steptime,1); %initialize

%%%%%%%%%%computing gain%%%%%%%%%%
disp('Computing cost...')
fprintf('%s','0%...')
for i=1:steptime
    sum_CAB = sum_CAB + abs( Cbar * Abar^(i-1) * Bbar );
    E(i) = norm(sum_CAB,inf)*d/2;
    T(i) = i;
    if (i>1)
        if (abs(E(i)-E(i-1))<1e-8)
            finaltime=i;
%            T=eye(finaltime,steptime)*T;
%            E=eye(finaltime,steptime)*E;
            break
        end
    end
    %%%%%%%%%%display progress%%%%%%%%%%
    if i==floor(steptime/10)
        fprintf('%s','10%...')
    elseif i==floor(steptime/10)*2
        fprintf('%s','20%...')
    elseif i==floor(steptime/10)*3
        fprintf('%s','30%...')
    elseif i==floor(steptime/10)*4
        fprintf('%s','40%...')
    elseif i==floor(steptime/10)*5
        fprintf('%s','50%...')
    elseif i==floor(steptime/10)*6
        fprintf('%s','60%...')
    elseif i==floor(steptime/10)*7
        fprintf('%s','70%...')
    elseif i==floor(steptime/10)*8
        fprintf('%s','80%...')
    elseif i==floor(steptime/10)*9
        fprintf('%s','90%...')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
pause(0.001)
end
fprintf('%s\n','Finish!')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Efinal = E(finaltime);      %RESULT

%%%%%%%%%%ploting%%%%%%%%%%
if (plotflag=='t')
    figure(1)
    plot(T,E);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%