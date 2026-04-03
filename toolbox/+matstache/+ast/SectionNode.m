classdef SectionNode < matstache.ast.Node
    properties
        Name
    end

    methods
        function node = SectionNode(name)
            node.Name = strip(name);
        end

        function out = render(node, context)
            stackContext = context.lookup(node.Name);
            if ~matstache.internal.isTruthy(stackContext)
                out = "";
            else
                % create context with stack data on top for use in the
                % section
                context = context.push(stackContext);
                sectionText = "";
                for child = node.Children
                    % For iterators, render call is vectorized.
                    % Currently we do vectorized + and then join at the
                    % end. To do: add better error handling for dimension
                    % mismatches.
                    sectionText = sectionText + render(child, context);
                end
                out = strjoin(sectionText, "");
            end
        end
    end
end