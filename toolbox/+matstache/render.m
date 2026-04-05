function out = render(template, context, partials)
arguments (Input)
    template (1,1) string
    context
    partials (1,1) struct = struct()
end
arguments (Output)
    out (1,1) string
end
import matstache.*;

lexer = Lexer();
parser = Parser();
renderer = Renderer();
if ~isa(context, "matstache.Context")
    ctx = Context(context);
else
    ctx = context;
end
tokens = lexer.tokenize(template);
ast = parser.parse(tokens);
out = renderer.render(ast, ctx, partials);
end