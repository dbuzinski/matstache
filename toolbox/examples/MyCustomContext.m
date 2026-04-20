classdef MyCustomContext < matstache.Context
    properties
        name (1,1) string
    end

    methods
        function context = MyCustomContext(name)
            arguments
                name (1,1) string = "world"
            end
            context.name = string(name);
        end

        function out = greeting(context)
            out = "Hello " + context.name + "! It's a pleasure.";
        end
    end
end