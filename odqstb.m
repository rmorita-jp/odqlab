function stb=odqstb(Q)
%ODQSTB Check the stability of Q
%
%If Q is stable, stb=1.
%Otherwise stb=0.
%
%See also odq 

if max(abs(eig(Q.a+Q.b2*Q.c)))>1
    stb=0;
else
    stb=1;
end