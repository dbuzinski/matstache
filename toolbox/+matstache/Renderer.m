classdef Renderer
    properties
        Parser
    end

    methods
        function r = Renderer(parser)
            arguments
                parser (1,1) matstache.internal.Parser = matstache.internal.Parser(matstache.internal.Lexer)
            end
            r.Parser = parser;
        end

        function out = render(renderer, template, context, partials)
            arguments (Input)
                renderer (1,1) matstache.Renderer
                template (1,1) string
                context (1,1) matstache.Context
                partials (1,1) struct = struct()
            end
            arguments (Output)
                out (1,1) string
            end
            ast = renderer.Parser.parse(template);
            contextStack = matstache.internal.ContextStack(context);
            out = renderer.renderAST(ast, contextStack, partials);
        end
    end

    methods (Access=private)
        function out = renderAST(renderer, ast, contextStack, partials)
            out = "";
            for node = ast
                switch node.TokenType
                    case matstache.internal.TokenType.Text
                        out = out + node.Content;
                    case matstache.internal.TokenType.Variable
                        out = out + renderer.renderVariableNode(node, contextStack, true);
                    case matstache.internal.TokenType.UnescapedVariable
                        out = out + renderer.renderVariableNode(node, contextStack, false);
                    case matstache.internal.TokenType.SectionStart
                        out = out + renderer.renderSectionNode(node, contextStack, false, partials);
                    case matstache.internal.TokenType.InvertedStart
                        out = out + renderer.renderSectionNode(node, contextStack, true, partials);
                    case matstache.internal.TokenType.Partial
                        out = out + renderer.renderPartialNode(node, contextStack, partials);
                end
            end
        end

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
                    out = out + renderChildren(renderer, node.Children, data{1}, contextStack, partials);
                end
            elseif ~isTruthy && inverted
                for child = node.Children
                    out = out + renderAST(renderer, child, contextStack, partials);
                end
            end
        end

        function out = renderChildren(renderer, children, data, contextStack, partials)
            out = "";
            contextStack = contextStack.push(data);
            for child = children
                out = out + renderAST(renderer, child, contextStack, partials);
            end
        end

        function out = renderPartialNode(renderer, node, contextStack, partials)
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
            out = renderer.render(partialTemplate, ctx, partials);
        end
    end
end

function out = escapedString(s)
out = replace(string(s), ["&", """", "<", ">"], ["&amp;", "&quot;", "&lt;", "&gt;"]);
end