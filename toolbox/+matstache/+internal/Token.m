classdef Token < handle
    properties
        Content (1,1) string
        TokenType matstache.internal.TokenType {mustBeScalarOrEmpty}
        StartLine (1,1) int64
        EndLine (1,1) int64
        StartColumn (1,1) int64
        EndColumn (1,1) int64
        Children (1,:) matstache.internal.Token
    end

    methods
        function token = Token(content, tokenType, startLine, endLine, startColumn, endColumn, children)
            arguments
                content
                tokenType
                startLine
                endLine
                startColumn
                endColumn
                children = matstache.internal.Token.empty()
            end
            token.Content = content;
            token.TokenType = tokenType;
            token.StartLine = startLine;
            token.EndLine = endLine;
            token.StartColumn = startColumn;
            token.EndColumn = endColumn;
            token.Children = children;
        end
    end
end