classdef RootNode < matstache.ast.Node
    methods
        function out = render(root, context)
            if isempty(root.Children)
                out = "";
            else
                out = strjoin(arrayfun(@(c)render(c, context), root.Children), "");
            end
        end
    end
end