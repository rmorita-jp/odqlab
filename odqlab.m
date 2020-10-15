function odqlab(debugflag)
%ODQLAB Design Tool for Optimal Dynamic Quantizer
%       Help message is unavailable yet

if ~nargin
    debugflag=0;
end
    
handles.ODQDesign=odqlab_design(debugflag);

end

