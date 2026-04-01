classdef Lexer < handle
    % properties (Access=private)
    properties
        Template (1,:) char = '';
        Tokens (1,:) matstache.Token = matstache.Token.empty();
        ValueBuffer (1,:) char = '';
        InTag (1,1) logical = false;
        InTriple (1,1) logical = false;
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
        SupportedSigils = {'!', '&', '#', '/'};
    end

    methods
        function tokens = tokenize(tokenizer, template)
            arguments
                tokenizer (1,1) matstache.Lexer
                template {mustBeTextScalar}
            end
            tokenizer.reset();
            tokenizer.Template = template; 
            while ~isempty(tokenizer.Template)
                tokenizer.walk();
            end
            if ~isempty(tokenizer.ValueBuffer)
                tokenizer.Tokens(end+1) = tokenizer.createToken();
            end
            tokens = tokenizer.Tokens;
        end
    end

    methods (Access=private)
        function walk(tokenizer)
            defaultDelimiters = strcmp(tokenizer.LeftDelimiter, tokenizer.DefaultLeftDelimiter) && ...
                    strcmp(tokenizer.RightDelimiter, tokenizer.DefaultRightDelimiter);

            if tokenizer.InTag
                if tokenizer.InTriple && defaultDelimiters
                    delimiter = '}}}';
                    colOffset = 3;
                else
                    delimiter = tokenizer.RightDelimiter;
                    colOffset = 2;
                end
            else
                delimiter = tokenizer.LeftDelimiter;
                colOffset = 0;
            end

            if startsWith(tokenizer.Template, '{{{') && defaultDelimiters
                % Create token for text in tag
                tokenizer.Tokens(end+1) = tokenizer.createToken();

                tokenizer.StartLine = tokenizer.CurrentLine;
                tokenizer.StartColumn = tokenizer.CurrentColumn;

                % Advance past delimiter
                tokenizer.Template(1:3) = [];
                tokenizer.CurrentColumn = tokenizer.CurrentColumn + 3;

                % if we were in a tag, now we're not (and visa versa)
                tokenizer.InTriple = true;
                tokenizer.InTag = true;
                tokenizer.Sigil = '{';
            elseif startsWith(tokenizer.Template, delimiter)
                delimiterLen = length(delimiter);

                % Create token for text in tag
                tokenizer.Tokens(end+1) = tokenizer.createToken();

                tokenizer.StartLine = tokenizer.CurrentLine;
                tokenizer.StartColumn = tokenizer.CurrentColumn + colOffset;

                % Advance past delimiter
                tokenizer.Template(1:delimiterLen) = [];
                tokenizer.CurrentColumn = tokenizer.CurrentColumn + delimiterLen;

                % if we were in a tag, now we're not (and visa versa)
                tokenizer.InTag = ~tokenizer.InTag;
                if tokenizer.InTriple
                    tokenizer.InTriple = false;
                end
                % Set sigil for new tag
                if tokenizer.InTag
                    if startsWith(tokenizer.Template, tokenizer.SupportedSigils)
                        tokenizer.Sigil = tokenizer.Template(1);
                        tokenizer.Template(1) = [];
                        tokenizer.CurrentColumn = tokenizer.CurrentColumn + 1;
                    else
                        tokenizer.Sigil = '';
                    end
                else
                    tokenizer.Sigil = '';
                end
            else
                c = tokenizer.Template(1);
                tokenizer.ValueBuffer(end+1) = tokenizer.Template(1);
                tokenizer.CurrentColumn = tokenizer.CurrentColumn + 1;
                tokenizer.Template(1) = [];
                if c == newline
                    if ~tokenizer.InTag
                        tokenizer.Tokens(end+1) = tokenizer.createToken();
                        tokenizer.CurrentLine = tokenizer.CurrentLine + 1;
                        tokenizer.CurrentColumn = 1;
                        tokenizer.StartLine = tokenizer.CurrentLine;
                        tokenizer.StartColumn = tokenizer.CurrentColumn;
                    else
                        tokenizer.CurrentLine = tokenizer.CurrentLine + 1;
                        tokenizer.CurrentColumn = 1;
                    end
                end
            end
        end

        function reset(tokenizer)
            tokenizer.Template = '';
            tokenizer.Tokens = matstache.Token.empty();
            tokenizer.ValueBuffer = '';
            tokenizer.InTag = false;
            tokenizer.Sigil = '';
            tokenizer.LeftDelimiter = '{{';
            tokenizer.RightDelimiter = '}}';
            tokenizer.StartLine = 1;
            tokenizer.StartColumn = 1;
            tokenizer.CurrentLine = 1;
            tokenizer.CurrentColumn = 1;
        end

        function token = createToken(tokenizer)
            if ~tokenizer.InTag && ~tokenizer.InTriple
                token = matstache.Token(tokenizer.ValueBuffer, "Text", ...
                    tokenizer.StartLine, tokenizer.CurrentLine, ...
                    tokenizer.StartColumn, tokenizer.CurrentColumn - 1);
                tokenizer.ValueBuffer = [];
                return
            end

            switch tokenizer.Sigil
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
                otherwise
                    tokenType = "Variable";
            end

            token = matstache.Token(tokenizer.ValueBuffer, tokenType, ...
                tokenizer.StartLine, tokenizer.CurrentLine, ...
                tokenizer.StartColumn, tokenizer.CurrentColumn + 1);
            tokenizer.ValueBuffer = [];
        end
    end
end
