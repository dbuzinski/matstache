classdef ContextObject < matstache.Context
    properties
        name = "Dave"
    end

    methods
        function sup = greeting(obj)
            sup = "Sup " + obj.name;
        end

        function obj = nested(obj)
            % returns itself back
        end
    end
end