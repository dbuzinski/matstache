classdef JsonContext < matstache.Context
    properties
        Data
    end

    methods
        function ctx = JsonContext(data)
            ctx.Data = data;
        end

        function val = current(ctx)
            val = ctx.Data;
        end
    end

    methods (Access=protected)
        function [tf, val] = lookupElement(ctx, key)
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