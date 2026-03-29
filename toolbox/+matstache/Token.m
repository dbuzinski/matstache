classdef Token
    properties
        Content (1,1) string
        TokenType matstache.TokenType {mustBeScalarOrEmpty}
    end

    methods
        function token = Token(content, tokenType)
            token.Content = content;
            token.TokenType = tokenType;
        end
    end
end