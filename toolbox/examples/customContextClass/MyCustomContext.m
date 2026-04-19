classdef MyCustomContext < matstache.Context
    % Inherit from matstache.Context

    % {{ name }} will be interpolated by the property name
    properties
        name = "world"
    end

    methods
        function context = MyCustomContext(name)
            context.name = name;
        end

        % {{ greeting }} will be interpolated by the method greeting
        function out = greeting(context)
            out = "Hello " + context.name + "! It's a pleasure.";
        end
    end
end