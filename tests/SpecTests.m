classdef SpecTests < matlab.unittest.TestCase

    properties
        Tests
    end

    properties (ClassSetupParameter)
        specFiles = { ...
            'testdata/spec/specs/comments.json', ...
            'testdata/spec/specs/delimiters.json', ...
            'testdata/spec/specs/interpolation.json', ...
            'testdata/spec/specs/inverted.json', ...
            'testdata/spec/specs/partials.json', ...
            'testdata/spec/specs/sections.json'};
    end

    methods (TestClassSetup)
        function noop(testCase,specFiles)
        end
    end

    properties (TestParameter)
        specTests
    end

    methods (TestParameterDefinition,Static)
        function specTests = loadSpec(specFiles)
            spec = jsondecode(fileread(specFiles));
            specTests = num2cell(spec.tests);
        end
    end

    methods (Test)
        function validateRequirement(testCase, specTests)
            if iscell(specTests)
                specTests = specTests{1};
            end
            args = {specTests.template, specTests.data};
            if isfield(specTests, "partials")
                args{end+1} = specTests.partials;
            end
            out = matstache.render(args{:});
            testCase.verifyEqual(out, string(specTests.expected));
        end
    end

end