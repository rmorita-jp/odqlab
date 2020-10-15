function gainfinal = odqgain(Q,steptime,plotflag)
%ODQGAIN Compute upper bound of gain u->v and w->v
%
%gamma = odqgain(Q,T) computes the gain u->v and w->v of Q in steptime T.
%If you do not set T, T is set Inf.
%gamma = odqgain(Q,T,plotflag) can determine whether plot transition or
%not. plotflag = 't' is plotting, 'f' is not plotting. Default is 'f'.
%
%See also compg, odq, odqreal, odqcost, odqstb.

%%%%%set default steptime%%%%%
if (nargin==2)
    plotflag='f';
    if isempty(steptime)==1
        steptime=inf;
    end
end
if (nargin==1)
    steptime=inf;
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

finaltime=steptime;     %initilize

%%%%%unstable case%%%%%
if max(abs(eig(Q.a+Q.b2*Q.c)))>=1-1e-8
    gainfinal.wv=inf;
    if Q.b1==-Q.b2
        gainfinal.uv=1;
    else
        gainfinal.uv=inf;
    end
    return
end
%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%computing gain%%%%%%%%%%
sum_Quv=eye(size(Q.c*Q.b2));
sum_Qwv=eye(size(Q.c*Q.b2));

%T=zeros(steptime,1);    %initialize

disp('Computing gain...')
fprintf('%s','0%...')
for i=1:steptime
    sum_Quv=sum_Quv+abs(Q.c * (Q.a+Q.b2*Q.c)^(i-1) * (Q.b1+Q.b2));
    sum_Qwv=sum_Qwv+abs(Q.c * (Q.a+Q.b2*Q.c)^(i-1) * Q.b2);
    gain.uv(i) = norm(sum_Quv,inf);
    gain.wv(i) = norm(sum_Qwv,inf);
    T(i) = i;
    if (i>1)
        if (abs(gain.uv(i)-gain.uv(i-1))<1e-8 && abs(gain.wv(i)-gain.wv(i-1))<1e-8)
            finaltime=i;
            break
        end
    end
    %%%%%%%%%%display progress%%%%%%%%%%
    if i==floor(steptime/10)
        fprintf('%s','10%...');
    elseif i==floor(steptime/10)*2
        fprintf('%s','20%...');
    elseif i==floor(steptime/10)*3
        fprintf('%s','30%...');
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
%pause(0.01)
end
fprintf('%s\n','Finish!')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%RESULT%%%%%%%%%%
gainfinal.uv = gain.uv(finaltime);
gainfinal.wv = gain.wv(finaltime);
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%ploting%%%%%%%%%%
if (plotflag=='t')
    figure(2)
    plot(T,gain.uv);
    figure(3)
    plot(T,gain.wv);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%