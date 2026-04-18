classdef LexerTests < matlab.unittest.TestCase
    methods (Test)
        function tokenizesEmpty(testCase)
            lexer = matstache.internal.Lexer();
            rawText = '';
            tokens = lexer.tokenize(rawText);
            testCase.verifyEmpty(tokens);
        end

        function autoConvertsStrings(testCase)
            lexer = matstache.internal.Lexer();
            rawText = "Hello World!";
            expected = Token("Hello World!", "Text", 1, 1, 1, 12, 1, 12);
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesText(testCase)
            lexer = matstache.internal.Lexer();
            rawText = 'Hello World!';
            expected = Token("Hello World!", "Text", 1, 1, 1, 12, 1, 12);
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function TokenizesComments(testCase)
            lexer = matstache.internal.Lexer();
            rawText = 'Hello {{! Lovely! }}World';
            expected = [Token("Hello ", "Text", 1, 1, 1, 6, 1, 6), ...
                Token(" Lovely! ", "Comment", 1, 1, 7, 20, 7, 20), ...
                Token("World", "Text", 1, 1, 21, 25, 21, 25)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesVariables(testCase)
            lexer = matstache.internal.Lexer();
            rawText = 'Hello {{ subject }}!';
            expected = [Token("Hello ", "Text", 1, 1, 1, 6, 1, 6), ...
                Token(" subject ", "Variable", 1, 1, 7, 19, 7, 19), ...
                Token("!", "Text", 1, 1, 20, 20, 20, 20)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tracksNewlines(testCase)
            lexer = matstache.internal.Lexer();
            rawText = ['Hello ' newline ' World{{! Comment '  newline '  }}!'];
            expected = [Token(['Hello ' newline], "Text", 1, 1, 1, 7, 1, 7), ...
                Token(" World", "Text", 2, 2, 1, 6, 8, 13), ...
                Token(" Comment " + newline + "  ", "Comment", 2, 3, 7, 4, 14, 30), ...
                Token("!", "Text", 3, 3, 5, 5, 31, 31)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesSections(testCase)
            lexer = matstache.internal.Lexer();
            rawText = 'Hello {{#person}}{{name}}{{/person}}';
            expected = [Token('Hello ', "Text", 1, 1, 1, 6, 1, 6), ...
                Token("person", "Section", 1, 1, 7, 17, 7, 17), ...
                Token("name", "Variable", 1, 1, 18, 25, 18, 25), ...
                Token("person", "EndSection", 1, 1, 26, 36, 26, 36)
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesTripleMustache(testCase)
            lexer = matstache.internal.Lexer();
            rawText = 'Hello {{{ name }}}';
            expected = [Token("Hello ", "Text", 1, 1, 1, 6, 1, 6), ...
                Token(" name ", "UnescapedVariable", 1, 1, 7, 18, 7, 18)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesUnescapedVariables(testCase)
            lexer = matstache.internal.Lexer();
            rawText = 'Hello {{& name }}';
            expected = [Token("Hello ", "Text", 1, 1, 1, 6, 1, 6), ...
                Token(" name ", "UnescapedVariable", 1, 1, 7, 17, 7, 17)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function allowsSettingDelimiters(testCase)
            lexer = matstache.internal.Lexer();
            rawText = ['[ {{include}} ]' newline '{{= | | =}}' newline '[ |include| ]'];
            expected = [Token("[ ", "Text", 1, 1, 1, 2, 1, 2), ...
                Token("include", "Variable", 1, 1, 3, 13, 3, 13), ...
                Token(" ]" + newline, "Text", 1, 1, 14, 16, 14, 16), ...
                Token(" | | ", "SetDelimiters", 2, 2, 1, 11, 17, 27, '|', '|'), ...
                Token(newline, "Text", 2, 2, 12, 12, 28, 28,  '|', '|'), ...
                Token("[ ", "Text", 3, 3, 1, 2, 29, 30,  '|', '|'), ...
                Token("include", "Variable", 3, 3, 3, 11, 31, 39,  '|', '|'), ...
                Token(" ]", "Text", 3, 3, 12, 13, 40, 41,  '|', '|'), ...
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesPartials(testCase)
            lexer = matstache.internal.Lexer();
            rawText = '{{> partial}}';
            expected = [Token(" partial", "Partial", 1, 1, 1, 13, 1, 13)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesInvertedSections(testCase)
            lexer = matstache.internal.Lexer();
            rawText = '{{^boolean}}This should be rendered.{{/boolean}}';
            expected = [Token("boolean", "Inverted", 1, 1, 1, 12, 1, 12), ...
                Token("This should be rendered.", "Text", 1, 1, 13, 36, 13, 36), ...
                Token("boolean", "EndSection", 1, 1, 37, 48, 37, 48)];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function errorsOnMalformedSetDelimiterTag(testCase)
            lexer = matstache.internal.Lexer();
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
            lexer = matstache.internal.Lexer();
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
            lexer = matstache.internal.Lexer();
            rawText = 'Hello {{! Lovely! }}{{ name }}';
            lexer.setTemplate(rawText);

            expected = Token("Hello ", "Text", 1, 1, 1, 6, 1, 6);
            actual = lexer.nextToken();
            testCase.verifyEqual(expected, actual);

            expected = Token(" Lovely! ", "Comment", 1, 1, 7, 20, 7, 20);
            actual = lexer.nextToken();
            testCase.verifyEqual(expected, actual);

            expected = Token(" name ", "Variable", 1, 1, 21, 30, 21, 30);
            actual = lexer.nextToken();
            testCase.verifyEqual(expected, actual);
        end

        function resetCleansState(testCase)
            lexer = matstache.internal.Lexer();
            rawText = ['Oh no! {{= | | =}} ' newline '{{! Dirty State! }}{{ bad }}'];
            lexer.setTemplate(rawText);
            lexer.nextToken();
            lexer.nextToken();
            lexer.nextToken();

            lexer.reset();            
            testCase.assertEmpty(lexer.nextToken());

            rawText = '{{ var }}!';
            lexer.setTemplate(rawText);

            expected = Token(" var ", "Variable", 1, 1, 1, 9, 1, 9);
            actual = lexer.nextToken();
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesUnfinishedTagsAsText(testCase)
            lexer = matstache.internal.Lexer();
            rawText = '{{!';
            expected = Token("{{!", "Text", 1, 1, 1, 3, 1, 3);
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tokenizesEmptyTagsAsVariables(testCase)
            lexer = matstache.internal.Lexer();
            rawText = 'There is {{}} an empty tag';
            expected = [Token("There is ", "Text", 1, 1, 1, 9, 1, 9), ...
                Token("", "Variable", 1, 1, 10, 13, 10, 13), ...
                Token(" an empty tag", "Text", 1, 1, 14, 26, 14, 26) ...
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end
        function tokenizesSectionEmptyTags(testCase)
            lexer = matstache.internal.Lexer();
            rawText = 'There is {{#}} an empty tag';
            expected = [Token("There is ", "Text", 1, 1, 1, 9, 1, 9), ...
                Token("", "Section", 1, 1, 10, 14, 10, 14), ...
                Token(" an empty tag", "Text", 1, 1, 15, 27, 15, 27) ...
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end
        function tokenizesEmptyTagsWithWhiteSpaceAsVariables(testCase)
            lexer = matstache.internal.Lexer();
            rawText = 'There is {{ }} an empty tag';
            expected = [Token("There is ", "Text", 1, 1, 1, 9, 1, 9), ...
                Token(" ", "Variable", 1, 1, 10, 14, 10, 14), ...
                Token(" an empty tag", "Text", 1, 1, 15, 27, 15, 27) ...
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function testChangingDelimitersBackToDefault(testCase)
            lexer = matstache.internal.Lexer();
            rawText = '{{=| |=}}|name||={{ }}=|{{name}}';
            expected = [Token("| |", "SetDelimiters", 1, 1, 1, 9, 1, 9, '|', '|'), ...
                Token("name", "Variable", 1, 1, 10, 15, 10, 15,  '|', '|'), ...
                Token("{{ }}", "SetDelimiters", 1, 1, 16, 24, 16, 24), ...
                Token("name", "Variable", 1, 1, 25, 32, 25, 32), ...
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function unclosedDelimitersTokenizeAsText(testCase)
            lexer = matstache.internal.Lexer();
            rawText = '{{';
            expected = Token("{{", "Text", 1, 1, 1, 2, 1, 2);
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tripleMustacheDoesntWorkForChangedDelimiters(testCase)
            lexer = matstache.internal.Lexer();
            rawText = '{{=| |=}}{{{ nope }}}';
            expected = [Token("| |", "SetDelimiters", 1, 1, 1, 9, 1, 9, '|', '|'), ...
                Token("{{{ nope }}}", "Text", 1, 1, 10, 21, 10, 21, '|', '|'), ...
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end

        function tripleMustacheDoesntWorkForChangedRightDelimiter(testCase)
            lexer = matstache.internal.Lexer();
            rawText = '{{={{ |=}}{{{ nope }}}';
            expected = [Token("{{ |", "SetDelimiters", 1, 1, 1, 10, 1, 10, '{{', '|'), ...
                Token("{{{ nope }}}", "Text", 1, 1, 11, 22, 11, 22, '{{', '|'), ...
            ];
            actual = lexer.tokenize(rawText);
            testCase.verifyEqual(expected, actual);
        end
    end
end

function token = Token(varargin)
token = matstache.internal.Token(varargin{:});
end