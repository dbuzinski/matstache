classdef Token
    properties
        Content (1,1) string
        TokenType matstache.TokenType {mustBeScalarOrEmpty}
        StartLine (1,1) int64
        EndLine (1,1) int64
        StartColumn (1,1) int64
        EndColumn (1,1) int64
        ContainsNewLine (1,1) logical
    end

    methods
        function token = Token(content, tokenType, startLine, endLine, startColumn, endColumn)
            token.Content = content;
            token.TokenType = tokenType;
            token.StartLine = startLine;
            token.EndLine = endLine;
            token.StartColumn = startColumn;
            token.EndColumn = endColumn;
        end
    end
end