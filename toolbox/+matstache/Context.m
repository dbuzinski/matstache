classdef Context < handle
    properties (Access=private)
        Stack = {};
    end

    methods
        function ctx = Context(s)
            ctx.Stack{1} = s;
        end

        function push(ctx, s)
            ctx.Stack{end+1} = s;
        end

        function s = pop(ctx)
            if isempty(ctx.Stack)
                error('Stack is empty. Cannot pop.');
            end
            s = ctx.Stack{end};
            ctx.Stack(end) = [];
        end

        function val = lookup(context, name)
            val = missing;
            for i=numel(context):-1:1
                curr = context.Stack{i};
                if isstruct(curr) && isfield(curr, name)
                    val = curr.(name);
                    break;
                end
            end
            if ismissing(val)
                error('Field "%s" not found in the context.', name);
            end
        end

        function val = current(context)
            val = context{end};
        end
    end
end