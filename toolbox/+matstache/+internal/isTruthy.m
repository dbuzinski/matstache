function tf = isTruthy(data)
    % matstache.internal.isTruthy is an internal function.

    if isempty(data)
        tf = false;
    elseif ~isscalar(data)
        tf = true;
    elseif isa(data, "logical")
        tf = data;
    elseif isstring(data)
        tf = strlength(data) ~= 0;
    elseif isnumeric(data)
        tf = logical(data);
    else
        tf = true;
    end
end