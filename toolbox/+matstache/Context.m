classdef Context < matlab.mixin.Heterogeneous
    methods (Sealed)
        function [tf, val] = lookup(ctx, key)
            [tf, val] = lookupElement(ctx, key);
        end
    end

    methods (Access=protected)
        function [tf, val] = lookupElement(ctx, key)
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
            cobj = matstache.internal.JsonContext(obj);
        end
    end
end