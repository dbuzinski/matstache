function plan = buildfile
import matlab.buildtool.Task;
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("clean") = CleanTask;

plan("check") = CodeIssuesTask;

plan("test") = TestTask;

docFiles = plan.files(["toolbox/doc/*.m", "toolbox/examples/*Example.m"]);
htmlFiles = docFiles.transform(@toHtmlFile);
plan("export") = Task( ...
    Description = "Export documentation and examples", ...
    Actions = @exportDoc, ...
    Inputs = docFiles, ...
    Outputs = htmlFiles);

plan("doc") = Task( ...
    Description = "Build searchable documentation database", ...
    Actions = @buildDocDb, ...
    Dependencies = "export", ...
    Inputs = "toolbox/html/*.html", ...
    outputs = ["toolbox/html/helpsearch-v4_en", "toolbox/html/custom_toolbox.json"]);

plan("package") = Task( ...
    Description = "Package toolbox", ...
    Actions = @packageToolbox, ...
    Dependencies = "doc", ...
    Inputs = plan.files("toolbox"), ...
    Outputs = plan.files("build/release/matstache.mltbx"));

plan.DefaultTasks = ["check" "test", "package"];
end

function exportDoc(ctx)
% Add examples folder to path
origPath = path;
restorePath = onCleanup(@()path(origPath));
addpath("toolbox/examples");

mlxFiles = ctx.Task.Inputs.paths();
htmlFiles = ctx.Task.Outputs.paths();
for i = 1:numel(mlxFiles)
    export(mlxFiles(i), htmlFiles(i), Run=true);
end
end

function packageToolbox(ctx)
import matlab.addons.toolbox.ToolboxOptions;

tbxFolder = ctx.Task.Inputs.Path;
tbxFile = ctx.Task.Outputs.Path;

opts = ToolboxOptions(tbxFolder, "f396b9ca-fd14-46e2-878b-e053ffb5cca2", ...
    ToolboxName = "Matstache", ...
    ToolboxVersion = "1.0.0", ...
    Description = "Mustache templates for MATLAB.", ...
    Summary = "Mustache templates for MATLAB", ...
    AuthorName = "David Buzinski", ...
    AuthorEmail = "davidbuzinski@gmail.com", ...
    ToolboxGettingStartedGuide = "toolbox/doc/GettingStarted.m", ...
    OutputFile = tbxFile);

matlab.addons.toolbox.packageToolbox(opts);
end

function html = toHtmlFile(file)
[~, name] = fileparts(file);
html = fullfile("toolbox", "html", name + ".html");
end

function buildDocDb(~)
builddocsearchdb("toolbox/html");
end