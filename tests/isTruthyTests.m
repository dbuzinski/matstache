classdef isTruthyTests < matlab.unittest.TestCase
    methods (Test)
        function emptyArrayNotTruthy(testCase)
            res = isTruthy([]);
            testCase.verifyFalse(isTruthy(res));
        end

        function nonemptyArrayIsTruthy(testCase)
            res = isTruthy([false false]);
            testCase.verifyTrue(isTruthy(res));
        end

        function emptyCellNotTruthy(testCase)
            res = isTruthy({});
            testCase.verifyFalse(isTruthy(res));
        end

        function nonemptyCellIsTruthy(testCase)
            res = isTruthy({'a' 'b' 'c'});
            testCase.verifyTrue(isTruthy(res));
        end

        function emptyStringNotTruthy(testCase)
            res = isTruthy("");
            testCase.verifyFalse(isTruthy(res));
        end

        function nonemptyStringIsTruthy(testCase)
            res = isTruthy("false");
            testCase.verifyTrue(isTruthy(res));
        end

        function emptyCharNotTruthy(testCase)
            res = isTruthy('');
            testCase.verifyFalse(isTruthy(res));
        end

        function nonemptyCharIsTruthy(testCase)
            res = isTruthy('false');
            testCase.verifyTrue(isTruthy(res));
        end

        function falseIsNotTruthy(testCase)
            res = isTruthy(false);
            testCase.verifyFalse(isTruthy(res));
        end

        function trueIsTruthy(testCase)
            res = isTruthy(true);
            testCase.verifyTrue(isTruthy(res));
        end

        function zeroIsNotTruthy(testCase)
            res = isTruthy(0);
            testCase.verifyFalse(isTruthy(res));
        end

        function nonzeroIsTruthy(testCase)
            res = isTruthy(-1);
            testCase.verifyTrue(isTruthy(res));
        end

        function scalarOfArbitraryClassIsTrue(testCase)
            res = isTruthy(testCase);
            testCase.verifyTrue(isTruthy(res));
        end
    end
end

function res = isTruthy(varargin)
res = matstache.internal.isTruthy(varargin{:});
end