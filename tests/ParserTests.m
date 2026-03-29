classdef ParserTests < matlab.unittest.TestCase

    properties
        Parser = matstache.Parser;
    end

    methods (Test)
        function ignoresCommentTokens(testCase)
            tokens = [Token("Hello ", "Text"), Token(" Lovely! ", "Comment"), Token("World", "Text")];
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