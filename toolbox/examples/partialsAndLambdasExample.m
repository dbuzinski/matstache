%[text] # Using Lambdas and Partials
%[text] ## Use Partials to Include Templates Within Templates
%[text] We can create a template `blog.mustache` for our blog that has a list of posts. We can define another template `post.mustache` to display each post in our list of posts and include that in our blog template using a partial tag.
%[text] Partials are rendered at runtime and inherit the calling context so we can use `name` from our context in both the blog template and the post template.
% Load a template
template = fileread(fullfile("views", "blog.mustache"));

% Define a context
context = jsondecode(fileread(fullfile("data", "blog.json")));

% Load partials to a struct
partials = struct("post", fileread(fullfile("views", "post.mustache")));

% Render the template
out = matstache.render(template, context, partials);
disp(out);
%[text] ## Use Lambdas to Dynamically Modify Templates
%[text] ### Variable lambdas
%[text] A variable lambda is a function handle with no inputs. The returned text is treated as template text and rendered again.
% Using a lambda, we can transform name to make it bold everywhere
context.rawName = context.name;
context.name = @() "<b>{{rawName}}</b>";

% Render the page
out = matstache.render(template, context, partials);
disp(out);
%%
%[text] ### Section lambdas
%[text] A section lambda is a function handle that takes the section’s raw inner text as input.
%[text] The returned text is treated as template text and rendered again.
% Using a section lambda, we can wrap the section’s inner template (or replace it entirely).
context.posts = @(inner) "<div class=""posts"">" + string(inner) + "</div>";

% Render the page
out = matstache.render(template, context, partials);
disp(out);

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
