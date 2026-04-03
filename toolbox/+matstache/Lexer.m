classdef Lexer < handle
    properties (Access=private)
        Template (1,:) char = '';
        Token matstache.Token {mustBeScalarOrEmpty} = matstache.Token.empty();
        ValueBuffer (1,:) char = '';
        InTag (1,1) logical = false;
        InTriple (1,1) logical = false;
        InSetDelimiters (1,1) logical = false;
        Sigil (1,:) char = ''
        StartLine (1,1) int64 = 1;
        StartColumn (1,1) int64 = 1;
        CurrentLine (1,1) int64 = 1;
        CurrentColumn (1,1) int64 = 1;
        IsStandalone (1,1) logical = true;
        LeftDelimiter (1,:) char = '{{';
        RightDelimiter (1,:) char = '}}';
    end

    properties (Constant)
        DefaultLeftDelimiter = '{{';
        DefaultRightDelimiter = '}}';
        SupportedSigils = {'!', '&', '#', '/' '=', '^', '>'};
    end

    methods
        function token = nextToken(lexer)
            if isempty(lexer.Template)
                token = matstache.Token.empty();
                return;
            end
            while isempty(lexer.Token)
                lexer.walk();
            end
            token = lexer.Token;
            lexer.Token = matstache.Token.empty();
        end

        function setTemplate(lexer, template)
            lexer.Template = template;
        end

        function tokens = tokenize(lexer, template)
            arguments
                lexer (1,1) matstache.Lexer
                template {mustBeTextScalar}
            end
            tokens = matstache.Token.empty();
            lexer.reset();
            lexer.Template = template;
            token = lexer.nextToken();
            while ~isempty(token)
                tokens(end+1) = token;
                token = lexer.nextToken();
            end
        end

        function reset(lexer)
            lexer.Template = '';
            lexer.Token = matstache.Token.empty();
            lexer.ValueBuffer = '';
            lexer.InTag = false;
            lexer.InTriple = false;
            lexer.InSetDelimiters = false;
            lexer.Sigil = '';
            lexer.LeftDelimiter = lexer.DefaultLeftDelimiter;
            lexer.RightDelimiter = lexer.DefaultRightDelimiter;
            lexer.StartLine = 1;
            lexer.StartColumn = 1;
            lexer.CurrentLine = 1;
            lexer.CurrentColumn = 1;
        end
    end

    methods (Access=private)
        function walk(lexer)
            if isempty(lexer.Template)
                lexer.Token = lexer.createToken();
                return;
            end

            % Boolean to track if delimiters are defaults
            % Needed because we do not support triple mustache if
            % delimiters are changed
            defaultDelimiters = strcmp(lexer.LeftDelimiter, lexer.DefaultLeftDelimiter) && ...
                    strcmp(lexer.RightDelimiter, lexer.DefaultRightDelimiter);

            if lexer.InTag
                if lexer.InTriple && defaultDelimiters
                    delimiter = '}}}';
                    colOffset = 3;
                elseif lexer.InSetDelimiters
                    delimiter = '=}}';
                    colOffset = 3;
                else
                    delimiter = lexer.RightDelimiter;
                    colOffset = length(delimiter);
                end
            else
                delimiter = lexer.LeftDelimiter;
                colOffset = 0;
            end

            if ~lexer.InTag && startsWith(lexer.Template, '{{{') && defaultDelimiters
                % Create token for text in tag
                lexer.Token = lexer.createToken();

                lexer.StartLine = lexer.CurrentLine;
                lexer.StartColumn = lexer.CurrentColumn;

                % Advance past delimiter
                lexer.Template(1:3) = [];
                lexer.CurrentColumn = lexer.CurrentColumn + 3;

                % if we were in a tag, now we're not (and visa versa)
                lexer.InTriple = true;
                lexer.InTag = true;
                lexer.Sigil = '{';
            elseif startsWith(lexer.Template, delimiter)
                delimiterLen = length(delimiter);

                % Create token if value buffer is non-empty
                if ~isempty(lexer.ValueBuffer)
                    lexer.Token = lexer.createToken();
                end
                
                lexer.StartLine = lexer.CurrentLine;
                lexer.StartColumn = lexer.CurrentColumn + colOffset;

                % Advance past delimiter
                lexer.Template(1:delimiterLen) = [];
                lexer.CurrentColumn = lexer.CurrentColumn + delimiterLen;

                % if we were in a tag, now we're not (and visa versa)
                lexer.InTag = ~lexer.InTag;
                if lexer.InTriple
                    lexer.InTriple = false;
                end
                % Set sigil for new tag
                if lexer.InTag
                    if startsWith(lexer.Template, lexer.SupportedSigils)
                        lexer.Sigil = lexer.Template(1);
                        lexer.Template(1) = [];
                        lexer.CurrentColumn = lexer.CurrentColumn + 1;
                        if lexer.Sigil == '='
                            lexer.InSetDelimiters = true;
                        end
                    else
                        lexer.Sigil = '';
                    end
                else
                    lexer.Sigil = '';
                end
            else
                % Tokenizing regular char (not delimiter or sigil)
                c = lexer.Template(1);
                lexer.ValueBuffer(end+1) = lexer.Template(1);
                lexer.CurrentColumn = lexer.CurrentColumn + 1;
                lexer.Template(1) = [];
                if c == newline
                    if ~lexer.InTag
                        % Split text tokens on newlines
                        lexer.Token = lexer.createToken();
                        % Update line & column cursors
                        lexer.CurrentLine = lexer.CurrentLine + 1;
                        lexer.CurrentColumn = 1;
                        lexer.StartLine = lexer.CurrentLine;
                        lexer.StartColumn = lexer.CurrentColumn;
                    else
                        % No new line, walk one column
                        lexer.CurrentLine = lexer.CurrentLine + 1;
                        lexer.CurrentColumn = 1;
                    end
                end
            end
        end

        function token = createToken(lexer)
            if ~lexer.InTag && ~lexer.InTriple
                token = matstache.Token(lexer.ValueBuffer, "Text", ...
                    lexer.StartLine, lexer.CurrentLine, ...
                    lexer.StartColumn, lexer.CurrentColumn - 1);
                lexer.ValueBuffer = '';
                return;
            end

            % Add one to end column for final unprocessed delimiter char and
            % one more if in a triple mustache
            colOffset = length(lexer.RightDelimiter) - 1 + int64(lexer.InTriple);
            switch lexer.Sigil
                case '!'
                    tokenType = "Comment";
                case '&'
                    tokenType = "UnescapedVariable";
                case '{'
                    tokenType = "UnescapedVariable";
                case '#'
                    tokenType = "SectionStart";
                case '/'
                    tokenType = "SectionEnd";
                case '^'
                    tokenType = "InvertedStart";
                case '>'
                    tokenType = "Partial";
                case '='
                    tokenType = "SetDelimiters";
                    lexer.InSetDelimiters = false;
                    colOffset = colOffset + 1;
                    newDelimiters = split(strip(lexer.ValueBuffer));
                    if length(newDelimiters) ~= 2
                        error("matstache:InvalidDelimiters", "Set delimiter tag content must be any two non-whitespace sequences, separated by whitespace.");
                    elseif any(strcmp(newDelimiters, '='))
                        error("matstache:DelimiterCannotBeEqualSign", "Delimiters cannot be set to an equals sign.")
                    end
                    lexer.LeftDelimiter = newDelimiters{1};
                    lexer.RightDelimiter = newDelimiters{2};
                otherwise
                    tokenType = "Variable";
            end

            token = matstache.Token(lexer.ValueBuffer, tokenType, ...
                lexer.StartLine, lexer.CurrentLine, ...
                lexer.StartColumn, lexer.CurrentColumn + colOffset);
            lexer.ValueBuffer = '';
        end
    end
end
