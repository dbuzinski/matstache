classdef Context
    properties (Access=private)
        Stack = {};
    end

    methods
        function ctx = Context(data)
            ctx.Stack{1} = data;
        end

        function ctx = push(ctx, data)
            ctx.Stack{end+1} = data;
        end

        function [ctx, s] = pop(ctx)
            if isempty(ctx.Stack)
                error("mustache:PopEmptyContext", "Unable to pop from an empty context");
            end
            s = ctx.Stack{end};
            ctx.Stack(end) = [];
        end

        function val = lookup(context, key)
            % Return top of stack for .
            if strcmp(key, ".")
                val = context.Stack{end};
                return;
            end

            % Split on keys
            ctx = context;
            part = key.split(".");
            for k = part(:)'
                % Walk the stack backwards to check for a hit
                % Return on first hit
                for i=numel(ctx.Stack):-1:1
                    curr = ctx.Stack{i};
                    [tf, val] = getKey(curr, k);
                    if tf
                        ctx = matstache.Context(val);
                        break;
                    end
                end

                if ~matstache.internal.isTruthy(val)
                    % Failed context lookups should default to empty strings
                    % Falsey values also default to empty
                    val = "";
                    break;
                end
            end
        end
    end
end

function [tf, val] = getKey(data, key)
tf = false;
val = [];
if isstruct(data) && isfield(data, key)
    val = data.(key);
    val = val(:)';
    tf = true;
end
end
