classdef Context < matlab.mixin.Heterogeneous
    methods (Hidden, Sealed)
        function [tf, val] = lookup__(ctx, key)
            [tf, val] = lookupElement__(ctx, key);
        end
    end

    methods (Hidden)
        function ctx = current__(ctx)
        end
    end

    methods (Access=protected)
        function [tf, val] = lookupElement__(ctx, key)
            if isprop(ctx, key) || ismethod(ctx, key)
                tf = true;
                val = ctx.(key);
            else
                tf = false;
                val = [];
            end
        end
    end

    methods (Static, Sealed, Access = protected)
        function cobj = convertObject(~, obj)
            cobj = matstache.internal.DataContext(obj);
        end
    end
end