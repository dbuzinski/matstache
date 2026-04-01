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

        function val = lookup(context, key)
            if strcmp(key, ".")
                val = context.Stack{end};
                return;
            end

            ctx = context;
            part = key.split(".");
            for k = part(:)'
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

        function val = current(context)
            val = context{end};
        end
    end
end

function [tf, val] = getKey(data, key)
tf = false;
if isstruct(data) && isfield(data, key)
    val = data.(key);
    tf = true;
else
    val = [];
end
end