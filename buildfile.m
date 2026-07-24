function plan = buildfile
import matlab.buildtool.Task;
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("clean") = CleanTask;

plan("check") = CodeIssuesTask;

plan("test") = TestTask;

docFiles = plan.files(["src/doc/*.m", "src/examples/*Example.m"]);
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
    Inputs = "src/html/*.html", ...
    outputs = ["src/html/helpsearch-v4_en/index_meta.json", ...
        "src/html/custom_toolbox.json", ...
        "src/html/helpsearch-v4_en/store/*"]);

plan("package") = PackageTask(Dependencies="doc");

plan.DefaultTasks = ["check" "test", "package"];
end

% Task actions and helpers

function exportDoc(ctx)
mlxFiles = ctx.Task.Inputs.paths();
htmlFiles = ctx.Task.Outputs.paths();
for i = 1:numel(mlxFiles)
    export(mlxFiles(i), htmlFiles(i), Run=true);
    if ~contains(mlxFiles(i), ["GettingStarted", "examples"])
        %unescape HTML
        content = string(fileread(htmlFiles(i)));
        content = content.replace(["&lt;", "&gt;"], ["<", ">"]);
        fid = fopen(htmlFiles(i), "w");
        closeFile = onCleanup(@()fclose(fid));
        fprintf(fid, content);
        clear closeFile;
    end
end
end

function html = toHtmlFile(file)
[~, name] = fileparts(file);
html = fullfile("src", "html", name + ".html");
end

function buildDocDb(~)
builddocsearchdb("src/html");
end
