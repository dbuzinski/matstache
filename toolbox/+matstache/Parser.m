classdef Parser
    methods
        function ast = parse(~, tokens)
            import matstache.Node;

            % Create root now
            % Set it as the current root
            % Create empty stack
            ast = Node("Root", "");
            current.Node = ast;
            current.StartLine = 0;
            current.StartColumn = 0;
            stack = {current};
            % First pass to find standalone whitespace
            standaloneMask = findStandaloneWhiteSpace(tokens);

            for i = 1:numel(tokens)
                token = tokens(i);
                switch token.TokenType
                    case matstache.TokenType.Text
                        if ~standaloneMask(i)
                            current.Node.Children(end+1) = Node("Text", token.Content);
                        end
                    case matstache.TokenType.Variable
                        varName = validateVarName(token);
                        current.Node.Children(end+1) = Node("Variable", varName);
                    case matstache.TokenType.UnescapedVariable
                        varName = validateVarName(token);
                        current.Node.Children(end+1) = Node("UnescapedVariable", varName);
                    case matstache.TokenType.SectionStart
                        varName = validateVarName(token);
                        stackNode = Node("Section", varName);
                        % Add stack to current children
                        current.Node.Children(end+1) = stackNode;
                        % Set stack node to current
                        current.Node = stackNode;
                        current.StartLine = token.StartLine;
                        current.StartColumn = token.StartColumn;
                        stack{end+1} = current;
                    case matstache.TokenType.SectionEnd
                        varName = validateVarName(token);
                        if ~(isequal(current.Node.NodeType, matstache.NodeType.Section) ...
                                || isequal(current.Node.NodeType, matstache.NodeType.InvertedSection))
                            error("matstache:UnexpectedSectionClose", "Unexpected section close ''%s'' (line %d, column %d)", varName, token.StartLine, token.StartColumn);
                        elseif ~strcmp(current.Node.Content, varName)
                            error("matstache:MismatchedSections", "Found mismatched section close ''%s'' for currently open section ''%s'' (line %d, column %d)", varName, current.Node.Content, token.StartLine, token.StartColumn);
                        end
                        stack(end) = [];
                        current = stack{end};
                    case matstache.TokenType.InvertedStart
                        varName = validateVarName(token);
                        stackNode = Node("InvertedSection", varName);
                        % Add stack to current children
                        current.Node.Children(end+1) = stackNode;
                        % Set stack node to current
                        current.Node = stackNode;
                        current.StartLine = token.StartLine;
                        current.StartColumn = token.StartColumn;
                        stack{end+1} = current;
                    case matstache.TokenType.Partial
                        varName = validateVarName(token);
                        current.Node.Children(end+1) = Node("Partial", varName);
                    case matstache.TokenType.SetDelimiters
                        % Skip delimiter changes
                    case matstache.TokenType.Comment
                        % Skip comments
                end
            end
            % Only root node should be left in the stack
            if ~isscalar(stack)
                unclosed = stack{end};
                error("matstache:UnclosedSection", "No closing tag found for section ''%s'' (line %d, column %d)", unclosed.Node.Content, unclosed.StartLine, unclosed.StartColumn);
            end
        end
    end
end

function tf = isStandalone(token)
% Token types to treat as standalone: 
%    SectionStart, SectionEnd, InvertedStart, Partial, SetDelimiters, Comment
% Token types that are NOT standalone:
%    Variable, UnescapedVariable
% Text tokens are standalone if they only contain whitespace
tf = ~(token.TokenType == matstache.TokenType.Variable) && ...
    ~(token.TokenType == matstache.TokenType.UnescapedVariable) && ...
    ~(token.TokenType == matstache.TokenType.Text && any(~isspace(token.Content)));
end

function standaloneMask = findStandaloneWhiteSpace(tokens)
startLines = [tokens.StartLine];
endLines = [tokens.EndLine];
standaloneMask = false(1, numel(tokens));
% Iterate over all lines
for i = 1:tokens(end).EndLine
    % If all tokens on the line are standalone, skip rendering text for the line
    onLine = startLines <= i & endLines >= i;
    line = tokens(onLine);
    isStandaloneLine = all(arrayfun(@isStandalone, line)) && any([line.TokenType] ~= matstache.TokenType.Text);
    if isStandaloneLine
        standaloneMask = standaloneMask | onLine;
    end
end
end

function name = validateVarName(token)
name = strip(token.Content);
if isequal(name, ".")
    return;
end
isValid = all(arrayfun(@isvarname,name.split(".")));
if ~isValid
    msg = "Invalid variable name ''%s'' (line %d, column %d)";
    error("matstache:InvalidVariableName", msg, name, token.StartLine, token.StartColumn);
end
end