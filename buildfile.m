function plan = buildfile
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask;
plan("test") = TestTask("tests", ...
    SourceFiles="toolbox" ...
).addCodeCoverage("results/test/coverage/index.html", MetricLevel="mcdc");

plan.DefaultTasks = ["check" "test"];
end
