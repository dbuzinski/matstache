classdef Renderer
    methods
        function out = render(renderer, ast, contextStack, partials)
            out = "";
            for node = ast
                switch node.NodeType
                    case matstache.NodeType.Root
                        for child = node.Children
                            out = out + render(renderer, child, contextStack, partials);
                        end
                    case matstache.NodeType.Text
                        out = out + node.Content;
                    case matstache.NodeType.Variable
                        out = out + renderer.renderVariableNode(node, contextStack, true);
                    case matstache.NodeType.UnescapedVariable
                        out = out + renderer.renderVariableNode(node, contextStack, false);
                    case matstache.NodeType.Section
                        out = out + renderer.renderSectionNode(node, contextStack, false, partials);
                    case matstache.NodeType.InvertedSection
                        out = out + renderer.renderSectionNode(node, contextStack, true, partials);
                    case matstache.NodeType.Partial
                        out = out + renderer.renderPartialNode(node, contextStack, partials);
                end
            end
        end
    end

    methods (Access=private)
        function out = renderVariableNode(~, node, contextStack, escaped)
            out = "";
            res = contextStack.lookup(node.Content);
            if escaped
                nodeOutput = cellfun(@escapedString, res.iter());
            else
                nodeOutput = cellfun(@string, res.iter());
            end
            if ~isempty(nodeOutput)
                out = out + string(nodeOutput).join("");
            end
        end
        
        function out = renderSectionNode(renderer, node, contextStack, inverted, partials)
            out = "";
            res = contextStack.lookup(node.Content);
            isTruthy = res.isTruthy();
            if isTruthy && ~inverted
                it = res.iter();
                for data = it(:)'
                    contextStack = contextStack.push(data{1});
                    for child = node.Children
                        out = out + render(renderer, child, contextStack, partials);
                    end
                    contextStack = contextStack.pop();
                end
            elseif ~isTruthy && inverted
                for child = node.Children
                    out = out + render(renderer, child, contextStack, partials);
                end
            end
        end

        function out = renderPartialNode(~, node, contextStack, partials)
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
            [~, ctx] = contextStack.pop();
            out = matstache.render(partialTemplate, ctx, partials);
        end
    end
end

function out = escapedString(s)
out = replace(string(s), ["&", """", "<", ">"], ["&amp;", "&quot;", "&lt;", "&gt;"]);
end