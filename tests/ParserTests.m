classdef ParserTests < matlab.unittest.TestCase

    properties
        Parser = matstache.Parser;
    end

    methods (Test)
        function ignoresCommentTokens(testCase)
            tokens = [Token("Hello ", "Text", 1, 1, 1, 6), ...
                Token(" Lovely! ", "Comment", 1, 1, 7, 20), ...
                Token("World", "Text", 1, 1, 21, 25)];
            ast = testCase.Parser.parse(tokens);
            testCase.verifyEqual(ast, [TextNode("Hello "), TextNode("World")]);
        end
    end

end

function token = Token(varargin)
token = matstache.Token(varargin{:});
end

function node = TextNode(varargin)
node = matstache.ast.TextNode(varargin{:});
end