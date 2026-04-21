classdef Parser < handle
    % matstache.internal.Parser is an internal class.
    
    properties
        TemplateCache (1,1) dictionary = dictionary(string([]), cell([]))
        Lexer (1,1) matstache.internal.Lexer = matstache.internal.Lexer()
    end

    methods
        function ast = parse(parser, template, options)
            arguments
                parser (1,1) matstache.internal.Parser
                template (1,1) string
                options.Delimiters (1,2) string = ["{{", "}}"]
            end
            key = "L="+options.Delimiters(1)+"R="+options.Delimiters(2)+"T="+template;
            % Use cached AST if available
            if isKey(parser.TemplateCache, key)
                ast = parser.TemplateCache{key};
                return;
            end
            % Tokenize template
            tokens = parser.Lexer.tokenize(template, Delimiters=options.Delimiters);
            
            ast = parseTokens(parser, tokens);

            % Store result in cache
            parser.TemplateCache(key) = {ast};
        end

        function ast = parseTokens(~, tokens)
            import matstache.internal.Token;

            % Create root now
            % Set it as the current root
            % Create empty stack
            current = Token.empty();
            stack = {};
            % First pass to find standalone whitespace
            standaloneMask = findStandaloneWhiteSpace(tokens);

            for i = 1:numel(tokens)
                token = tokens(i);
                switch token.TokenType
                    case matstache.internal.TokenType.Text
                        if ~standaloneMask(i)
                            current(end+1) = token;
                        end
                    case matstache.internal.TokenType.Variable
                        token.Content = makeValid(token.Content);
                        current(end+1) = token;
                    case matstache.internal.TokenType.UnescapedVariable
                        token.Content = makeValid(token.Content);
                        current(end+1) = token;
                    case matstache.internal.TokenType.Section
                        % Push current to end of stack
                        token.Content = makeValid(token.Content);
                        current(end+1) = token;
                        stack{end+1} = current;
                        % Set stack node as new current
                        current = Token.empty();
                    case matstache.internal.TokenType.EndSection
                        name = makeValid(token.Content);
                        if isempty(stack)
                            error("matstache:UnexpectedSectionClose", "Unexpected section close ''%s'' (line %d, column %d)", name, token.StartLine, token.StartColumn);
                        end
                        children = current;
                        current = stack{end};
                        current(end).Children = children;
                        stack(end) = [];
                        if ~strcmp(current(end).Content, name)
                            error("matstache:MismatchedSections", "Found mismatched section close ''%s'' for currently open section ''%s'' (line %d, column %d)", name, current.Content, token.StartLine, token.StartColumn);
                        end
                    case matstache.internal.TokenType.Inverted
                        % Push current to end of stack
                        token.Content = makeValid(token.Content);
                        current(end+1) = token;
                        stack{end+1} = current;
                        % Set stack node as new current
                        current = Token.empty();
                    case matstache.internal.TokenType.Partial
                        token.Content = makeValid(token.Content);
                        % If a partial is stadalone, add its preceeding
                        % whitespace tokens as children. We use this at
                        % render time to indent all lines of the partial.
                        if standaloneMask(i)
                            token.Children = getPreceedingWhitespace(token, tokens);
                        end
                        current(end+1) = token;
                    case matstache.internal.TokenType.SetDelimiters
                        % Skip delimiter changes
                    case matstache.internal.TokenType.Comment
                        % Skip comments
                end
            end
            % Stack should be empty after parsing, or there's an unclosed section
            if ~isempty(stack)
                unclosed = stack{end};
                error("matstache:UnclosedSection", "No closing tag found for section ''%s'' (line %d, column %d)", unclosed.Content, unclosed.StartLine, unclosed.StartColumn);
            end
            ast = current;
        end
    end
end

function tf = isStandalone(token)
% Token types to treat as standalone: 
%    Section, EndSection, Inverted, Partial, SetDelimiters, Comment
% Token types that are NOT standalone:
%    Variable, UnescapedVariable
% Text tokens are standalone if they only contain whitespace
tf = ~(token.TokenType == matstache.internal.TokenType.Variable) && ...
    ~(token.TokenType == matstache.internal.TokenType.UnescapedVariable) && ...
    ~(token.TokenType == matstache.internal.TokenType.Text && any(~isspace(token.Content)));
end

function standaloneMask = findStandaloneWhiteSpace(tokens)
standaloneMask = false(1, numel(tokens));
if isempty(tokens)
    return;
end
startLines = [tokens.StartLine];
endLines = [tokens.EndLine];
% Iterate over all lines
for i = 1:endLines(end)
    % If all tokens on the line are standalone, skip rendering text for the line
    onLine = startLines <= i & endLines >= i;
    line = tokens(onLine);
    isStandaloneLine = all(arrayfun(@isStandalone, line)) && any([line.TokenType] ~= matstache.internal.TokenType.Text);
    if isStandaloneLine
        standaloneMask = standaloneMask | onLine;
    end
end
end

function textTokens = getPreceedingWhitespace(token, tokens)
% Find the any text tokens that end on the same line/column that token starts on
lineMask = ([tokens.TokenType] == matstache.internal.TokenType.Text) & ...
    ([tokens.EndLine] == token.StartLine) & ...
    ([tokens.EndColumn] < token.StartColumn);
textTokens = tokens(lineMask);
end

function name = makeValid(content)
name = strip(content);
if name == "."
    return;
end
if ~contains(name, ".")
    name = matlab.lang.makeValidName(name);
else
    name = join(arrayfun(@matlab.lang.makeValidName, name.split(".")), ".");
end
end
