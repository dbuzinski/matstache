# Matstache

[Mustache](http://mustache.github.io/) templates for MATLAB.

Matstache is fully [spec](https://github.com/mustache/spec) compliant and also implements [lambdas](https://github.com/mustache/spec/blob/master/specs/~lambdas.yml). For more details on tag syntax (variables, sections, partials, delimiters, and etc.), see the [mustache(5)](http://mustache.github.io/mustache.5.html) manual.

## Usage

###  Rendering a template

Templates can be rendered using the `matstache.render` function. The required inputs are the template, specified as a `string` scalar, and a context, which can be specified as a `struct` scalar or a `matstache.Context` scalar. The rendered text will be output as a `string` scalar.

```matlab
template = "Hello {{name}}!";
context = struct("name", "world");
out = matstache.render(template, context);
% Hello world!
```

#### Loading templates from a files

A `.mustache` file can be rendered by first reading the file using `fileread`. 

```matlab
template = fileread("views/page.mustache");
context = struct("title", "Home");
out = matstache.render(template, context);
```

### Partials

Partials can be passed to `matstache.render` as an optional third argument, specified as a scalar `struct`. The field names are the partial names and the values are the partial’s template specified as a `string` scalar.

```matlab
template = "{{>header}}Body{{>footer}}";
context = struct("title", "Hello");
partials = struct( ...
    "header", "<h1>{{title}}</h1>", ...
    "footer", fileread("views/footer.mustache"));
out = matstache.render(template, context, partials);
```

### Lambdas

Lambdas can be included by as **`function_handle`** values in the context.

- **Variable Tags:** the handle must be callable with no arguments. The returned value is rendered as a Mustache template.
- **Sections:** the handle must accept one argument, specified as a scalar `string`. At render time, it is called with the inner section text. The returned string replaces the section.

```matlab
% Pass lambdas as variables
context = struct( ...
    "planet", "world", ...
    "lambda", @() "{{planet}}");
out = matstache.render("Hello {{lambda}}!", context); 
% "Hello world!"

% Pass lambdas to sections
ctx = struct("wrap", @(text) "<b>" + text + "</b>");
out = matstache.render("{{#wrap}}inner{{/wrap}}", ctx);
% <b>inner</b>
```

### Custom Context Classes

A custom subclass of `matstache.Context` can be passed to `matstache.render` for structured data reuse. Context lookups use property and method names from the class. 

```matlab
classdef MyCustomContext < matstache.Context
    properties
        name = "world"
    end

    methods
        function context = MyCustomContext(name)
            context.name = name;
        end

        function out = greeting(context)
            out = "Hello " + context.name + "! It's a pleasure.";
        end
    end
end
```


```matlab
% MyCustomContext defines name property and greeting method
context = MyCustomContext("Jim");
out = matstache.render("Greeting for {{name}}: {{greeting}}", context);
% Greeting for Jim: Hello Jim! It's a pleasure.
```

### Caching

If the same template will be rendered many times, it can be more efficient to use a `matstache.Renderer` instance, which has caches parsed templates. This can have huge performance benefits for large templates or templates that will be rendered many times. The rendering is still dynamic and depends on the context passed to each `render` call.

```matlab
% Instantiate a renderer for reuse
renderer = matstache.Renderer;

context = struct("student", "Alice", "score", 92);

tic
out = renderer.render("{{student}} got a {{score}} out of 100 on the big exam.", context);
t = toc;
fprintf("First render took %f seconds.\n", t);

context = struct("student", "Bob", "score", 89);

tic
out = renderer.render("{{student}} got a {{score}} out of 100 on the big exam.", context);
t = toc;
fprintf("Cached render took %f seconds.\n", t);
```

## Installation

Requires **MATLAB R2023a** or later.

Install the **`.mltbx`** from the [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/) or using the Add-On Explorer.
