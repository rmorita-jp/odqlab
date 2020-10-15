function [varargout] = odqsim(varargin)
%ODQSIM  Simulate time response of quantized systems.
%
%Help Messege is not available yet
%
%See also odq, compg, odqreal, odqgain, odqcost, odqstb.

G=varargin{1};
Q=varargin{2};
r=varargin{3};
x0=varargin{4};

TL=length(r);

xQ = zeros(size(G.a ,1),TL+1);
xI = zeros(size(G.a ,1),TL+1);
xi = zeros(size(Q.a ,1),TL+1);
zQ = zeros(size(G.c1,1),TL);
zI = zeros(size(G.c1,1),TL);
uQ  = zeros(size(G.c2,1),TL);
uI  = zeros(size(G.c2,1),TL);
vQ  = zeros(size(G.c2,1),TL);
xQ(:,1)=x0;


for k=1:TL
    zQ(:,k)   = G.c1*xQ(:,k)  + G.d1*r(:,k);
    zI(:,k)   = G.c1*xI(:,k)  + G.d1*r(:,k);
    uQ(:,k)   = G.c2*xQ(:,k)  + G.d2*r(:,k);
    uI(:,k)   = G.c2*xI(:,k)  + G.d2*r(:,k);
    vQ(:,k)   = d*round( ( Q.c*xi(:,k) + uQ(:,k) )/d );
    xi(:,k+1) = Q.a*xi(:,k) + Q.b1*uQ(:,k) + Q.b2*vQ(:,k);
    xQ(:,k+1) = G.a*xQ(:,k) + G.b1*r(:,k) + G.b2*vQ(:,k) ;
    xI(:,k+1) = G.a*xI(:,k) + G.b1*r(:,k) + G.b2*uI(:,k) ;
end

varargout{1}=zQ;
varargout{2}=vQ;
varargout{3}=uQ;
varargout{4}=xQ(:,1:TL);
varargout{5}=xi(:,1:TL);

varargout{6}=zI;
varargout{7}=uI;
varargout{8}=xI(:,1:TL);
varargout{9}=norm(zQ-zI,inf);
varargout{10}=zQ-zI;

