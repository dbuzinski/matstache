function out = render(template, context)
arguments (Input)
    template (1,1) string
    context (1,1) struct
end
arguments (Output)
    out (1,1) string
end
import matstache.*;

lexer = Lexer();
parser = Parser();
renderer = Renderer();
ctx = Context(context);

tokens = lexer.tokenize(template);
ast = parser.parse(tokens);
out = renderer.render(ast, ctx);
end