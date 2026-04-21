%[text] # Getting Started with Matstache
%[text] Matstache is a Mustache template renderer for MATLAB.
%%
%[text] ## Quick start: render a template
%[text] Use the `matstache.render` function to render a Mustache template. It accepts a template string for the first argument and a context for the second argument.
%[text] The context is typically a `struct`, but you can also pass a `matstache.Context`.
%[text] **Variables** use `{{name}}` and are looked up from the context by name.

template = "Hello, {{name}}!";
context = struct("name", "world");

out = matstache.render(template, context);
disp(out); %[output:97961d39]
% Try a different context with the same template
context.name = "Matstache";
out = matstache.render(template, context);
disp(out); %[output:08ec932e]
%%
%[text] ## Working with structured data
%[text] Your context can be nested. Matstache supports **dot notation** for nested lookups.
template = "Name: {{user.name}} (id={{user.id}})";
context = struct("user", struct("name","Ada","id", 42));
out = matstache.render(template, context);
disp(out); %[output:359fc83f]
%%
%[text] ## Sections
%[text] **Sections** use `{{#name}} ... {{/name}}`. When `name` is *truthy* in the context, the inner template is rendered with that value pushed onto the lookup stack.
%[text] If the value is a non-scalar array or a cell array, the section is rendered once per element (iteration). Use `{{.}}` inside the section to refer to the current element.
template = "Items: {{#items}}[{{.}}]{{/items}}";
context = struct("items", ["a","b","c"]);
out = matstache.render(template, context);
disp(out); %[output:6b9a1240]
%%
%[text] ## Inverted sections
%[text] **Inverted sections** use `{{^name}} ... {{/name}}`. They render when `name` is *falsy* (for example empty, false, or zero), and are omitted when the value is truthy.
% items is empty so the inverted section will render and the regular
% section won't
template = "Items: {{^items}}(no items){{/items}}{{#items}}[{{.}}]{{/items}}";
context = struct("items", []);
out = matstache.render(template, context);
disp(out); %[output:a4e2c91b]
% items is non-empty so the inverted section won't render and the regular
% section will
template = "Items: {{^items}}(no items){{/items}}{{#items}}[{{.}}]{{/items}}";
context = struct("items", ["a","b","c"]);
out = matstache.render(template, context);
disp(out); %[output:4b67f9ca]
%%
%[text] ## Variables and escaping
%[text] `{{name}}` inserts the value of `name` with HTML-sensitive characters escaped (`&`, `"`, `<`, `>`, `'`).
%[text] **Unescaped variables** use ampersand `{{&name}}` or triple mustache `{{{name}}}`.
template = "Escaped: {{x}}  Raw: {{&x}}}";
context = struct("x", "<b>hi</b>");
out = matstache.render(template, context);
disp(out); %[output:2c91f4e6]
%%
%[text] ## Comments
%[text] **Comments** use `{{! ... }}`. They are ignored when parsing and rendering templates.

template = "Hello, {{! ignored }}{{name}}!";
context = struct("name", "world");
out = matstache.render(template, context);
disp(out); %[output:b8e50344]
%%
%[text] ## Partials
%[text] **Partials** include another template by name with `{{>partialName}}`. Pass a `struct` whose field names correspond to the names of partial tags and whose values are template strings as the argument to `matstache.render`.
%[text] Partials inherit contexts from their parent template, so variables such as `{{name}}` resolve the same way in the template and inside the partial.

template = "Hello it's {{name}}. I'm doing well. {{>signoff}}";
partials = struct("signoff", "See you soon — {{name}}");
context = struct("name", "Ada");
out = matstache.render(template, context, partials);
disp(out); %[output:5d1a9c72]
%%
%[text] ## Custom delimiters
%[text] You can change the tag delimiters with a **set delimiter** tag: `{{=OPEN CLOSE=}}`. After changing delimiters, use `OPEN` and `CLOSE` in place of `{{` and `}}` for all tags.
%[text] For example, `{{=| |=}}` sets both delimiters to `|`, so `|name|` is a variable tag and `|#items|` is a section tag. Changing delimiters is useful when `{{` would collide with another syntax.

template = "Hello, {{name}}! {{=| |=}}We love you, |name|!";
context = struct("name", "world");
out = matstache.render(template, context);
disp(out); %[output:4de5b7d0]
%%
%[text] ## Lambdas
%[text] Matstache treats function handles in the context as **lambdas**.
%[text] Lambdas can be used for variables tags and sections. The value you return is treated as template text and rendered again.
%%
%[text] ### Variable lambdas
%[text] Function handles with **no inputs** can be used as variable tags.
%[text] It should return a string scalar. The returned string will also be rendered as a Mustache template.

template = "Hello, {{name}}!";
context = struct( ...
    "first", "Grace", ...
    "last", "Hopper", ...
    "name", @() "{{first}} {{last}}");
out = matstache.render(template, context);
disp(out); %[output:3356addb]
%%
%[text] ### Section lambdas
%[text] Function handles with **one input** can be used as a section tag.
%[text] It should return a Mustache template as a string scalar.
%[text] A section lambda is a function handle that takes the section’s raw inner text as input.
%[text] Return replacement template text to be rendered in place of that section.

template = "{{#wrap}}Name: {{name}}{{/wrap}}";
context = struct( ...
    "name", "Charlie", ...
    "wrap", @(inner) "<b>" + string(inner) + "</b>");
out = matstache.render(template, context);
disp(out); %[output:6d4bc655]
%%
%[text] ## Use a `matstache.Renderer` to improve performance
%[text] `matstache.render` is a convenience function that always parses and renders templates.
%[text] If you render the same templates many times, consider using a `matstache.Renderer` instance so the parsed template is cached. This can result in huge performance increases for large templates.
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
%   data: {"layout":"inline"}
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
%[output:a4e2c91b]
%   data: {"dataType":"text","outputData":{"text":"Items: (no items)\n","truncated":false}}
%---
%[output:4b67f9ca]
%   data: {"dataType":"text","outputData":{"text":"Items: [a][b][c]\n","truncated":false}}
%---
%[output:2c91f4e6]
%   data: {"dataType":"text","outputData":{"text":"Escaped: &lt;b&gt;hi&lt;\/b&gt;  Raw: <b>hi<\/b>}\n","truncated":false}}
%---
%[output:b8e50344]
%   data: {"dataType":"text","outputData":{"text":"Hello, world!\n","truncated":false}}
%---
%[output:5d1a9c72]
%   data: {"dataType":"text","outputData":{"text":"Hello it's Ada. I'm doing well. See you soon — Ada\n","truncated":false}}
%---
%[output:4de5b7d0]
%   data: {"dataType":"text","outputData":{"text":"Hello, world! We love you, world!\n","truncated":false}}
%---
%[output:3356addb]
%   data: {"dataType":"text","outputData":{"text":"Hello, Grace Hopper!\n","truncated":false}}
%---
%[output:6d4bc655]
%   data: {"dataType":"text","outputData":{"text":"<b>Name: Charlie<\/b>\n","truncated":false}}
%---
%[output:987f47d6]
%   data: {"dataType":"text","outputData":{"text":"Renders: 2000\nNo cache: 0.794109 s\nCached:  0.110482 s\n","truncated":false}}
%---
