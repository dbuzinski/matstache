classdef Renderer
    methods
        function out = render(renderer, ast, context)
            out = "";
            for node = ast
                switch node.NodeType
                    case matstache.NodeType.Root
                        for child = node.Children
                            out = out + render(renderer, child, context);
                        end
                    case matstache.NodeType.Text
                        out = out + node.Content;
                    case matstache.NodeType.Variable
                        data = context.lookup(node.Content);
                        if isscalar(data) || ischar(data)
                            data = {string(data)};
                        elseif ~iscell(data)
                            data = num2cell(data);
                        elseif iscellstr(data)
                            data = num2cell(string(data));
                        end
                        for i = 1:numel(data)
                            out = out + data{i}.replace(["&", """", "<", ">"], ["&amp;", "&quot;", "&lt;", "&gt;"]);
                        end
                    case matstache.NodeType.UnescapedVariable
                        data = context.lookup(node.Content);
                        if isscalar(data) || ischar(data)
                            data = {string(data)};
                        elseif ~iscell(data)
                            data = num2cell(data);
                        elseif iscellstr(data)
                            data = string(data);
                        end
                        for i = 1:numel(data)
                            out = out + data{i};
                        end
                    case matstache.NodeType.Section
                        data = context.lookup(node.Content);
                        if matstache.internal.isTruthy(data)
                            context = context.push(data);
                            for child = node.Children
                                out = out + render(renderer, child, context);
                            end
                            context = context.pop();
                        end
                    case matstache.NodeType.InvertedSection
                        data = context.lookup(node.Content);
                        if ~matstache.internal.isTruthy(data)
                            context.push(data)
                            for child = node.Children
                                out = out + render(renderer, child, context);
                            end
                            context.pop()
                        end
                    case matstache.NodeType.Partial
                end
            end
        end
    end
end