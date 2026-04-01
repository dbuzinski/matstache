classdef SpecTests < matlab.unittest.TestCase

    properties
        Tests
    end

    properties (ClassSetupParameter)
        specFiles = { ...
            'testdata/spec/specs/comments.json', ...
            'testdata/spec/specs/interpolation.json', ...
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
            out = matstache.render(specTests.template, specTests.data);
            testCase.verifyEqual(out, string(specTests.expected));
        end
    end

end