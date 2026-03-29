classdef Lexer < handle
    properties (Access=private)
        Template (1,:) char = '';
        Tokens (1,:) matstache.Token = matstache.Token.empty();
        ValueBuffer (1,:) char = '';
        InTag (1,1) logical = false;
        Sigil (1,:) char = ''
        LeftDelimiter (1,:) char = '{{';
        RightDelimiter (1,:) char = '}}';
    end

    properties (Constant)
        DefaultLeftDelimiter = '{{';
        DefaultRightDelimiter = '}}';
        SupportedSigils = {'!'};
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
            if tokenizer.InTag
                delimiter = tokenizer.RightDelimiter;
            else
                delimiter = tokenizer.LeftDelimiter;
            end

            if startsWith(tokenizer.Template, delimiter) || isempty(tokenizer.Template)
                % Create token for text in tag
                tokenizer.Tokens(end+1) = tokenizer.createToken();

                % if we were in a tag, now we're not (and visa versa)
                tokenizer.InTag = ~tokenizer.InTag;

                % Advance past delimiter and start the next block
                tokenizer.Template(1:2) = [];
                % Set sigil for new tag
                if tokenizer.InTag
                    if startsWith(tokenizer.Template, tokenizer.SupportedSigils)
                        tokenizer.Sigil = tokenizer.Template(1);
                        tokenizer.Template(1) = [];
                    else
                        tokenizer.Sigil = '';
                    end
                else
                    tokenizer.Sigil = '';
                end
            else
                tokenizer.ValueBuffer(end+1) = tokenizer.Template(1);
                tokenizer.Template(1) = [];
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
        end

        function token = createToken(tokenizer)
            if ~tokenizer.InTag
                token = matstache.Token(tokenizer.ValueBuffer, "Text");
                tokenizer.ValueBuffer = [];
                return
            end
            switch tokenizer.Sigil
                case '!'
                    token = matstache.Token(tokenizer.ValueBuffer, "Comment");
                otherwise
                    token = matstache.Token(tokenizer.ValueBuffer, "Variable");
            end
            tokenizer.ValueBuffer = [];
        end
    end
end
