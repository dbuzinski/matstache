classdef ContextData
    properties
        Data
    end

    methods
        function obj = ContextData(data)
            obj.Data = data;
        end

        function [val, tf] = get(data, key)
            tf = false;
            val = [];
            if isstruct(data) && isfield(data, key)
                val = data.(key);
                val = val(:)';
                tf = true;
            end
        end

        function val = getCurrent(obj)
            val = obj.Data;
        end
    end
end