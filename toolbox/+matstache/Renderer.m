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
            out = renderer.renderAST(ast, contextStack, template, partials);
        end
    end

    methods (Access=private)
        function out = renderAST(renderer, ast, contextStack, template, partials)
            out = "";
            for node = ast
                switch node.TokenType
                    case matstache.internal.TokenType.Text
                        out = out + node.Content;
                    case matstache.internal.TokenType.Variable
                        out = out + renderer.renderVariableNode(node, contextStack, partials, true);
                    case matstache.internal.TokenType.UnescapedVariable
                        out = out + renderer.renderVariableNode(node, contextStack, partials, false);
                    case matstache.internal.TokenType.Section
                        out = out + renderer.renderSectionNode(node, contextStack, template, partials, false);
                    case matstache.internal.TokenType.Inverted
                        out = out + renderer.renderSectionNode(node, contextStack, template, partials, true);
                    case matstache.internal.TokenType.Partial
                        out = out + renderer.renderPartialNode(node, contextStack, partials);
                end
            end
        end

        function out = renderVariableNode(renderer, node, contextStack, partials, escaped)
            out = "";
            key = node.Content;
            res = contextStack.lookup(key);
            % Handle lambdas
            if isa(res, "function_handle")
                [~, ctx] = contextStack.pop();
                if escaped
                    out = out + replace(renderer.render(res(), ctx, partials), ["&", """", "<", ">"], ["&amp;", "&quot;", "&lt;", "&gt;"]);
                else
                    out = out + renderer.render(res(), ctx, partials);
                end
            elseif escaped
                for data = iter(res)
                    out = out + replace(toString(data, key), ["&", """", "<", ">"], ["&amp;", "&quot;", "&lt;", "&gt;"]);
                end
            else
                for data = iter(res)
                    out = out + toString(data);
                end
            end
        end
        
        function out = renderSectionNode(renderer, node, contextStack, template, partials, inverted)
            out = "";
            res = contextStack.lookup(node.Content);
            isTruthy = matstache.internal.isTruthy(res);
            if isTruthy && ~inverted
                % Handle lambdas
                if isa(res, "function_handle")
                    % Evaluate as arity 1 function against child content
                    lambdaEval = res(childContent(node, template));
                    % Render with current delimiters
                    % May want to clean this up a little in the future
                    lexer = matstache.internal.Lexer(Delimiters=string({node.LeftDelimiter, node.RightDelimiter}));
                    tokens = lexer.tokenize(lambdaEval, Reset=false);
                    ast = renderer.Parser.parseTokens(tokens);
                    out = out + renderAST(renderer, ast, contextStack, lambdaEval, partials);
                else
                    it = iter(res);
                    for data = it(:)'
                        out = out + renderChildren(renderer, node.Children, data{1}, contextStack, template, partials);
                    end
                end
            elseif ~isTruthy && inverted
                % Do not need lambdas in this branch because lambdas are
                % always truthy
                for child = node.Children
                    out = out + renderAST(renderer, child, contextStack, template, partials);
                end
            end
        end

        function out = renderChildren(renderer, children, data, contextStack, template, partials)
            out = "";
            contextStack = contextStack.push(data);
            for child = children
                out = out + renderAST(renderer, child, contextStack, template, partials);
            end
        end

        function out = renderPartialNode(renderer, node, contextStack, partials)
            if ~isfield(partials, node.Content)
                out = "";
                return
            end
            partialTemplate = string(partials.(node.Content));
            % Add indentations. We store preceeding whitespace as child nodes
            % for partials
            if ~isempty(node.Children)
                partialTemplate = splitlines(partialTemplate);
                indentation = join([node.Children.Content], "");
                offset = 0;
                % Don't append to the last element if it is a trailing newline
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

function it = iter(data)
    if ischar(data) || iscellstr(data) %#ok<ISCLSTR> disable warning because we convert to string anyways
        data = string(data);
    end
    if ~iscell(data)
        data = num2cell(data);
    end
    it = data;
end

function s = toString(data, key)
try
    s = string(data);
catch
    error("matstache:UnableToConvertToString", "Unable to convert context data '%s' from type %s to string.", key, class(data{1}));
end
end

function s = childContent(node, template)
s = "";
for child = node.Children
    s = s + extractBetween(template, child.StartPosition, child.EndPosition);
end
end