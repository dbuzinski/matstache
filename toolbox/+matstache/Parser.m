classdef Parser
    methods
        function ast = parse(~, tokens)
            import matstache.ast.*;

            ast = Node.empty();
            for token = tokens
                switch token.TokenType
                    case matstache.TokenType.Text
                        ast(end+1) = TextNode(token.Content);
                    case matstache.TokenType.Variable
                        ast(end+1) = VariableNode(token.Content);
                end
            end
        end
    end
end