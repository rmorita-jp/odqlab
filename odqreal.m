function [Q, Hk_new] = odqreal(G,Hk,dim)
%ODQREAL Compose Optimal Dynamic Quantizer from brock hankel matrix
%
%Q = odqreal(G,Hk,dim) composes Q from brock hankel matrix, Hk.H is structure
%which contains its singular-value-decompositioned matrix.
%(Hk.H = Hk.Wo * Hk.S * Hk.Wc)
%
%See also compg, odq, odqgain, odqcost, odqstb.

%%%%%set parameters%%%%%           
%Tdash=floor(T/2)+1;
%m=size(Hk.H,1)/Tdash;
m = size(G.c1*G.b2,2);
Tdash=size(Hk.H,1)/m;
T=(Tdash-1)*2+1;
%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%set dimention%%%%%
rdctn=0;
if (nargin==3)
%     if (strcmp(dim,'auto')==1)
%         dim = 0.01;
%     end
%     if (mod(dim,1)==0)
%         nQ = dim;
%         rdctn = 1;
%     elseif (dim<1)
%         for i=1:Tdash*m-1
%             if rdctn==0
%                 if Hk.S(i+1,i+1)/Hk.S(i,i)<dim
%                     nQ=i;
%                     rdctn=1;
%                 end
%             end
%         end
%     else
%         error('wromng dimention')
%     end
%
%
% if length(Hk.S)==1
%     nQ=1;
%     rdctn=1;
% else
%     for i=1:Tdash*m-1
%         if rdctn==0
%             if Hk.S(i+1,i+1)<dim
%                 nQ=i;
%                 rdctn=1;
%             end
%         end
%     end
% end
%
nQ = dim;
rdctn = 1;
end
if (nargin==2 || rdctn==0)
    nQ = m*Tdash;
end
%%%%%%%%%%%%%%%%%%%%%%

%%%%%reduce dimention%%%%%
Wor = Hk.Wo( :  ,1:nQ);
Sr  = Hk.S(1:nQ,1:nQ);
Wcr = Hk.Wc(1:nQ, :  );
%%%%%%%%%%%%%%%%%%%%%%%%%%

Hk_new.Wo=Wor;
Hk_new.S=Sr;
Hk_new.Wc=Wcr;
Hk_new.H=Wor*Sr*Wcr;

%%%%%%%%%%compose quantizer%%%%%%%%%%
Q.b2 = Sr^(1/2)*Wcr*[eye(m);zeros(m*(Tdash-1),m)];
Q.c  = [eye(m) zeros(m,m*(Tdash-1))]*Wor*Sr^(1/2);
Q.a  = pinv([eye(m*(Tdash-1)) zeros(m*(Tdash-1),m)]*Wor*Sr^(1/2))*[zeros(m*(Tdash-1),m) eye(m*(Tdash-1))]*Wor*Sr^(1/2)-Q.b2*Q.c;
Q.b1 = -Q.b2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Q = orderfields(Q);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if max(abs(eig(Q.a+Q.b2*Q.c)))>1
    disp('Stabilizing...')
    pause(0.1)
    
    nQbar=nQ*T;
    
    AQbar  = [zeros( nQbar-nQ,nQ ) kron( eye(T-1),(Q.a+Q.b2*Q.c) );
               kron( ones(1,T),(-Q.b2*Q.c) )                     ];
    B2Qbar = [zeros( nQbar-nQ,m );Q.b2];
    CQbar  = kron( ones(1,T),Q.c );

    Q.a  = AQbar;
    Q.b1 = -B2Qbar;
    Q.b2 = B2Qbar;
    Q.c  = CQbar;
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
