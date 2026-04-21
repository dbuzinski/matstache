%[text] # Using Lambdas and Partials
%[text] ## Use Partials to Include Templates Within Templates
%[text] We can create a template `blog.mustache` for our blog that has a list of posts. If we want to reuse the template for a post in other parts of our site, we can store it in another template and use a partial.
% Load a template
template = fileread(fullfile("views", "blog.mustache"));

disp(template); %[output:17015bd0]
%%
%[text] We can load the template `post.mustache` to display each post in our list of posts and include that in our blog template using a partial tag.
% Load partials to a struct
partials = struct("post", fileread(fullfile("views", "post.mustache")));

disp(partials.post); %[output:008e4ee1]
%%
%[text] We can load the data containing all posts for a given author. We can retrieve this from a database or another service. For this example, we will load the data from a json file.
% Define a context
jsonData = fileread(fullfile("data", "blog.json"));
context = jsondecode(jsonData);
disp(jsonData); %[output:2aba4f16]
%%
%[text] Partials are rendered at runtime and inherit the calling context so we can use `name` from our context in both the blog template and the post template.
% Render the template
out = matstache.render(template, context, partials);
disp(out); %[output:495c1309]
%[text] ## Use Lambdas to Dynamically Modify Templates
%[text] ### Variable lambdas
%[text] Section lambdas can be used to modify or replace content within sections.
%[text] Function handles with zero inputs can be used as a variable tag. It should return a Mustache template as a string scalar. The lambda will be evaluated, and the returned template will be rendered using the current context.
% Using a lambda, we can transform name to make it bold everywhere
context.rawName = context.name;
context.name = @() "<b>{{rawName}}</b>";

% Render the page
out = matstache.render(template, context, partials);
disp(out); %[output:8592edfa]
%%
%[text] ### Section lambdas
%[text] Section lambdas can be used to modify or replace content within sections.
%[text] Function handles with **one input** can be used as a section tag. It should return a Mustache template as a string scalar. The lambda will be evaluated on the inner content of the section, and the returned template will be rendered using the current context.
% Using a section lambda, we can wrap the section’s inner template (or replace it entirely).
context.posts = @(inner) "        Nothing to see here!" + newline;

% Render the page
out = matstache.render(template, context, partials);
disp(out); %[output:493aca43]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":34.4}
%---
%[output:17015bd0]
%   data: {"dataType":"text","outputData":{"text":"<div>\n    <h1>{{&name}}'s Blog<\/h1>\n    <h2>Posts:<\/h2>\n    <div>\n        {{#posts}}\n            {{>post}}\n        {{\/posts}}\n    <\/div>\n<\/div>\n","truncated":false}}
%---
%[output:008e4ee1]
%   data: {"dataType":"text","outputData":{"text":"<div>\n    <h3>{{title}}<\/h3>\n    <p>Author: {{&name}}. Created: {{date}}.<\/p>\n    <p>Summary: {{summary}}<\/p>\n<\/div>\n\n","truncated":false}}
%---
%[output:2aba4f16]
%   data: {"dataType":"text","outputData":{"text":"{\n    \"name\": \"David\",\n    \"posts\": [\n        {\n            \"title\": \"Proofs from the Book\",\n            \"date\": \"03\/30\/2026\",\n            \"summary\": \"Here are some of my favorite proofs of all time.\"\n        },\n        {\n            \"title\": \"The Sensual (Quadratic) Form\",\n            \"date\": \"03\/23\/2026\",\n            \"summary\": \"Can you hear the sound of a quadratic? Can you feel it?\"\n        },\n        {\n            \"title\": \"What is a Monad? (and why you shouldn't care)\",\n            \"date\": \"03\/17\/2026\",\n            \"summary\": \"How are monads used in programming, and how does that relate to their mathematical definitions?\"\n        }\n    ]\n}\n","truncated":false}}
%---
%[output:495c1309]
%   data: {"dataType":"text","outputData":{"text":"<div>\n    <h1>David's Blog<\/h1>\n    <h2>Posts:<\/h2>\n    <div>\n            <div>\n                <h3>Proofs from the Book<\/h3>\n                <p>Author: David. Created: 03\/30\/2026.<\/p>\n                <p>Summary: Here are some of my favorite proofs of all time.<\/p>\n            <\/div>\n            <div>\n                <h3>The Sensual (Quadratic) Form<\/h3>\n                <p>Author: David. Created: 03\/23\/2026.<\/p>\n                <p>Summary: Can you hear the sound of a quadratic? Can you feel it?<\/p>\n            <\/div>\n            <div>\n                <h3>What is a Monad? (and why you shouldn't care)<\/h3>\n                <p>Author: David. Created: 03\/17\/2026.<\/p>\n                <p>Summary: How are monads used in programming, and how does that relate to their mathematical definitions?<\/p>\n            <\/div>\n    <\/div>\n<\/div>\n","truncated":false}}
%---
%[output:8592edfa]
%   data: {"dataType":"text","outputData":{"text":"<div>\n    <h1><b>David<\/b>'s Blog<\/h1>\n    <h2>Posts:<\/h2>\n    <div>\n            <div>\n                <h3>Proofs from the Book<\/h3>\n                <p>Author: <b>David<\/b>. Created: 03\/30\/2026.<\/p>\n                <p>Summary: Here are some of my favorite proofs of all time.<\/p>\n            <\/div>\n            <div>\n                <h3>The Sensual (Quadratic) Form<\/h3>\n                <p>Author: <b>David<\/b>. Created: 03\/23\/2026.<\/p>\n                <p>Summary: Can you hear the sound of a quadratic? Can you feel it?<\/p>\n            <\/div>\n            <div>\n                <h3>What is a Monad? (and why you shouldn't care)<\/h3>\n                <p>Author: <b>David<\/b>. Created: 03\/17\/2026.<\/p>\n                <p>Summary: How are monads used in programming, and how does that relate to their mathematical definitions?<\/p>\n            <\/div>\n    <\/div>\n<\/div>\n","truncated":false}}
%---
%[output:493aca43]
%   data: {"dataType":"text","outputData":{"text":"<div>\n    <h1><b>David<\/b>'s Blog<\/h1>\n    <h2>Posts:<\/h2>\n    <div>\n        Nothing to see here!\n    <\/div>\n<\/div>\n","truncated":false}}
%---
