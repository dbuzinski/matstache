%[text] # `matstache.Context`
%[text] Data used to render Mustache templates
%[text] A `matstache.Context` can wrap plain MATLAB data such as structs and can also be subclassed to define reusable structured context data. Subclasses of `matstache.Context` expose values through their defined properties and methods.
%%
%[text] ## Notes
%[text] - You can pass a `struct` to any function or method that accepts a `matstache.Context` object, and MATLAB will automatically convert it.
%[text] - When a tag resolves to a function handle (for structs and wrapped data), Matstache treats it as a lambda. \

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
