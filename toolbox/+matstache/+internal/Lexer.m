classdef Lexer < handle
    properties (Access=private)
        Template (1,:) char = '';
        TemplateLength (1,1) int64 = 0;
        Token matstache.internal.Token {mustBeScalarOrEmpty} = matstache.internal.Token.empty();
        InTag (1,1) logical = false;
        InTriple (1,1) logical = false;
        InSetDelimiters (1,1) logical = false;
        IsUsingDefaultDelimiters (1,1) logical = true;
        Sigil (1,:) char = ''
        Position (1,1) int64 = 1;
        StartPosition (1,1) int64 = 1;
        StartLine (1,1) int64 = 1;
        StartColumn (1,1) int64 = 1;
        CurrentLine (1,1) int64 = 1;
        CurrentColumn (1,1) int64 = 1;
        LeftDelimiter (1,:) char = '{{';
        RightDelimiter (1,:) char = '}}';
    end

    properties (Constant, Access=private)
        DefaultLeftDelimiter = '{{';
        DefaultRightDelimiter = '}}';
        SupportedSigils = {'!', '&', '#', '/' '=', '^', '>'};
        TripleMustacheStart = '{{{';
    end

    methods
        function token = nextToken(lexer)
            if lexer.Position > lexer.TemplateLength
                token = matstache.internal.Token.empty();
                return;
            end
            while isempty(lexer.Token)
                lexer.walk();
            end
            token = lexer.Token;
            lexer.Token = matstache.internal.Token.empty();
        end

        function setTemplate(lexer, template)
            arguments
                lexer (1,1) matstache.internal.Lexer
                template (1,:) char
            end
            lexer.Template = template;
            lexer.TemplateLength = length(template);
        end

        function tokens = tokenize(lexer, template)
            arguments
                lexer (1,1) matstache.internal.Lexer
                template {mustBeTextScalar}
            end
            tokens = matstache.internal.Token.empty();
            lexer.reset();
            lexer.setTemplate(template);
            token = lexer.nextToken();
            while ~isempty(token)
                tokens(end+1) = token;
                token = lexer.nextToken();
            end
        end

        function reset(lexer)
            lexer.Template = '';
            lexer.TemplateLength = 0;
            lexer.Token = matstache.internal.Token.empty();
            lexer.InTag = false;
            lexer.InTriple = false;
            lexer.InSetDelimiters = false;
            lexer.IsUsingDefaultDelimiters = true;
            lexer.Sigil = '';
            lexer.Position = 1;
            lexer.StartPosition = 1;
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
            pos = lexer.Position;
            templateLen = lexer.TemplateLength;
            template = lexer.Template;
            if pos > templateLen
                content = template(lexer.StartPosition:lexer.Position-1);
                lexer.Token = matstache.internal.Token(content, "Text", ...
                    lexer.StartLine, lexer.CurrentLine, ...
                    lexer.StartColumn, lexer.CurrentColumn - 1);
                return;
            end

            if lexer.InTag
                if lexer.InTriple && lexer.IsUsingDefaultDelimiters
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
            offset = length(delimiter) - 1;

            % Check for triple mustache start
            if pos + 2 <= templateLen && ...
                    all(lexer.Template(pos:pos+2) == '{{{') && ...
                    lexer.IsUsingDefaultDelimiters
                % Create token for text in tag
                lexer.Token = lexer.createToken();

                lexer.StartLine = lexer.CurrentLine;
                lexer.StartColumn = lexer.CurrentColumn;
                lexer.StartPosition = lexer.Position;

                % Advance past delimiter
                lexer.Position = lexer.Position + 3;
                lexer.CurrentColumn = lexer.CurrentColumn + 3;

                % if we were in a tag, now we're not (and visa versa)
                lexer.InTriple = true;
                lexer.InTag = true;
                lexer.Sigil = '{';
            % Check for delimiter
            elseif pos + offset <= templateLen && ...
                    all(template(pos:pos+offset) == delimiter)
                % Create token if value buffer is non-empty
                if lexer.Position > lexer.StartPosition
                    lexer.Token = lexer.createToken();
                end
                
                lexer.StartLine = lexer.CurrentLine;
                lexer.StartColumn = lexer.CurrentColumn + colOffset;
                lexer.StartPosition = lexer.Position + colOffset;

                % Advance past delimiter
                delimiterLen = length(delimiter);
                lexer.Position = lexer.Position + delimiterLen;
                lexer.CurrentColumn = lexer.CurrentColumn + delimiterLen;

                % if we were in a tag, now we're not (and visa versa)
                lexer.InTag = ~lexer.InTag;
                if lexer.InTriple
                    lexer.InTriple = false;
                end
                % Set sigil for new tag
                if lexer.InTag
                    if lexer.Position <= lexer.TemplateLength && any(strcmp(lexer.Template(lexer.Position), lexer.SupportedSigils))
                        lexer.Sigil = lexer.Template(lexer.Position);
                        lexer.Position = lexer.Position + 1;
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
            % Regular char (not delimiter or sigil)
            else
                c = template(pos);
                lexer.CurrentColumn = lexer.CurrentColumn + 1;
                lexer.Position = pos + 1;
                if c == newline
                    if ~lexer.InTag
                        % Split text tokens on newlines
                        lexer.Token = lexer.createToken();
                        % Update line & column cursors
                        lexer.CurrentLine = lexer.CurrentLine + 1;
                        lexer.CurrentColumn = 1;
                        lexer.StartLine = lexer.CurrentLine;
                        lexer.StartColumn = lexer.CurrentColumn;
                        lexer.StartPosition = lexer.Position;
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
                token = matstache.internal.Token(lexer.Template(lexer.StartPosition:lexer.Position - 1), "Text", ...
                    lexer.StartLine, lexer.CurrentLine, ...
                    lexer.StartColumn, lexer.CurrentColumn - 1);
                return;
            end

            % Add one to end column for final unprocessed delimiter char and
            % one more if in a triple mustache
            colOffset = length(lexer.RightDelimiter) - 1 + int64(lexer.InTriple);
            posOffset = length(lexer.LeftDelimiter) + length(lexer.Sigil);
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
                    newDelimiters = split(strip(lexer.Template(lexer.StartPosition+posOffset:lexer.Position-1)));
                    if length(newDelimiters) ~= 2
                        error("matstache:InvalidDelimiters", "Set delimiter tag content must be any two non-whitespace sequences, separated by whitespace.");
                    elseif any(strcmp(newDelimiters, '='))
                        error("matstache:DelimiterCannotBeEqualSign", "Delimiters cannot be set to an equals sign.")
                    end
                    lexer.LeftDelimiter = newDelimiters{1};
                    lexer.RightDelimiter = newDelimiters{2};
                    lexer.IsUsingDefaultDelimiters = strcmp(newDelimiters{1}, lexer.DefaultLeftDelimiter) && ...
                        strcmp(newDelimiters{2}, lexer.DefaultRightDelimiter);
                otherwise
                    tokenType = "Variable";
            end

            token = matstache.internal.Token(lexer.Template(lexer.StartPosition + posOffset:lexer.Position-1), ...
                tokenType, ...
                lexer.StartLine, lexer.CurrentLine, ...
                lexer.StartColumn, lexer.CurrentColumn + colOffset);
        end
    end
end
