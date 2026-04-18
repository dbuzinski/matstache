classdef SpecTests < matlab.unittest.TestCase
    properties (TestParameter)
        data = loadTestData()
    end

    methods (Test)
        function testRenderFunctionAgainstSpec(testCase, data)
            if isfield(data.data, "lambda")
                data.data.lambda = str2func(data.data.lambda.matlab);
            end
            args = {data.template, data.data};
            if isfield(data, "partials")
                args{end+1} = data.partials;
            end
            expected = string(data.expected);
            out = matstache.render(args{:});
            testCase.verifyEqual(expected, out, data.desc);
        end
    end
end

function testData = loadTestData()
specFiles = [ "testdata/spec/specs/comments.json", ...
    "testdata/spec/specs/delimiters.json", ...
    "testdata/spec/specs/interpolation.json", ...
    "testdata/spec/specs/inverted.json", ...
    "testdata/spec/specs/partials.json", ...
    "testdata/spec/specs/sections.json" ...
    "testdata/spec/specs/~lambdas.json" ...
];
testData = {};
for file = specFiles
    jsonData = jsondecode(fileread(file));
    tests = jsonData.tests(:)';
    if ~iscell(tests)
        tests = num2cell(tests);
    end
    testData = [testData, tests];
end
end
