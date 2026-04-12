classdef ContextTests < matlab.unittest.TestCase
    methods (TestMethodSetup)
        function setupPath(testCase)
            import matlab.unittest.fixtures.PathFixture;

            % Add ContextObject to path for testing
            testCase.applyFixture(PathFixture("testdata"));
        end
    end

    methods (Test)
        function lookupFindsPropertiesOnContextClasses(testCase)
            c = ContextObject;
            [tf, val] = lookup__(c, "name");
            testCase.verifyTrue(tf);
            testCase.verifyEqual(val, c.name);
        end

        function lookupFindsMethodsOnContextClasses(testCase)
            c = ContextObject;
            [tf, val] = lookup__(c, "greeting");
            testCase.verifyTrue(tf);
            testCase.verifyEqual(val, c.greeting());
        end

        function lookupReturnsFalseIfNotAPropertyOrMathod(testCase)
            c = ContextObject;
            testCase.verifyFalse(lookup__(c, "nonexistent"));
        end

        function implicitlyConvertsStructs(testCase)
            c = matstache.Context.empty();
            s = struct("a", 1, "b", 2);
            c = [c s];
            testCase.verifyInstanceOf(c, ?matstache.Context);
            % Contains expected entries
            testCase.verifyTrue(lookup__(c, "a"));
            testCase.verifyTrue(lookup__(c, "b"));
            testCase.verifyFalse(lookup__(c, "c"));
        end
    end
end