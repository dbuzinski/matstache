classdef Parser < handle
    properties
        LineBuffer (1,:) matstache.ast.Node;
    end
    methods
        function ast = parse(parser, tokens)
            import matstache.ast.*;

            ast = RootNode;
            standaloneLine = false;
            allWhitespace = true;
            stack = {};
            root = ast;
            for token = tokens
                switch token.TokenType
                    case matstache.TokenType.Comment
                        if contains(token.Content, newline)
                            allWhitespace = true;
                        end
                        standaloneLine = allWhitespace;
                    case matstache.TokenType.Text
                        content = token.Content;
                        parser.LineBuffer(end+1) = TextNode(content);
                        % Strip whitespace for standalone lines
                        if ~all(isspace(content))
                            allWhitespace = false;
                            standaloneLine = false;
                        end
                        if endsWith(content, newline)
                            if ~standaloneLine
                                root.Children = [root.Children, parser.LineBuffer];
                            end
                            parser.LineBuffer = Node.empty();
                            allWhitespace = true;
                            standaloneLine = false;
                        end
                    case matstache.TokenType.Variable
                        root.Children = [root.Children, parser.LineBuffer VariableNode(token.Content)];
                        parser.LineBuffer = Node.empty();
                        allWhitespace = false;
                        standaloneLine = false;
                    case matstache.TokenType.UnescapedVariable
                        root.Children = [root.Children, parser.LineBuffer VariableNode(token.Content, Escaped=false)];
                        parser.LineBuffer = Node.empty();
                        allWhitespace = false;
                        standaloneLine = false;
                    case matstache.TokenType.SectionStart
                        if contains(token.Content, newline)
                            allWhitespace = true;
                        end
                        standaloneLine = allWhitespace;
                        root.Children = [root.Children, parser.LineBuffer];
                        parser.LineBuffer = Node.empty();
                        stack{end+1} = root;
                        root = SectionNode(token.Content);
                    case matstache.TokenType.SectionEnd
                        if contains(token.Content, newline)
                            allWhitespace = true;
                        end
                        standaloneLine = allWhitespace;
                        root.Children = [root.Children, parser.LineBuffer];
                        parser.LineBuffer = Node.empty();
                        newRoot = stack{end};
                        newRoot.Children = [newRoot.Children, root];
                        root = newRoot;
                        stack(end) = [];

                end
            end
            if ~standaloneLine
                root.Children = [root.Children, parser.LineBuffer];
            end
        end
    end
end