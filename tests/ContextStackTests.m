classdef ContextStackTests < matlab.unittest.TestCase
    methods (TestMethodSetup)
        function setupPath(testCase)
            import matlab.unittest.fixtures.PathFixture;

            % Add ContextObject to path
            testCase.applyFixture(PathFixture("testdata"));
        end
    end

    methods (Test)
        function lookupWorksWithContextObject(testCase)
            ctx = ContextObject;
            stack = ContextStack(ctx);
            res = stack.lookup("name");

            testCase.verifyTrue(res.Success);
            testCase.verifyEqual(res.Data, ctx.name);
        end

        function lookupWorksWithNestedContextObjects(testCase)
            ctx = ContextObject;
            stack = ContextStack(ctx);
            res = stack.lookup("nested.name");

            testCase.verifyTrue(res.Success);
            testCase.verifyEqual(res.Data, ctx.name);
        end

        function lookupWorksWithDeeplyNestedContextObjects(testCase)
            ctx = ContextObject;
            stack = ContextStack(ctx);
            res = stack.lookup("nested.nested.name");

            testCase.verifyTrue(res.Success);
            testCase.verifyEqual(res.Data, ctx.name);
        end

        function falseLookupWithDeeplyNestedContextObjects(testCase)
            ctx = ContextObject;
            stack = ContextStack(ctx);
            res = stack.lookup("nested.doesnt.exist");

            testCase.verifyFalse(res.Success);
        end
        
        function lookupPeriodReturnsCurrent(testCase)
            ctx = struct("a", 1, "b", 2);
            stack = ContextStack(ctx);
            res = stack.lookup(".");

            testCase.verifyTrue(res.Success);
            testCase.verifyEqual(res.Data, ctx);
        end

        function pushAutoConvertsStructs(testCase)
            ctx = struct("a", 1, "b", 2);
            stack = ContextStack(struct("c", 3));
            stack = stack.push(ctx);
            res = stack.lookup(".");

            testCase.verifyTrue(res.Success);
            testCase.verifyEqual(res.Data, ctx);
        end

        function falseLookupResultIfNotInContext(testCase)
            ctx = struct("a", 1, "b", 2);
            stack = ContextStack(ctx);
            res = stack.lookup("c");
            testCase.verifyFalse(res.Success);
        end

        function popRemovesFromTopOfStack(testCase)
            ctx1 = struct("a", 1, "b", 2);
            ctx2 = ContextObject;

            stack = ContextStack(ctx1);
            stack = stack.push(ctx2);
            res = stack.lookup(".");

            testCase.verifyTrue(res.Success);
            testCase.verifyEqual(res.Data, ctx2);

            stack = stack.pop();
            res = stack.lookup(".");

            testCase.verifyTrue(res.Success);
            testCase.verifyEqual(res.Data, ctx1);
        end

        function cannotPopFromEmptyStack(testCase)
            ctx = struct("a", 1, "b", 2);
            stack = ContextStack(ctx);
            % empty the stack
            stack = stack.pop();

            testCase.verifyError(@()stack.pop(), "mustache:PopEmptyContextStack")
        end

        function lookupIsEmptyArray(testCase)
            % null json decodes to empty array in MATLAB
            % This ended up being an important case to check to  distinguish
            % between hits that were null and misses.
            ctx = struct("a", []);
            stack = ContextStack(ctx);
            res = stack.lookup("a");

            testCase.verifyTrue(res.Success);
            testCase.verifyEmpty(res.Data);
        end

        function nestedLookupIsEmptyArray(testCase)
            ctx = struct("a", struct("b", []));
            stack = ContextStack(ctx);
            res = stack.lookup("a.b");

            testCase.verifyTrue(res.Success);
            testCase.verifyEmpty(res.Data);
        end

        function nestedNullLookup(testCase)
            % null json decodes to empty array in MATLAB
            % This ended up being an important case to check to  distinguish
            % between hits that were null and misses.
            ctx = struct("a", []);
            stack = ContextStack(ctx);
            res = stack.lookup("a.b");

            testCase.verifyFalse(res.Success);
        end
    end
end

function stack = ContextStack(varargin)
stack = matstache.internal.ContextStack(varargin{:});
end