classdef ContextResult
    properties
        Success (1,1) logical
        Data
    end

    methods
        function res = ContextResult(success, data)
            res.Success = success;
            res.Data = data;
        end

        function tf = isTruthy(res)
            data = res.Data;
            if isempty(data)
                tf = false;
            elseif ~isscalar(data)
                tf = true;
            elseif isa(data, "logical")
                tf = data;
            elseif isstring(data) || ischar(data)
                tf = strlength(data) ~= 0;
            elseif isnumeric(data)
                tf = logical(data);
            else
                tf = true;
            end
        end

        function it = iter(res)
            data = res.Data;
            if ischar(data) || iscellstr(data)
                data = string(data);
            end
            if ~iscell(data)
                data = num2cell(data);
            end
            it = data;
        end
    end
end