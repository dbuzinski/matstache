%[text] # `matstache.Renderer`
%[text] Parse and render Mustache template strings using a context (and optional partials).
%[text] Use `matstache.Renderer` when you need to render templates repeatedly and want to reuse internal parsing work.
%%
%[text] ## Constructor
%[text] `renderer = matstache.Renderer`
%%
%[text] ## Method
%[text] `out = renderer.render(template, context)`
%[text] `out = renderer.render(template, context, partials)`
%%
%[text] ## Inputs
%[text] - `template` (`string` scalar): The Mustache template to render.
%[text] - `context` (`struct` or `matstache.Context`): Data used to resolve tags
%[text] - `partials` (`struct`, optional): A struct whose field names are partial names and whose values are template strings. \
%%
%[text] ## Output
%[text] - `out` (string scalar): The rendered result. \

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
