classdef TokenType
    enumeration
        Text
        Variable
        UnescapedVariable
        SectionStart
        SectionEnd
        InvertedStart
        Partial
        SetDelimiters
        Comment
    end
end