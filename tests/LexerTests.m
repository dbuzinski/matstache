classdef LexerTests < matlab.unittest.TestCase
    methods (Test)
        function tokenizesEmpty(testCase)
            lexer = matstache.Lexer();
            rawText = '';
            tokens = lexer.tokenize(rawText);
            testCase.verifyEmpty(tokens);
        end

        function autoConvertsStrings(testCase)
            lexer = matstache.Lexer();
            rawText = "Hello World!";
            expected = Token("Hello World!", "Text", 1, 1, 1, 12);
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesText(testCase)
            lexer = matstache.Lexer();
            rawText = 'Hello World!';
            expected = Token("Hello World!", "Text", 1, 1, 1, 12);
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function TokenizesComments(testCase)
            lexer = matstache.Lexer();
            rawText = 'Hello {{! Lovely! }}World';
            expected = [Token("Hello ", "Text", 1, 1, 1, 6), ...
                Token(" Lovely! ", "Comment", 1, 1, 7, 20), ...
                Token("World", "Text", 1, 1, 21, 25)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesVariables(testCase)
            lexer = matstache.Lexer();
            rawText = 'Hello {{ subject }}!';
            expected = [Token("Hello ", "Text", 1, 1, 1, 6), ...
                Token(" subject ", "Variable", 1, 1, 7, 19), ...
                Token("!", "Text", 1, 1, 20, 20)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tracksNewlines(testCase)
            lexer = matstache.Lexer();
            rawText = ['Hello ' newline ' World{{! Comment '  newline '  }}!'];
            expected = [Token(['Hello ' newline], "Text", 1, 1, 1, 7), ...
                Token(" World", "Text", 2, 2, 1, 6), ...
                Token(" Comment " + newline + "  ", "Comment", 2, 3, 7, 4), ...
                Token("!", "Text", 3, 3, 5, 5)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesSections(testCase)
            lexer = matstache.Lexer();
            rawText = 'Hello {{#person}}{{name}}{{/person}}';
            expected = [Token('Hello ', "Text", 1, 1, 1, 6), ...
                Token("person", "SectionStart", 1, 1, 7, 17), ...
                Token("name", "Variable", 1, 1, 18, 25), ...
                Token("person", "SectionEnd", 1, 1, 26, 36)
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesTripleMustache(testCase)
            lexer = matstache.Lexer();
            rawText = 'Hello {{{ name }}}';
            expected = [Token("Hello ", "Text", 1, 1, 1, 6), ...
                Token(" name ", "UnescapedVariable", 1, 1, 7, 18)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesUnescapedVariables(testCase)
            lexer = matstache.Lexer();
            rawText = 'Hello {{& name }}';
            expected = [Token("Hello ", "Text", 1, 1, 1, 6), ...
                Token(" name ", "UnescapedVariable", 1, 1, 7, 17)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function allowsSettingDelimiters(testCase)
            lexer = matstache.Lexer();
            rawText = ['[ {{include}} ]' newline '{{= | | =}}' newline '[ |include| ]'];
            expected = [Token("[ ", "Text", 1, 1, 1, 2), ...
                Token("include", "Variable", 1, 1, 3, 13), ...
                Token(" ]" + newline, "Text", 1, 1, 14, 16), ...
                Token(" | | ", "SetDelimiters", 2, 2, 1, 11), ...
                Token(newline, "Text", 2, 2, 12, 12), ...
                Token("[ ", "Text", 3, 3, 1, 2), ...
                Token("include", "Variable", 3, 3, 3, 11), ...
                Token(" ]", "Text", 3, 3, 12, 13), ...
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesPartials(testCase)
            lexer = matstache.Lexer();
            rawText = '{{> partial}}';
            expected = [Token(" partial", "Partial", 1, 1, 1, 13)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesInvertedSections(testCase)
            lexer = matstache.Lexer();
            rawText = '{{^boolean}}This should be rendered.{{/boolean}}';
            expected = [Token("boolean", "InvertedStart", 1, 1, 1, 12), ...
                Token("This should be rendered.", "Text", 1, 1, 13, 36), ...
                Token("boolean", "SectionEnd", 1, 1, 37, 48)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function errorsOnMalformedSetDelimiterTag(testCase)
            lexer = matstache.Lexer();
            % 0 delimiters
            rawText = '{{=   =}}';
            testCase.verifyError(@() lexer.tokenize(rawText), ...
                "matstache:InvalidDelimiters");
            % 1 delimiter1
            rawText = '{{= || =}}';
            testCase.verifyError(@() lexer.tokenize(rawText), ...
                "matstache:InvalidDelimiters");
            % 3 delimiters
            rawText = '{{= || << >> =}}';
            testCase.verifyError(@() lexer.tokenize(rawText), ...
                "matstache:InvalidDelimiters");
        end

        function delimitersCannotBeSetToEqualSign(testCase)
            lexer = matstache.Lexer();
            % Left
            rawText = '{{= = | =}}';
            testCase.verifyError(@() lexer.tokenize(rawText), ...
                "matstache:DelimiterCannotBeEqualSign");
            % Right
            rawText = '{{= | = =}}';
            testCase.verifyError(@() lexer.tokenize(rawText), ...
                "matstache:DelimiterCannotBeEqualSign");
            % Both
            rawText = '{{= = = =}}';
            testCase.verifyError(@() lexer.tokenize(rawText), ...
                "matstache:DelimiterCannotBeEqualSign");
        end

        function nextTokenReturnsNextToken(testCase)
            lexer = matstache.Lexer();
            rawText = 'Hello {{! Lovely! }}{{ name }}';
            lexer.setTemplate(rawText);

            expected = Token("Hello ", "Text", 1, 1, 1, 6);
            actual = lexer.nextToken();
            testCase.verifyEqual(expected, actual);

            expected = Token(" Lovely! ", "Comment", 1, 1, 7, 20);
            actual = lexer.nextToken();
            testCase.verifyEqual(expected, actual);

            expected = Token(" name ", "Variable", 1, 1, 21, 30);
            actual = lexer.nextToken();
            testCase.verifyEqual(expected, actual);
        end

        function resetCleansState(testCase)
            lexer = matstache.Lexer();
            rawText = ['Oh no! {{= | | =}} ' newline '{{! Dirty State! }}{{ bad }}'];
            lexer.setTemplate(rawText);
            lexer.nextToken();
            lexer.nextToken();
            lexer.nextToken();

            lexer.reset();            
            testCase.assertEmpty(lexer.nextToken());

            rawText = '{{ var }}!';
            lexer.setTemplate(rawText);

            expected = Token(" var ", "Variable", 1, 1, 1, 9);
            actual = lexer.nextToken();
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesUnfinishedTagsAsText(testCase)
            lexer = matstache.Lexer();
            rawText = '{{!';
            expected = Token("{{!", "Text", 1, 1, 1, 3);
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end
    end
end

function token = Token(varargin)
token = matstache.Token(varargin{:});
end