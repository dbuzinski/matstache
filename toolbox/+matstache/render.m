function out = render(template, context, partials)
% render - Render a mustache template
%
%   Render a mustache template using context data and
%   partial templates.
%
%   Template Context should be specified as a struct or matstache.Context object.
%   Partials can be specified as a struct using partial names as the field
%   names and templates as values.
%
%   Example:
%
%      template = "Hello, {{name}}!";
%      context = struct("name","world");
%      out = matstache.render(template, context);
%
%   Examples: <a href="matlab:open('toolbox/examples/renderTemplates/renderTemplates.mlx')">Render Templates</a>
%
%   See also matstache.Renderer, matstache.Context

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
