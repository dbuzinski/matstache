function tf = isTruthy(val)
    if isempty(val)
        tf = false;
    elseif isa(val, "logical")
        tf = val;
    elseif isstring(val)
        tf = strlength(val) ~= 0;
    else
        tf = true;
    end
end