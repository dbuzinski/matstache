classdef Node < handle
    properties
        NodeType (1,1) matstache.NodeType
        Content (1,1) string
        StartLine (1,1) int64
        EndLine (1,1) int64
        StartColumn (1,1) int64
        EndColumn (1,1) int64
        Children (1,:) matstache.Node
        IsStandalone (1,1) logical
    end

    methods
        function node = Node(nodeType, content, startLine, endLine, startColumn, endColumn, isStandalone, children)
            arguments
                nodeType (1,1) matstache.NodeType
                content (1,1) string
                startLine (1,1) int64
                endLine (1,1) int64
                startColumn (1,1) int64
                endColumn (1,1) int64
                isStandalone (1,1) logical = false
                children (1,:) matstache.Node = matstache.Node.empty()
            end
            node.NodeType = nodeType;
            node.Content = content;
            node.StartLine = startLine;
            node.EndLine = endLine;
            node.StartColumn = startColumn;
            node.EndColumn = endColumn;
            node.Children = children;
            node.IsStandalone = isStandalone;
        end
    end
end