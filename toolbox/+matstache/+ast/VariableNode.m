classdef VariableNode  < matstache.ast.Node
    properties
        Name
    end

    methods
        function node = VariableNode(name)
            % strtrim appears to be faster than strip for chars
            node.Name = strtrim(name);
        end

        function out = render(node, context)
            out = context.lookup(node.Name);
        end
    end
end