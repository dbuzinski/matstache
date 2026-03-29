classdef Renderer
    methods
        function out = render(~, ast, context)
            out = "";
            for node = ast
                out = out + node.render(context);
            end
        end
    end
end