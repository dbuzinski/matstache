classdef ParserTests < matlab.unittest.TestCase
    methods (Test)
        function parsesRegularText(testCase)
            template = 'Hello world';
            parser = Parser();
            ast = parser.parse(template);
            expected = Token("Hello world", "Text", 1, 1, 1, 11);
            testCase.verifyEqual(expected, ast);
        end

        function parsesVariables(testCase)
            template = '{{ name }}';
            parser = Parser();
            ast = parser.parse(template);
            expected = Token("name", "Variable", 1, 1, 1, 10);
            testCase.verifyEqual(expected, ast);
        end

        function parsesUnescapedVariables(testCase)
            template = '{{& name }}';
            parser = Parser();
            ast = parser.parse(template);
            expected = Token("name", "UnescapedVariable", 1, 1, 1, 11);
            testCase.verifyEqual(expected, ast);
        end

        function parsesSections(testCase)
            template = '{{# employee }}{{ name }}{{/ employee }}';
            parser = Parser();
            ast = parser.parse(template);

            expected = Token("employee", "Section", 1, 1, 1, 15);
            expected.Children = Token("name", "Variable", 1, 1, 16, 25);

            testCase.verifyEqual(expected, ast);
        end

        function parsesInvertedSections(testCase)
            template = '{{^ employee }}{{ name }}{{/ employee }}';
            parser = Parser();
            ast = parser.parse(template);

            expected = Token("employee", "Inverted", 1, 1, 1, 15);
            expected.Children = Token("name", "Variable", 1, 1, 16, 25);
            
            testCase.verifyEqual(expected, ast);
        end

        function ignoresSetDelimiterTokens(testCase)
            template = '{{=|| ||=}}|| name ||';
            parser = Parser();
            ast = parser.parse(template);
            expected = Token("name", "Variable", 1, 1, 12, 21);
            testCase.verifyEqual(expected, ast);
        end

        function ignoresComments(testCase)
            template = 'Hello{{! invisible! }}';
            parser = Parser();
            ast = parser.parse(template);
            expected = Token("Hello", "Text", 1, 1, 1, 5);
            testCase.verifyEqual(expected, ast);
        end

        function standaloneTextBeforeSectionIsNotAddedToAST(testCase)
            template = ['    {{# employee }}' newline '{{ name }}' newline '{{/ employee }}'];
            parser = Parser();
            ast = parser.parse(template);

            expected = Token("employee", "Section", 1, 1, 5, 19);
            expected.Children = [ Token("name", "Variable", 2, 2, 1, 10) ...
                Token(newline, "Text", 2, 2, 11, 11)];
            
            testCase.verifyEqual(expected, ast);
        end

        function standaloneTextBeforeInvertedIsNotAddedToAST(testCase)
            template = ['    {{^ employee }}' newline '{{ name }}' newline '{{/ employee }}'];
            parser = Parser();
            ast = parser.parse(template);

            expected = Token("employee", "Inverted", 1, 1, 5, 19);
            expected.Children = [ Token("name", "Variable", 2, 2, 1, 10) ...
                Token(newline, "Text", 2, 2, 11, 11)];
            
            testCase.verifyEqual(expected, ast);
        end

        function standaloneTextBeforeEndSectionIsNotAddedToAST(testCase)
            template = ['{{# employee }}' newline '{{ name }}' newline '    {{/ employee }}'];
            parser = Parser();
            ast = parser.parse(template);

            expected = Token("employee", "Section", 1, 1, 1, 15);
            expected.Children = [ Token("name", "Variable", 2, 2, 1, 10) ...
                Token(newline, "Text", 2, 2, 11, 11)];
            
            testCase.verifyEqual(expected, ast);
        end

        function standaloneTextBeforePartialAreAddedAsChildren(testCase)
            template = '    {{> post }}';
            parser = Parser();
            ast = parser.parse(template);

            expected = Token("post", "Partial", 1, 1, 5, 15);
            expected.Children = Token("    ", "Text", 1, 1, 1, 4);

            testCase.verifyEqual(expected, ast);
        end

        function makesNamesValid(testCase)
            template = '{{ snake-case }}';
            parser = Parser();
            ast = parser.parse(template);

            expected = Token("snake_case", "Variable", 1, 1, 1, 16);

            testCase.verifyEqual(expected, ast);
        end

        function parsesPeriod(testCase)
            template = '{{ . }}';
            parser = Parser();
            ast = parser.parse(template);

            expected = Token(".", "Variable", 1, 1, 1, 7);

            testCase.verifyEqual(expected, ast);
        end

        function makesNestedNamesValid(testCase)
            template = '{{ snake-1.snake-2 }}';
            parser = Parser();
            ast = parser.parse(template);

            expected = Token("snake_1.snake_2", "Variable", 1, 1, 1, 21);

            testCase.verifyEqual(expected, ast);
        end

        function storesParsedTemplatesInCache(testCase)
            template = 'Hello world';
            parser = Parser();
            % Cache should be empty before any parsing
            testCase.assertEmpty(parser.TemplateCache.keys());

            ast = parser.parse(template);

            % Template is added to the cache
            testCase.verifyTrue(isKey(parser.TemplateCache, template));

            % Cache resolves to expected value
            cached = parser.TemplateCache(template);
            testCase.verifyEqual(cached{1}, ast);
        end

        function retrievesKnownTemplatesFromCache(testCase)
            template = 'known';
            expected = Token("Cache hit", "Text", 1, 1, 1, 9);

            parser = Parser();
            parser.TemplateCache(template) = {expected};
            ast = parser.parse(template);

            testCase.verifyEqual(expected, ast);
        end

        function errorsIfEndSectionWithNoSectionOpen(testCase)
            template = '{{/ Bang }}';
            parser = Parser();

            testCase.verifyError(@()parser.parse(template), "matstache:UnexpectedSectionClose");
        end

        function errorsIfEndSectionWithSectionMismatch(testCase)
            template = '{{# Hello }}Bang{{/ Goodbye }}';
            parser = Parser();
            
            testCase.verifyError(@()parser.parse(template), "matstache:MismatchedSections");
        end

        function errorsIfSectionIsOpenAtEndOfFile(testCase)
            template = '{{# Bang }}';
            parser = Parser();

            testCase.verifyError(@()parser.parse(template), "matstache:UnclosedSection");
        end
    end
end

function token = Token(varargin)
token = matstache.internal.Token(varargin{:});
end

function token = Parser(varargin)
token = matstache.internal.Parser(varargin{:});
end