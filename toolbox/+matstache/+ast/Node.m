classdef Node < matlab.mixin.Heterogeneous
    properties
        Children (1,:) matstache.ast.Node
    end
end