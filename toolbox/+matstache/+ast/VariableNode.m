classdef VariableNode  < matstache.ast.Node
    properties
        Name
        Escaped
    end

    methods
        function node = VariableNode(name, options)
            arguments
                name (1,1) string
                options.Escaped (1,1) logical = true
            end
            node.Name = strip(name);
            node.Escaped = options.Escaped;
        end

        function out = render(node, context)
            arguments (Output)
                out (1,:) string
            end
            out = context.lookup(node.Name);
            % HTML escape forbidden characters
            if node.Escaped
                out = replace(string(out), ["&", """", "<", ">"], ["&amp;", "&quot;", "&lt;", "&gt;"]);
            end
        end
    end
end