%[text] # Writing Custom Context Classes
%[text] You can subclass `matstache.Context` to provide context data via MATLAB properties and methods.
%[text] Tags like `{{name}}` resolve to properties, and tags like `{{greeting}}` can resolve to methods.
%[text] See `toolbox/examples/MyCustomContext.m` for the full class definition used here.

context = MyCustomContext("Jim");
template = "Greeting for {{name}}: {{greeting}}";
out = matstache.render(template, context);
disp(out);

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
