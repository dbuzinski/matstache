classdef Context < matlab.mixin.Heterogeneous
    % Context - Data used to render Mustache templates
    %
    %   The matstache.Context class represents context data used to render
    %   Mustache templates.
    %
    %   When specifying inputs to functions, you can use structs instead of
    %   Context objects.  MATLAB automatically converts structs to Context
    %   objects.
    %
    %   Examples:
    %
    %      % Automatically convert a struct to a context
    %      context = [matstache.Context.empty(), struct("title","Hello","name","world")];
    %      out = matstache.render("{{title}}, {{name}}!", context);
    %
    %      % Create a subclass of matstache.Context with properties title and name
    %      context = MyContextClass();
    %      context.title = "Hello";
    %      context.name = "world";
    %      out = matstache.render("{{title}}, {{name}}!", context);
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
