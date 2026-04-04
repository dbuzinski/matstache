classdef Node < handle
    properties
        NodeType (1,1) matstache.NodeType
        Content (1,1) string
        Children (1,:) matstache.Node
    end

    methods
        function node = Node(nodeType, content, children)
            arguments
                nodeType (1,1) matstache.NodeType
                content (1,1) string
                children (1,:) matstache.Node = matstache.Node.empty()
            end
            node.NodeType = nodeType;
            node.Content = content;
            node.Children = children;
        end
    end
end