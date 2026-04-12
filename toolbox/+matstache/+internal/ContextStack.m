classdef ContextStack
    properties (Access=private)
        Stack (1,:) matstache.Context;
    end

    methods
        function stack = ContextStack(ctx)
            arguments
                ctx (1,:) matstache.Context
            end
            stack.Stack = ctx;
        end

        function stack = push(stack, ctx)
            if ~isa(ctx, "matstache.Context")
                ctx = matstache.internal.DataContext(ctx);
            end
            stack.Stack(end+1) = ctx;
        end

        function [stack, ctx] = pop(stack)
            if isempty(stack.Stack)
                error("mustache:PopEmptyContextStack", "Unable to pop from an empty context stack");
            end
            ctx = stack.Stack(end);
            stack.Stack(end) = [];
        end

        function res = lookup(stack, key)
            % Return top of stack for .
            if strcmp(key, ".")
                val = stack.Stack(end).current__();
                res = matstache.internal.LookupResult(true, val);
                return;
            end

            % Split on keys
            part = key.split(".");
            % Walk the stack backwards to check for a hit
            % Return on first hit
            start = part(1);
            for i=numel(stack.Stack):-1:1
                curr = stack.Stack(i);
                [tf, val] = lookup__(curr, start);
                if tf
                    if ~isa(val, "matstache.Context")
                        curr = matstache.internal.DataContext(val);
                    else
                        curr = val;
                    end
                    break;
                end
            end

            % Return if we didn't get a hit or found an empty context
            if ~tf
                res = matstache.internal.LookupResult(false, []);
                return;
            end

            % Now find remaining parts of the key in that context
            remaining = part(2:end);
            for k = remaining(:)'
                % Look up in that context until we've resolved all parts or
                % get a miss
                [tf, val] = lookup__(curr, k);
                if tf
                    if ~isa(val, "matstache.Context")
                        curr = matstache.internal.DataContext(val);
                    else
                        curr = val;
                    end
                else
                    break;
                end
            end
            res = matstache.internal.LookupResult(tf, val);
        end
    end
end