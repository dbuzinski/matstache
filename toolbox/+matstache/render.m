function out = render(template, context, partials)
arguments (Input)
    template (1,1) string
    context (1,1) matstache.Context
    partials (1,1) struct = struct()
end
arguments (Output)
    out (1,1) string
end
import matstache.*;

lexer = Lexer();
parser = Parser();
renderer = Renderer();
contextStack = matstache.internal.ContextStack(context);
tokens = lexer.tokenize(template);
ast = parser.parse(tokens);
out = renderer.render(ast, contextStack, partials);
end