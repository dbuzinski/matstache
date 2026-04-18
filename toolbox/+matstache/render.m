function out = render(template, context, partials)
% render - Render Mustache template to output string
%
%   This MATLAB function renders a template string using context data and
%   optional named partial templates. Rendering uses a default
%   matstache.Renderer object.
%
%   Field names of the partials struct are partial names referenced in the
%   template. When you omit partials, use an empty struct with no fields.
%
%   Example:
%
%      tpl = "Hello, {{name}}!";
%      ctx = struct("name","world");
%      out = matstache.render(tpl, ctx);
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
