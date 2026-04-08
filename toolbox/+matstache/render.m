function out = render(template, context, partials)
arguments (Input)
    template (1,1) string
    context (1,1) matstache.Context
    partials (1,1) struct = struct()
end
arguments (Output)
    out (1,1) string
end
renderer = matstache.Renderer;
out = renderer.render(template, context, partials);
end