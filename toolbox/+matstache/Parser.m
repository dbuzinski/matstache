classdef Parser
    methods
        function ast = parse(~, tokens)
            import matstache.Node;

            ast = Node("Root", "");
            stack = {};
            current = ast;
            onNewLine = true;
            i = 0;
            while i < numel(tokens)
                i = i + 1;
                % lookahead to strip standalone whitespace
                if onNewLine
                    tokens = stripStandaloneWhiteSpace(tokens, i);
                end
                token = tokens(i);
                onNewLine = contains(token.Content, newline);
                switch token.TokenType
                    case matstache.TokenType.Text
                        current.Children(end+1) = Node("Text", token.Content);
                    case matstache.TokenType.Variable
                        varName = validateVarName(token);
                        current.Children(end+1) = Node("Variable", varName);
                    case matstache.TokenType.UnescapedVariable
                        varName = validateVarName(token);
                        current.Children(end+1) = Node("UnescapedVariable", varName);
                    case matstache.TokenType.SectionStart
                        varName = validateVarName(token);
                        stackNode = Node("Section", varName);
                        current.Children(end+1) = stackNode;
                        stack{end+1} = current;
                        current = stackNode;
                    case matstache.TokenType.SectionEnd
                        varName = validateVarName(token);
                        if ~(isequal(current.NodeType, matstache.NodeType.Section) ...
                                || isequal(current.NodeType, matstache.NodeType.InvertedSection))
                            % Todo improve
                            error("There is not a section open");
                        elseif ~strcmp(current.Content, varName)
                            % Todo improve
                            error("Mismatched sections");
                        end
                        current = stack{end};
                        stack(end) = [];
                    case matstache.TokenType.InvertedStart
                        varName = validateVarName(token);
                        stackNode = Node("InvertedSection", varName);
                        current.Children(end+1) = stackNode;
                        stack{end+1} = current;
                        current = stackNode;
                    case matstache.TokenType.Partial
                        % Todo fix
                        current.Children(end+1) = Node("Partial", token.Content);
                    case matstache.TokenType.SetDelimiters
                        % Skip
                    case matstache.TokenType.Comment
                        % Skip
                end
            end
            % Todo error on unclosed section
        end
    end
end

function tf = isStandalone(token)
% Token types to treat as standalone: 
%    SectionStart, SectionEnd, InvertedStart, Partial, SetDelimiters, Comment
% Token types that are NOT standalone:
%    Variable, UnescapedVariable
% Text tokens are standalone if they only contain whitespace
tf = ~isequal(token.TokenType, matstache.TokenType.Variable) && ...
    ~isequal(token.TokenType, matstache.TokenType.UnescapedVariable) && ...
    ~(isequal(token.TokenType, matstache.TokenType.Text) && any(~isspace(token.Content)));
end

function tokens = stripStandaloneWhiteSpace(tokens, position)
% Find the next newline from the current position
for i = position:numel(tokens)
    if contains(tokens(i).Content, newline)
        break;
    end
end
% Collect the inds and tokens for this line
inds = position:i;
line = tokens(inds);
isStandaloneLine = all(arrayfun(@(tok)isStandalone(tok), line));
if isStandaloneLine
    % Mask and remove the standalone text tokens
    textTokenMask = [line.TokenType] == matstache.TokenType.Text;
    tokens(inds(textTokenMask)) = [];
end
end

function name = validateVarName(token)
% Todo: validate and cleanup. good error for invalid.
name = strip(token.Content);
end