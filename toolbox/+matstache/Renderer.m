classdef Renderer
    methods
        function out = render(renderer, ast, context, partials)
            out = "";
            for node = ast
                switch node.NodeType
                    case matstache.NodeType.Root
                        for child = node.Children
                            out = out + render(renderer, child, context, partials);
                        end
                    case matstache.NodeType.Text
                        out = out + node.Content;
                    case matstache.NodeType.Variable
                        out = out + renderer.renderVariableNode(node, context, true);
                    case matstache.NodeType.UnescapedVariable
                        out = out + renderer.renderVariableNode(node, context, false);
                    case matstache.NodeType.Section
                        out = out + renderer.renderSectionNode(node, context, false, partials);
                    case matstache.NodeType.InvertedSection
                        out = out + renderer.renderSectionNode(node, context, true, partials);
                    case matstache.NodeType.Partial
                        out = out + renderer.renderPartialNode(node, context, partials);
                end
            end
        end
    end

    methods (Access=private)
        function out = renderVariableNode(~, node, context, escaped)
            out = "";
            data = context.lookup(node.Content);
            data = sanitize(data);
            for i = 1:numel(data)
                if escaped
                    out = out + replace(string(data{i}), ["&", """", "<", ">"], ["&amp;", "&quot;", "&lt;", "&gt;"]);
                else
                    out = out + data{i};
                end
            end
        end
        
        function out = renderSectionNode(renderer, node, context, inverted, partials)
            out = "";
            data = context.lookup(node.Content);
            data = sanitize(data);
            isTruthy = ~isscalar(data) || matstache.internal.isTruthy(data{1});
            if (isTruthy && ~inverted) ...
                    || (~isTruthy && inverted)
                for i = 1:numel(data)
                    context = context.push(data{i});
                    for child = node.Children
                        out = out + render(renderer, child, context, partials);
                    end
                    context = context.pop();
                end
            end
        end

        function out = renderPartialNode(~, node, context, partials)
            if ~isfield(partials, node.Content)
                out = "";
                return
            end
            partialTemplate = string(partials.(node.Content));
            % add indentations
            if node.IsStandalone
                partialTemplate = splitlines(partialTemplate);
                indentation = string(repmat(' ', 1, node.StartColumn - 1));
                offset = 0;
                % don't append to the last element if it is a trailing
                % newline
                if strlength(partialTemplate(end)) == 0
                    offset = -1;
                end
                partialTemplate(1:end+offset) = indentation + partialTemplate(1:end+offset);
                partialTemplate = join(partialTemplate, newline);
            end
            out = matstache.render(partialTemplate, context, partials);
        end
    end
end

function data = sanitize(data)
    % Sanitize data
    if ischar(data)
        data = {string(data)};
    % Convert arrays to cell arrays
    elseif ~iscell(data)
        data = num2cell(data);
    % Convert cellstrs to cells of strings
    elseif iscellstr(data)
        data = num2cell(string(data));
    end
end