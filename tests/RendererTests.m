classdef RendererTests < matlab.unittest.TestCase
    % Note that almost all of the test coverage for the Renderer comes from
    % SpecTests. This file only tests edge cases and error conditions.
    methods (Test)
        function convertsLambdaOutputsToString(testCase)
            renderer = matstache.Renderer();
            template = "{{ lambda }}";
            ctx.lambda = @() 1;

            expected = "1";
            actual = renderer.render(template, ctx);
            testCase.verifyEqual(expected, actual);
        end

        function errorsIfLambdaCannotConvertToString(testCase)
            renderer = matstache.Renderer();
            template = "{{ lambda }}";
            % lambda returns function_handle
            ctx.lambda = @() @sqrt;

            testCase.verifyError(@()renderer.render(template, ctx), ...
                "matstache:UnableToConvertToString");
        end
    end
end