%[text] # `matstache.render`
%[text] Render a Mustache template
%%
%[text] ## Syntax
%[text] `out = matstache.render(template, context)`
%[text] `out = matstache.render(template, context, partials)`
%%
%[text] ## Inputs
%[text] - `template` (`string` scalar): The Mustache template to render
%[text] - `context` (`struct` or `matstache.Context`): Data used to resolve tags
%[text] - `partials` (`struct`, optional): A struct whose field names correspond to the names of partial tags and whose values are template strings \
%%
%[text] ## Output
%[text] - `out` (string scalar): The rendered result \
%%
%[text] ## See also
%[text] \<a href="Renderer.html"\>`matstache.Renderer`\</a\>, \<a href="Context.html"\>`matstache.Context`\</a\>

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
