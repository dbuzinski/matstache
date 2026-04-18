classdef Token < handle
    properties
        Content (1,1) string
        TokenType matstache.internal.TokenType {mustBeScalarOrEmpty}
        StartLine (1,1) int64
        EndLine (1,1) int64
        StartColumn (1,1) int64
        EndColumn (1,1) int64
        StartPosition (1,1) int64
        EndPosition (1,1) int64
        LeftDelimiter (1,:) char
        RightDelimiter (1,:) char
        Children (1,:) matstache.internal.Token
    end

    methods
        function token = Token(content, tokenType, startLine, endLine, ...
                startColumn, endColumn, startPosition, endPosition, ...
                leftDelimiter, rightDelimiter, children)
            arguments
                content
                tokenType
                startLine
                endLine
                startColumn
                endColumn
                startPosition
                endPosition
                leftDelimiter = '{{',
                rightDelimiter = '}}',
                children = matstache.internal.Token.empty()
            end
            token.Content = content;
            token.TokenType = tokenType;
            token.StartLine = startLine;
            token.EndLine = endLine;
            token.StartColumn = startColumn;
            token.EndColumn = endColumn;
            token.StartPosition = startPosition;
            token.EndPosition = endPosition;
            token.LeftDelimiter = leftDelimiter;
            token.RightDelimiter = rightDelimiter;
            token.Children = children;
        end
    end
end