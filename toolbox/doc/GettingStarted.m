%[text] # Getting Started with Matstache
%[text] Matstache is a Mustache template renderer for MATLAB.
%%
%[text] ## Quick start: render a template
%[text] Use `matstache.render(template, context)` to interpolate tags like `{{name}}`.
%[text] The context is typically a `struct`, but you can also pass a `matstache.Context` (or a subclass).

template = "Hello, {{name}}!";
context = struct("name", "world");

out = matstache.render(template, context);
disp(out); %[output:97961d39]

% Try a different context
context.name = "Matstache";
disp(matstache.render(template, context)); %[output:08ec932e]
%%
%[text] ## Working with structured data
%[text] Your context can be nested. Matstache supports **dot notation** for nested lookups.
%[text] Use `{{.}}` to refer to the “current” context element when iterating.

template = "Name: {{user.name}} (id={{user.id}})";
context = struct("user", struct("name","Ada","id", 42));
disp(matstache.render(template, context)); %[output:359fc83f]

template = "Items: {{#items}}[{{.}}]{{/items}}";
context = struct("items", ["a","b","c"]);
disp(matstache.render(template, context)); %[output:6b9a1240]
%%
%[text] ## Lambdas
%[text] Matstache treats function handles in the context as **lambdas**.
%[text] Lambdas can be used for variables and sections. The value you return is treated as template text and rendered again.
%%
%[text] ### Variable lambdas
%[text] A variable lambda is a function handle with **no inputs**.
%[text] It should return text (string/char) and may itself contain Mustache tags.

template = "Hello, {{name}}!";
context = struct( ...
    "first", "Grace", ...
    "last", "Hopper", ...
    "name", @() "{{first}} {{last}}");

disp(matstache.render(template, context)); %[output:3356addb]
%%
%[text] ### Section lambdas
%[text] A section lambda is a function handle that takes the section’s raw inner text as input.
%[text] Return replacement template text to be rendered in place of that section.

template = "{{#wrap}}Name: {{name}}{{/wrap}}";
context = struct( ...
    "name", "Charlie", ...
    "wrap", @(inner) "<b>" + string(inner) + "</b>");

disp(matstache.render(template, context)); %[output:6d4bc655]
%%
%[text] ## Use a `matstache.Renderer` to improve performance
%[text] `matstache.render` is a convenience function that always parses and renders templates.
%[text] If you render the same templates many times, consider using a `matstache.Renderer` instance so the parsed template is cached. This can result in huge increases in performance for large templates.
renderer = matstache.Renderer;
template = "Hello {{name}}!";
context = struct("name","world");

n = 2000;

% Without caching
tic
for i = 1:n
    matstache.render(template, context);
end
tNoCache = toc;

% With caching
tic
for i = 1:n
    renderer.render(template, context);
end
tCache = toc;

fprintf("Renders: %d\nNo cache: %g s\nCached:  %g s\n", n, tNoCache, tCache); %[output:987f47d6]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:97961d39]
%   data: {"dataType":"text","outputData":{"text":"Hello, world!\n","truncated":false}}
%---
%[output:08ec932e]
%   data: {"dataType":"text","outputData":{"text":"Hello, Matstache!\n","truncated":false}}
%---
%[output:359fc83f]
%   data: {"dataType":"text","outputData":{"text":"Name: Ada (id=42)\n","truncated":false}}
%---
%[output:6b9a1240]
%   data: {"dataType":"text","outputData":{"text":"Items: [a][b][c]\n","truncated":false}}
%---
%[output:3356addb]
%   data: {"dataType":"text","outputData":{"text":"Hello, Grace Hopper!\n","truncated":false}}
%---
%[output:6d4bc655]
%   data: {"dataType":"text","outputData":{"text":"<b>Name: Charlie<\/b>\n","truncated":false}}
%---
%[output:987f47d6]
%   data: {"dataType":"text","outputData":{"text":"Renders: 2000\nNo cache: 0.636242 s\nCached:  0.137671 s\n","truncated":false}}
%---
