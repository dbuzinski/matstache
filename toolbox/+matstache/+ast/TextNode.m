classdef TextNode < matstache.ast.Node
    properties
        Value
    end

    methods
        function node = TextNode(value)
            node.Value = value;
        end

        function out = render(node, ~)
            out = node.Value;
        end
    end
end