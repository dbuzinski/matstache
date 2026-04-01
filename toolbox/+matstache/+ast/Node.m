classdef Node < matlab.mixin.Heterogeneous & handle
    properties
        Children (1,:) matstache.ast.Node
    end

    methods (Abstract)
        out = render(node, context)
    end
end