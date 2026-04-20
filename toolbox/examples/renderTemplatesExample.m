%[text] # Rendering Templates
%[text] ## Render your first template
%[text] Create a template with a variable tag `name` that gets interpolated from the given context. Try changing the value for `name` and see what happens.
% Define a template
template = "Hello {{name}}!";

% Define a context
context = struct("name", "world");

% Render the template
out = matstache.render(template, context);
disp(out);

% Try with a different context
context = struct("name", "matstache");

% Re-render the template
out = matstache.render(template, context);
disp(out);
%[text] ### Rendering templates from files
%[text] You can load templates from files using `fileread`. You can also load context from files using `fileread` and `jsondecode`.
% Load a template from the file views/page.mustache
template = fileread(fullfile("views", "page.mustache"));

% Load data from the file data/pageData.json
context = jsondecode(fileread(fullfile("data", "pageData.json")));

% Render the page
out = matstache.render(template, context);
disp(out);
%%
%[text] ## Improve performance by caching
% Instantiate a renderer for reuse
renderer = matstache.Renderer;

% Load a large template
template = fileread("views/largeTemplate.mustache");

% Load a context from json
context = jsondecode(fileread(fullfile("data", "largeData.json")));

% Render 100 times without caching
tic
for i = 1:100
    matstache.render(template, context);
end
t = toc;
fprintf("100 renders without caching: %fs.\n", t);

% Render 100 times with caching
tic
for i = 1:100
    renderer.render(template, context);
end
t = toc;
fprintf("100 renders with caching: %fs.\n", t);


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
