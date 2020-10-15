function [Q, E, Hk, gain] = odq(G,T,d,gamma,dim,solver)
%ODQ Optimal Dynamic Quantizer
%
%Q = odq(G,T,d) is ODQ for G with evaluation interval 'T'.
%Q = odq(G,T,d,gamma) is ODQ for G whose upper bound of gain is gamma, and
%quantizing interval is d.
%(gamma is structure which contains uv and wv.)
%Q = odq(G,T,d,gamma,dim) can specify the dimension of Q. dim is the
%dimension.
%[Q E] = odq(G,T,d,gamma,dim) shows Q's cost.
%[Q E Hk] = odq(G,T,d,gamma,dim) keeps Hankel matrix to workspace.
%
%Q = odq(G,T,d,gamma,dim,solver) specifies optimization solver.
%'linprog' uses linprog. (Optimization Toolbox by Mathworks)
%'cplex' uses CPLEX. (by ILOG http://www.ilog.com/)
%CPLEX needs CPLEX MEX INTERFACE (contains some bugs)
%
%See also compg, odqreal, odqgain, odqcost, odqstb.

if nargin==5
    if ischar(dim)
        solver = dim;
        dim=0;
    else
        solver='linprog';
    end
elseif nargin==4
    if ischar(gamma)
        solver   = gamma;
        clear gamma
        gamma.wv = inf;
    else
        solver='linprog';
    end
    dim=0;
elseif nargin==3
    gamma.wv = inf;
    dim=0;
    solver='linprog';
elseif nargin<3
    error('there are not enough input argument')
end

%%%%%set dimension%%%%%
m = size(G.c1*G.b2,2);
p = size(G.c1*G.b2,1);
%%%%%%%%%%%%%%%%%%%%%%%

G.aa = G.a+G.b2*G.c2;    %convert to closed loop

%%%%%%%%%%Compose Quantizer%%%%%%%%%%
endflag=0;
if T~=inf
    mstkn=1;
else
    mstkn=0;
end
while (endflag == 0)
    if (m >= p && mstkn == 0)
        Q = odqanly(G);
        %Hk = 'null';
        Hk=odqhnkl_anly(Q);
        if max(abs(eig(Q.a+Q.b2*Q.c)))<=1
            endflag=1;
        else
            mstkn = 0;
            endflag=1;
            disp('Try optimization...')
        end
    else
        [x, exitflag,Tnew,fval] = odqlp(G,T,gamma,solver);
        if (exitflag==1)
            Hk = odqhnkl(x,Tnew,m,p);
            if dim~=0
                [Q, Hk] = odqreal(G,Hk,dim);
            else
                [Q, Hk] = odqreal(G,Hk);
            end
            endflag=2;
        else
            error('Optimization is failed. Please change T and gamma')
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%Check Quantizer%%%%%
if endflag==1
    E=odqcost(G,Q,d,T);
elseif endflag==2
    E=fval*d/2;
end
if (size(Q.a,1)>1000)
    disp('Q has too big dimension. Skip verifying')
    skipflag=1;
    gain.uv='skipped';
    gain.wv='skipped';
else
    gain=odqgain(Q,T);
    skipflag=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%Display Result%%%%%
fprintf('\n%s\n','RESULT')
disp('Q')
disp(Q)
if (skipflag==1)
    fprintf('%s%d\n%s\n','T = ',T,'Computing gain and cost are skiped')
else
    fprintf('%s%d\n%s%d\n%s%d\n','T = ',T,'gain uv = ',gain.uv,'gain wv = ',gain.wv)
    if E~=0
        fprintf('%s%1.4e%s%d%s\n','E = ',E,' in ',T,' steps.') 
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%

function [x,exitflag,T,fval] = odqlp(G,T,gamma,solver)
%ODQLP Optimal Dynamic Quantizer with LP
%
%This function is not to use alone.
%Please use 'ODQ'.
%
%See also odq.

%%%%%set parameters%%%%%
if (mod(T,1)~=0)
    error('steptime must be a positive integer');
end
if (mod(T,2)==0)
    T=T+1;
end
if (gamma.wv<1)
    error('max gain w->v must be greater than 1');
end

m = size(G.c1*G.b2,2);
p = size(G.c1*G.b2,1);

G.aa = G.a+G.b2*G.c2;    %convert to closed loop
%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%initialize%%%%%
if strcmpi(solver,'linprog') || strcmpi(solver,'cplex')
    if gamma.wv==inf
        vectorf = zeros( 1 + m*m*T + p*m*(T-1) , 1 );
    else
        vectorf = zeros( 1 + m*m*T*2 + p*m*(T-1) , 1 );
    end
elseif strcmpi(solver,'sdpt3') || strcmpi(solver,'sedumi')
    if gamma.wv==inf
        vectorf = zeros( 1 + m*m*T + p*m*(T-1) , 1 );
    else
        vectorf = sparse(zeros( 1 + m*m*T*2 + p*m*(T-1) + p + p*m*(T-1)*2 + m + m*m*T*2 , 1 ));
    end
else
    error('wrong solver')
end
%vectorb = zeros( p + p*m*(T-1)*2 + m + m*m*T*2 , 1 );
%matrixA = zeros( p + p*m*(T-1)*2 + m + m*m*T*2 , 1 + m*m*T + p*m*(T-1) );
%%%%%%%%%%%%%%%%%%%%

vectorf(1)=1;

fprintf('Preprocessing for LP...\n')
pause(0.1)

%%%%%making PHI%%%%%
PHI     = zeros( m*p*(T-1) , m*m*T );   %initialize
%PHIdash = zeros( p , m );               %initialize
for i=1:T-1
    PHIdash = kron( G.c1*G.aa^(i-1)*G.b2 , eye(m) );
    for j=i:T-1
        PHI( (j-1)*m*p+1:j*m*p , (j-i)*m*m+1:(j-i+1)*m*m ) = PHIdash;
    end
end
%%%%%%%%%%%%%%%%%%%%

%%%%%making 'matrix -> vector' transposer%%%%%
eye_sumE = kron( ones(1,m*(T-1)) , eye(p) );
eye_sumH = kron( ones(1,m*T) , eye(m) );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%finalize%%%%%%%%%%
if strcmpi(solver,'linprog') || strcmpi(solver,'cplex')
    if gamma.wv==inf
        matrixA = [
            -ones( p , 1 )         zeros( p , m*m*T )  eye_sumE                 ;
            zeros( p*m*(T-1) , 1 )   PHI              -eye( m*p*(T-1) )         ;
            zeros( p*m*(T-1) , 1 )  -PHI              -eye( m*p*(T-1) )         ;
            ];
    else
        matrixA = [
            -ones( p , 1 )         zeros( p , m*m*T ) zeros( p , m*m*T )           eye_sumE                 ;
            zeros( p*m*(T-1) , 1 )   PHI              zeros( p*m*(T-1) , m*m*T )  -eye( m*p*(T-1) )         ;
            zeros( p*m*(T-1) , 1 )  -PHI              zeros( p*m*(T-1) , m*m*T )  -eye( m*p*(T-1) )         ;
            zeros( m , 1 )         zeros( m , m*m*T )   eye_sumH                 zeros( m , m*p*(T-1) )     ;
            zeros( m*m*T , 1 )       eye( m*m*T )      -eye( m*m*T )             zeros( m*m*T , m*p*(T-1) ) ;
            zeros( m*m*T , 1 )      -eye( m*m*T )      -eye( m*m*T )             zeros( m*m*T , m*p*(T-1) ) ;
            ];
    end
elseif strcmpi(solver,'sdpt3') || strcmpi(solver,'sedumi')
    if gamma.wv==inf
        matrixA = [
            -ones( p , 1 )         zeros( p , m*m*T )  eye_sumE                 ;
            zeros( p*m*(T-1) , 1 )   PHI              -eye( m*p*(T-1) )         ;
            zeros( p*m*(T-1) , 1 )  -PHI              -eye( m*p*(T-1) )         ;
            ];
    else
        matrixA = sparse([
            -ones( p , 1 )         zeros( p , m*m*T ) zeros( p , m*m*T )           eye_sumE                             eye(p) zeros(p        ,p*m*(T-1)) zeros(p        ,p*m*(T-1)) zeros(p        ,m) zeros(p        ,m*m*T) zeros(p        ,m*m*T);  % sum(E)-G <-abs(CB)
            zeros( p*m*(T-1) , 1 )   PHI              zeros( p*m*(T-1) , m*m*T )  -eye( m*p*(T-1) )         zeros(p*m*(T-1),p)             eye(p*m*(T-1)) zeros(p*m*(T-1),p*m*(T-1)) zeros(p*m*(T-1),m) zeros(p*m*(T-1),m*m*T) zeros(p*m*(T-1),m*m*T);  %  PHI*H-E  <-C*A^k*B
            zeros( p*m*(T-1) , 1 )  -PHI              zeros( p*m*(T-1) , m*m*T )  -eye( m*p*(T-1) )         zeros(p*m*(T-1),p) zeros(p*m*(T-1),p*m*(T-1))             eye(p*m*(T-1)) zeros(p*m*(T-1),m) zeros(p*m*(T-1),m*m*T) zeros(p*m*(T-1),m*m*T);  % -PHI*H-E <C*A^k*B
            zeros( m , 1 )         zeros( m , m*m*T )   eye_sumH                 zeros( m , m*p*(T-1) )     zeros(m        ,p) zeros(m        ,p*m*(T-1)) zeros(m        ,p*m*(T-1))             eye(m) zeros(m        ,m*m*T) zeros(m        ,m*m*T);  % sum(Hbar)<gamma-1
            zeros( m*m*T , 1 )       eye( m*m*T )      -eye( m*m*T )             zeros( m*m*T , m*p*(T-1) ) zeros(m*m*T    ,p) zeros(m*m*T    ,p*m*(T-1)) zeros(m*m*T    ,p*m*(T-1)) zeros(m*m*T    ,m)             eye(m*m*T) zeros(m*m*T    ,m*m*T);  % H-Hbar   <0
            zeros( m*m*T , 1 )      -eye( m*m*T )      -eye( m*m*T )             zeros( m*m*T , m*p*(T-1) ) zeros(m*m*T    ,p) zeros(m*m*T    ,p*m*(T-1)) zeros(m*m*T    ,p*m*(T-1)) zeros(m*m*T    ,m) zeros(m*m*T    ,m*m*T)             eye(m*m*T);  % -H-Hbar  <0
            ]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%making C A^k B ,changing matrix to vector%%%%%
CAB = zeros( (T-1)*p , m );             %initialize
el_CAB = zeros( m*p*(T-1) , 1 );        %initialize

for i=1:T-1
    CAkB = G.c1*G.aa^i*G.b2;
    CAB( (i-1)*p+1:i*p , 1:m ) = CAkB;
end

for j=1:p*(T-1)
    for i=1:m
        el_CAB( i+(j-1)*m , 1 ) = CAB( j , i );
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%finalize%%%%%%%%%%
if strcmpi(solver,'linprog') || strcmpi(solver,'cplex')
    if gamma.wv==inf
        vectorb = [ 
            -abs( G.c1*G.b2 )*ones( m , 1 ) ;
            -el_CAB                         ;
            el_CAB                          ;
            ];
    else
        vectorb = [ 
            -abs( G.c1*G.b2 )*ones( m , 1 ) ;
            -el_CAB                         ;
            el_CAB                          ;
            (gamma.wv-1)*ones( m , 1 )      ;
            zeros( m*m*T*2,1 )              ;
            ];
    end
elseif strcmpi(solver,'sdpt3') || strcmpi(solver,'sedumi')
    if gamma.wv==inf
        vectorb = [
            -abs( G.c1*G.b2 )*ones( m , 1 ) ;
            -el_CAB                         ;
            el_CAB                          ;
            ];
    else
        vectorb = sparse([
            -abs( G.c1*G.b2 )*ones( m , 1 ) ;
            -el_CAB                         ;
            el_CAB                          ;
            (gamma.wv-1)*ones( m , 1 )      ;
            zeros( m*m*T*2,1 )              ;
            ]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% liner programing problem%%%%%%%%%%
switch lower(solver)
    case 'linprog'
        fprintf('Solving LP problem (linplog)...\n')
        pause(0.1)
        options=optimset('LargeScale','on','Diagnostics','off','Display','off','MaxIter',10000,'TolFun',[]);
        [x,fval,exitflag,output]=linprog(vectorf,matrixA,vectorb,[],[],[],[],[],options);
        disp(output.message)
    case 'cplex'
        fprintf('Solving LP problem (cplex)...\n')
        pause(0.1)
        if ismac
            pause(0.1)
            [x,fval,STATUS]=lp_cplex(1,vectorf,matrixA,vectorb); %#ok<ASGLU>
        else
            x=cplexlp(vectorf,matrixA,vectorb);
            fval=vectorf'*x;
        end
        exitflag=1;
    case 'sdpt3'
        disp('Solving LP problem (SDPT3)...')
        blk{1,1}='l';
        blk{2,1}='u';
        blk{1,2}=m*m*T + m*p*(T-1) + p + p*m*(T-1)*2 + m + m*m*T*2;
        blk{2,2}=1+m*m*T;
        At{1}=sparse(matrixA(:,1+m*m*T+1:1 + m*m*T*2 + p*m*(T-1) + p + p*m*(T-1)*2 + m + m*m*T*2)');
        At{2}=sparse(matrixA(:,1:1+m*m*T)');
        C{1}=sparse(vectorf(1+m*m*T+1:1 + m*m*T*2 + p*m*(T-1) + p + p*m*(T-1)*2 + m + m*m*T*2));
        C{2}=sparse(vectorf(1:1+m*m*T));
        option_sdpt = sqlparameters;
        [obj,X,y,Z,info,runhist]=sqlp(blk,At,C,vectorb,option_sdpt); %#ok<ASGLU>
        x=[X{2};X{1}];
        fval=vectorf'*x;
        exitflag=1;
    case 'sedumi'
        disp('Solving LP problem (SeDuMi)...')
        K.f=1 + m*m*T;
        K.l= m*m*T + p*m*(T-1) + p + p*m*(T-1)*2 + m + m*m*T*2;
        x=sedumi(matrixA,vectorb,vectorf,K);
        length(vectorf)
        exitflag=1;
        fval=vectorf'*x;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Hk = odqhnkl(x,T,m,p) %#ok<INUSD>
%ODQHNKL Compute block hankel matrix from inpulse response matrix of ODQ
%
%This function is not to use alone.
%Please use 'ODQREAL'.
%
%See also odqreal.

disp('Computing SVD...')
pause(0.1)

Tdash=floor(T/2)+1;

%%%%%making Block Hankel matrix%%%%%
for i=1:m*T
    row_H( i , 1:m ) = x( 2+(i-1)*m : 1+i*m );
end

for i=1:Tdash
    Hk.H( 1:m*Tdash , (i-1)*m+1:i*m ) = row_H( (i-1)*m+1:(i+Tdash-1)*m , : );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%Singular Value Decomposition%%%%%
[Hk.Wo, Hk.S, Hk.Wc] = svd( Hk.H );
Hk.Wc = Hk.Wc';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%verify%%%%%%%%%%
if norm(Hk.H-Hk.Wo*Hk.S*Hk.Wc,inf)/norm(Hk.H)>10^(-2)
    error('Oops! SVD is failed. Abort Program.')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

function H=odqhnkl_anly(Q)

nG = size(Q.a,1);  %Size of Q
m  = size(Q.b1,2); %Size of input

Tdash = floor(nG/2)+1;


H2k = Q.c*Q.b2;
row_H = H2k;
for k=1:nG
    H2k = Q.c*(Q.a+Q.b2*Q.c)^k*Q.b2;
    row_H = [row_H; H2k];
end

for i=1:Tdash
    H.H(1:m*Tdash, (i-1)*m+1:i*m) = row_H((i-1)*m+1:(i+Tdash-1)*m, :);
end

[H.Wo, H.S, H.Wc] = svd( H.H );
H.Wc = H.Wc';

if norm(H.H-H.Wo*H.S*H.Wc,inf)/norm(H.H)>10^(-2)
    error('SVD is failed')
end

%hist(diag(H.S))

function Q = odqanly(G)
%ODQANLY Optimal Dynamic Quantizer with analytic method
%
%This function is not to use alone.
%Please use 'ODQ'.
%
%See also odq.

G.aa = G.a+G.b2*G.c2;    %convert to closed loop

Q.a  = G.aa;
Q.b1 = -G.b2;
Q.b2 = G.b2;
Q.c  = -pinv(G.c1*G.b2)*G.c1*G.aa;
