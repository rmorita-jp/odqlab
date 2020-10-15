function G=compg(P,K,con)
%COMPG Compute system G
%
%G = COMPG(P,K,CON) computes the state space representation of G.
%G is combination form of a plant P and a controller K, and it is given as
%      x(k+1) = G.a  * x(k) + G.b1 * r(k) + G.b2 * v(k) 
%       z(k)  = G.c1 * x(k) + G.d1 * r(k) 
%       u(k)  = G.c2 * x(k) + G.d2 * r(k) 
%
%P is a sturucture object representing the state-space model of the plant
%below,
%     Xp(k+1) = P.a  * Xp(k) + P.b * v(k)
%       z(k)  = P.c1 * Xp(k)
%       y(k)  = P.c2 * Xp(k)
%
%K is a sturucture object representing the state-space model of the
%controller below,
%     Xk(k+1) = K.a * Xk(k) + K.b1 * r(k) + K.b2 * y(k)
%       u(k)  = K.c * Xk(k) + K.d1 * r(k) + K.d2 * y(k)
%
%CON is a string representing connection between P, K, and the quantizer.
%Three types of connection below you can set.
%   'ff'   Feedforward system
%             +-----+  v  +-----+    
%       u --->|  Q  |---->|  P  |---> z 
%             +-----+     +-----+    
%
%   'fbiq'   Feedback system with input quantizer
%             +-------+     +-------+     +-------+     
%       r --->|       |  u  |       |  v  |       |---> z
%             |   K   |---->|   Q   |---->|   P   |     
%          +->|       |     |       |     |       |--+  
%          |  +-------+     +-------+     +-------+  |y 
%          +-----------------------------------------+  
%
%   'fboq'   Feedback system with output quantizer
%             +-------+           +-------+     
%       r --->|       |           |       |---> z 
%             |   K   |---------->|   P   |     
%          +->|       |           |       |--+  
%         v|  +-------+  +-----+  +-------+  |u
%          +-------------|  Q  |<------------+  
%                        +-----+              
%
%See also odq, odqreal, odqcost.

%%%%%%%%% Check Plant %%%%%%%%%%
if ~isfield(P,'b') || isempty(P.b) || isequal(P.b,0)
    error('Plant must have input')
else
    nu = size(P.b,2);
    nP = size(P.b,1);
end

if ~isfield(P,'c1') || isempty(P.c1) || isequal(P.c1,0)
    error('Plant must have output')
else
    nz = size(P.c1,1);
    if nP~=size(P.c1,2)
        error('Dimension size error')
    end
end

if ~isfield(P,'c2') || isempty(P.c2) || isequal(P.c2,0)
    if strcmp(con,'fbiq') || strcmp(con,'fboq')
        error('Plant must have feedback output')
    else
        ny=0;
        P.c2=zeros(ny,nP);
    end
else
    ny = size(P.c2,1);
    if nP~=size(P.c2,2)
        error('Dimension size error')
    end
end

if ~isfield(P,'a') || isempty(P.a) || isequal(P.a,0)
    P.a  = zeros( nP );
else
    if nP~=size(P.a,1) || nP~=size(P.a,2)
        error('Dimension size error')
    end
end

%%%%%%%%% Check Controller %%%%%%%%%%
if ~strcmp(con,'ff')
    if ~isfield(K,'d2') || isempty(K.d2) || isequal(K.d2,0)
        K.d2 = zeros( nu , ny );
    end
    if nu~=size(K.d2,1) || ny~=size(K.d2,2)
        error('Dimension size error')
    end
    
    if ~isfield(K,'d1') || isempty(K.d1) || isequal(K.d1,0)
        if ~isfield(K,'b1') || isempty(K.b1) || isequal(K.b1,0)
            nr=0;
        else
            nr=size(K.b1,2);
        end
        K.d1=zeros( nu , nr );
    else
        nr=size(K.d1,2);
        if nu~=size(K.d1,1)
            error('Dimension size error')
        end
    end

    if ~isfield(K,'c') || isempty(K.c) || isequal(K.c,0)
        nK = 0;
        K.c  = zeros( nu , nK );
        K.a  = zeros( nK );
        K.b1 = zeros( nK , nr );
        K.b2 = zeros( nK , ny );
    else
        nK=size(K.c,2);
        if nu~=size(K.c,1)
            error('Dimension size error')
        end
        if ~isfield(K,'a') || isempty(K.a) || isequal(K.a,0)
            K.a = zeros( nK );
        else
            if nK~=size(K.a,1)
                error('Dimension size error')
            end
        end
        if ~isfield(K,'b1') || isempty(K.b1) || isequal(K.b1,0)
            K.b1 = zeros( nK , nr );
        else
            if nK~=size(K.b1,1) || nr~=size(K.b1,2)
                error('Dimension size error')
            end
        end
        if ~isfield(K,'b2') || isempty(K.b2) || isequal(K.b2,0)
            K.b2 = zeros( nK , ny );
        else
            if nK~=size(K.b2,1) || ny~=size(K.b2,2)
                error('Dimension size error')
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    +-----+   +-----+    %
% -->|  Q  |-->|  P  |--> %
%    +-----+   +-----+    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(con,'ff')==1
    G.a  = P.a;
    G.b1 = zeros( nP ,  0 );
    G.b2 = P.b;
    G.c1 = P.c1;
    G.c2 = zeros( nu , nP );
    G.d1 = zeros( nz ,  0 );
    G.d2 = zeros( nu ,  0 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     +-----+   +-----+   +-----+     %
% --->|     |   |     |   |     |---> %
%     |  K  |-->|  Q  |-->|  P  |     %
%  +->|     |   |     |   |     |--+  %
%  |  +-----+   +-----+   +-----+  |  %
%  +-------------------------------+  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(con,'fbiq')==1
    G.a  = [  P.a     zeros( nP , nK ) ;
            K.b2*P.c2    K.a           ];
    G.b1 = [ zeros( nP , nr ) ;
               K.b1           ];
    G.b2 = [   P.b            ;
             zeros( nK , nu ) ];
    G.c1 = [ P.c1      zeros( nz , nK ) ];
    G.c2 = [ K.d2*P.c2   K.c            ];
    G.d1 = zeros( nz , nr );
    G.d2 = K.d1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     +-----+           +-----+     %
% --->|     |           |     |---> %
%     |  K  |---------->|  P  |     %
%  +->|     |           |     |--+  %
%  |  +-----+  +-----+  +-----+  |  %
%  +-----------|  Q  |<----------+  %
%              +-----+              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(con,'fboq')==1
    G.a  = [  P.a            P.b*K.c ;
            zeros( nK , nP )   K.a   ];
    G.b1 = [ P.b*K.d1 ;
               K.b1   ];
    G.b2 = [ P.b*K.d2 ;
               K.b2   ];
    G.c1 = [ P.c1 zeros( nz , nK ) ];
    G.c2 = [ P.c2 zeros( nu , nK ) ];
    G.d1 = zeros( nz , nr );
    G.d2 = zeros( nu , nr );
    
%%%%%%%%%%OTHER%%%%%%%%%%
else
    error('illigal form')
end
%%%%%%%%%%%%%%%%%%%%%%%%%
