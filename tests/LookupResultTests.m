classdef LookupResultTests < matlab.unittest.TestCase
    methods (Test)
        function lookupResultIsTruthyArray(testCase)
            % empty is false
            res = LookupResult(true, []);
            testCase.verifyFalse(res.isTruthy());

            % nonempty is true
            res = LookupResult(true, [false false]);
            testCase.verifyTrue(res.isTruthy());
        end

        function lookupResultIsTruthyCell(testCase)
            % empty is false
            res = LookupResult(true, {});
            testCase.verifyFalse(res.isTruthy());

            % nonempty is true
            res = LookupResult(true, {'a' 'b' 'c'});
            testCase.verifyTrue(res.isTruthy());
        end

        function lookupResultIsTruthyString(testCase)
            % empty string is false
            res = LookupResult(true, "");
            testCase.verifyFalse(res.isTruthy());

            % nonempty is true
            res = LookupResult(true, "false");
            testCase.verifyTrue(res.isTruthy());
        end

        function lookupResultIsTruthyChar(testCase)
            % empty string is false
            res = LookupResult(true, '');
            testCase.verifyFalse(res.isTruthy());

            % nonempty is true
            res = LookupResult(true, 'false');
            testCase.verifyTrue(res.isTruthy());
        end

        function lookupResultIsTruthyLogical(testCase)
            % false is false
            res = LookupResult(true, false);
            testCase.verifyFalse(res.isTruthy());

            % true is true
            res = LookupResult(true, true);
            testCase.verifyTrue(res.isTruthy());
        end

        function lookupResultIsTruthyNumber(testCase)
            % 0 is false
            res = LookupResult(true, 0);
            testCase.verifyFalse(res.isTruthy());

            % non-zero is true
            res = LookupResult(true, -1);
            testCase.verifyTrue(res.isTruthy());
        end

        function scalarOfArbitraryClassIsTrue(testCase)
            res = LookupResult(true, testCase);
            testCase.verifyTrue(res.isTruthy());
        end
    end
end

function res = LookupResult(varargin)
res = matstache.internal.LookupResult(varargin{:});
end