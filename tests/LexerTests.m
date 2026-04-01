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
            expected = Token("Hello World!", "Text", 1, 1, 1, 12);
            testCase.verifyEqual(expected, tokens);
        end

        function tokenizesText(testCase)
            rawText = 'Hello World!';
            tokens = testCase.Lexer.tokenize(rawText);
            expected = Token("Hello World!", "Text", 1, 1, 1, 12);
            testCase.verifyEqual(expected, tokens);
        end

        function TokenizesComments(testCase)
            rawText = 'Hello {{! Lovely! }}World';
            tokens = testCase.Lexer.tokenize(rawText);
            expected = [Token("Hello ", "Text", 1, 1, 1, 6), ...
                Token(" Lovely! ", "Comment", 1, 1, 7, 20), ...
                Token("World", "Text", 1, 1, 21, 25)];
            testCase.verifyEqual(expected, tokens);
        end

        function tokenizesVariables(testCase)
            rawText = 'Hello {{ subject }}!';
            tokens = testCase.Lexer.tokenize(rawText);
            expected = [Token("Hello ", "Text", 1, 1, 1, 6), ...
                Token(" subject ", "Variable", 1, 1, 7, 19), ...
                Token("!", "Text", 1, 1, 20, 20)];
            testCase.verifyEqual(expected, tokens);
        end

        function tracksNewlines(testCase)
            rawText = ['Hello ' newline ' World{{! Comment '  newline '  }}!'];
            tokens = testCase.Lexer.tokenize(rawText);
            % expected = [Token(['Hello ' newline ' World'], "Text", 1, 2, 1, 6), ...
            %     Token([' Comment '  newline], "Comment", 2, 3, 7, 2), ...
            %     Token("!", "Text", 3, 3, 3, 3)];
            expected = [Token(['Hello ' newline], "Text", 1, 1, 1, 7), ...
                Token(' World', "Text", 2, 2, 1, 6), ...
                Token([' Comment '  newline '  '], "Comment", 2, 3, 7, 4), ...
                Token("!", "Text", 3, 3, 5, 5)];
            testCase.verifyEqual(expected, tokens);
        end
    end
end

function token = Token(varargin)
token = matstache.Token(varargin{:});
end