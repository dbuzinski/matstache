classdef TokenType
    % matstache.internal.TokenType is an internal class.

    enumeration
        Text
        Variable
        UnescapedVariable
        Section
        Inverted
        EndSection
        Partial
        SetDelimiters
        Comment
    end
end