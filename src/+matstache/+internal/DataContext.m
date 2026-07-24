classdef DataContext < matstache.Context
    % matstache.internal.DataContext is an internal class.

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
                tf = true;
                val = data.(key);
                % This guard is important for lambdas
                if ~isscalar(val)
                    val = val(:)';
                end
            else
                tf = false;
                val = [];
            end
        end
    end
end