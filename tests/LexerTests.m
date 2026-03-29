classdef LexerTests < matlab.unittest.TestCase
    properties
        Lexer (1,1) matstache.Lexer = matstache.Lexer()
    end

    methods (Test)
        function tokenizesEmpty(testCase)
            rawText = '';
            tokens = testCase.Lexer.tokenize(rawText);
            testCase.verifyEmpty(tokens);
        end

        function autoConvertsStrings(testCase)
            rawText = "Hello World!";
            tokens = testCase.Lexer.tokenize(rawText);
            testCase.verifyEqual(tokens, Token("Hello World!", "Text"));
        end

        function tokenizesText(testCase)
            rawText = 'Hello World!';
            tokens = testCase.Lexer.tokenize(rawText);
            testCase.verifyEqual(tokens, Token("Hello World!", "Text"));
        end

        function TokenizesComments(testCase)
            rawText = 'Hello {{! Lovely! }}World';
            tokens = testCase.Lexer.tokenize(rawText);
            testCase.verifyEqual(tokens, [Token("Hello ", "Text"), Token(" Lovely! ", "Comment"), Token("World", "Text")]);
        end

        function tokenizesVariables(testCase)
            rawText = 'Hello {{ subject }}!';
            tokens = testCase.Lexer.tokenize(rawText);
            testCase.verifyEqual(tokens, [Token("Hello ", "Text"), Token(" subject ", "Variable"), Token("!", "Text")]);
        end
    end
end

function token = Token(varargin)
token = matstache.Token(varargin{:});
end