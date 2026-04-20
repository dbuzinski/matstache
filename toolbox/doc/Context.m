%[text] # `matstache.Context`
%[text] Data used to render Mustache templates
%[text] A `matstache.Context` can expose values through MATLAB properties and methods, and can also wrap plain MATLAB data such as structs. You can subclass `matstache.Context` to define structured context data using properties and methods.
%%
%[text] ## Notes
%[text] - You can typically pass a `struct` instead, and MATLAB will automatically convert it to a context object.
%[text] - Context lookup checks for a property or method name matching the tag key.
%[text] - When a tag resolves to a function handle (for structs and wrapped data), Matstache treats it as a lambda. \

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
