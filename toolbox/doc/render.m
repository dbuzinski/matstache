%[text] # `matstache.render`
%[text] Render a Mustache template string with a context (and optional partials).
%%
%[text] ## Syntax
%[text] `out = matstache.render(template, context)`
%[text] `out = matstache.render(template, context, partials)`
%%
%[text] ## Inputs
%[text] - `template` (`string` scalar): The Mustache template to render.
%[text] - `context` (`struct` or `matstache.Context`): Data used to resolve tags
%[text] - `partials` (`struct`, optional): A struct whose field names are partial names and whose values are template strings. \
%%
%[text] ## Output
%[text] - `out` (string scalar): The rendered result. \
%%
%[text] ## Notes
%[text] - When a function expects a `matstache.Context`, you can pass a `struct` and MATLAB will automatically convert it to a context object.
%[text] - `partials` are looked up by name (field) when the template contains `{{> partialName}}`. \
%%
%[text] ## See also
%[text] `matstache.Renderer`, `matstache.Context`

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
