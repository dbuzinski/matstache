classdef Context < matlab.mixin.Heterogeneous
    % Context - Template context for Mustache rendering
    %
    %   The matstache.Context class is the base type for template data passed
    %   to matstache.render and matstache.Renderer. Context data can be a
    %   struct or a subclass of matstache.Context whose field names,
    %   properties, and methods match tags referenced in the template.
    %
    %   Examples:
    %
    %      % Automatically convert a struct to a context
    %      ctx = [matstache.Context.empty(), struct("title","Hello","name","world")];
    %      out = matstache.render("{{title}}, {{name}}!", ctx);
    %
    %      % Create a subclass of matstache.Context with properties title and name
    %      ctx = MyContextClass();
    %      ctx.title = "Hello";
    %      ctx.name = "world";
    %      out = matstache.render("{{title}}, {{name}}!", ctx);
    %      
    %   See also matstache.Renderer, matstache.render

    methods (Hidden, Sealed)
        function [tf, val] = lookup__(ctx, key)
            [tf, val] = lookupElement__(ctx, key);
        end
    end

    methods (Hidden)
        function ctx = current__(ctx)
        end
    end

    methods (Hidden, Access=protected)
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
