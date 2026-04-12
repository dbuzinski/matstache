classdef DataContext < matstache.Context
    properties
        Data
    end

    methods
        function ctx = DataContext(data)
            ctx.Data = data;
        end
    end

    methods (Hidden)
        function val = current__(ctx)
            val = ctx.Data;
        end
    end

    methods (Hidden, Access=protected)
        function [tf, val] = lookupElement__(ctx, key)
            data = ctx.Data;
            if isstruct(data) && isfield(data, key)
                val = data.(key);
                val = val(:)';
                tf = true;
            else
                tf = false;
                val = [];
            end
        end
    end
end