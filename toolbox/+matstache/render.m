function out = render(template, hash)
arguments (Input)
    template (1,1) string
    hash
end
arguments (Output)
    out (1,1) string
end
import matstache.*;

lexer = Lexer();
parser = Parser();
renderer = Renderer();
ctx = Context(hash);

tokens = lexer.tokenize(template);
ast = parser.parse(tokens);
out = renderer.render(ast, ctx);
end