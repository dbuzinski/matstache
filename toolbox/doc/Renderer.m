%[text] # `matstache.Renderer`
%[text] Render Mustache templates
%[text] Use `matstache.Renderer` when you need to render templates repeatedly in order to cache parsed templates.
%%
%[text] ## Constructor
%[text] `renderer = matstache.Renderer`
%%
%[text] ## Methods
%[text] `out = renderer.render(template, context)`
%[text] `out = renderer.render(template, context, partials)`
%%
%[text] ## Inputs
%[text] - `template` (`string` scalar): The Mustache template to render
%[text] - `context` (`struct` or `matstache.Context`): Data used to resolve tags
%[text] - `partials` (`struct`, optional): A struct whose field names correspond to the names of partial tags and whose values are template strings \
%%
%[text] ## Outputs
%[text] - `out` (string scalar): The rendered result \
%%
%[text] ## See also
%[text] \<a href="render.html"\>`matstache.render`\</a\>, \<a href="Context.html"\>`matstache.Context`\</a\>

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
