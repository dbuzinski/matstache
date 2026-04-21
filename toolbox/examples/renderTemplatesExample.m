%[text] # Rendering Templates
%[text] ## Render your first template
%[text] Create a template with a variable tag `name` that gets interpolated from the given context. Try changing the value for `name` and see what happens.
% Define a template
template = "Hello {{name}}!";

% Define a context
context = struct("name", "world");

% Render the template
out = matstache.render(template, context);
disp(out); %[output:10c8a403]
% Try with a different context
context = struct("name", "matstache");

% Re-render the template
out = matstache.render(template, context);
disp(out); %[output:941e0588]
%[text] ### Rendering templates from files
%[text] You can load templates from files using `fileread`. You can also load context from files using `fileread` and `jsondecode`.
% Load a template from the file views/page.mustache
template = fileread(fullfile("views", "page.mustache"));
disp(template); %[output:5da2f63a]
% Load data from the file data/pageData.json
context = jsondecode(fileread(fullfile("data", "pageData.json")));
disp(context); %[output:3c1d9941]
% Render the page
out = matstache.render(template, context);
disp(out); %[output:969db132]
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

fprintf("Renders: %d\nNo cache: %g s\nCached:  %g s\n", n, tNoCache, tCache); %[output:4a91e33a]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40}
%---
%[output:10c8a403]
%   data: {"dataType":"text","outputData":{"text":"Hello world!\n","truncated":false}}
%---
%[output:941e0588]
%   data: {"dataType":"text","outputData":{"text":"Hello matstache!\n","truncated":false}}
%---
%[output:5da2f63a]
%   data: {"dataType":"text","outputData":{"text":"<h1>{{ title }}<\/h1>\n<div>\n    <h2>{{ username }}<\/h2>\n    <div>\n        <h3>Interests<\/h3>\n        <p>Likes: {{ likes }}.<\/p>\n        <p>Dislikes: {{ dislikes }}.<\/p>\n    <\/div>\n<\/div>\n","truncated":false}}
%---
%[output:3c1d9941]
%   data: {"dataType":"text","outputData":{"text":"       title: 'Profile'\n    username: 'Charlie'\n       likes: 'Milk steak, ghouls'\n    dislikes: 'Peoples' knees'\n\n","truncated":false}}
%---
%[output:969db132]
%   data: {"dataType":"text","outputData":{"text":"<h1>Profile<\/h1>\n<div>\n    <h2>Charlie<\/h2>\n    <div>\n        <h3>Interests<\/h3>\n        <p>Likes: Milk steak, ghouls.<\/p>\n        <p>Dislikes: Peoples' knees.<\/p>\n    <\/div>\n<\/div>\n","truncated":false}}
%---
%[output:4a91e33a]
%   data: {"dataType":"text","outputData":{"text":"Renders: 2000\nNo cache: 0.655789 s\nCached:  0.114628 s\n","truncated":false}}
%---
