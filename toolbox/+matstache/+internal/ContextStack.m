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
            stack.Stack = [stack.Stack, ctx];
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
                val = stack.Stack(end).current();
                res = matstache.internal.ContextResult(true, val);
                return;
            end

            % Split on keys
            part = key.split(".");
            for k = part(:)'
                % Walk the stack backwards to check for a hit
                % Return on first hit
                for i=numel(stack.Stack):-1:1
                    curr = stack.Stack(i);
                    [tf, val] = lookup(curr, k);
                    if tf
                        stack = matstache.internal.ContextStack(val);
                        break;
                    end
                end
                res = matstache.internal.ContextResult(tf, val);
            end
        end
    end
end