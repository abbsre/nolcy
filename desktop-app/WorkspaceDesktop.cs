using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Windows.Forms;

namespace WorkspaceDesktop
{
    internal static class Program
    {
        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new LauncherForm());
        }
    }

    internal sealed class LauncherForm : Form
    {
        private readonly string appRoot;
        private readonly string repoRoot;
        private readonly string launcherPath;
        private readonly string projectsFilePath;
        private readonly string projectsExamplePath;

        private readonly Label welcomeLabel;
        private readonly Label helpLabel;
        private readonly ListBox projectsListBox;
        private readonly Button browseRegisteredButton;
        private readonly Button addProjectButton;
        private readonly Button openProjectButton;
        private readonly Button cancelButton;
        private readonly Label statusLabel;

        private List<string> registeredProjects;

        public LauncherForm()
        {
            appRoot = AppDomain.CurrentDomain.BaseDirectory.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            var appParent = Directory.GetParent(appRoot);
            repoRoot = appParent != null ? appParent.FullName : appRoot;
            launcherPath = Path.Combine(repoRoot, "start-work.bat");
            projectsFilePath = Path.Combine(appRoot, "projects.txt");
            projectsExamplePath = Path.Combine(appRoot, "projects.example.txt");
            registeredProjects = new List<string>();

            Text = "Nocly";
            StartPosition = FormStartPosition.CenterScreen;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = true;
            ClientSize = new Size(760, 460);
            Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point);

            welcomeLabel = new Label
            {
                AutoSize = true,
                Location = new Point(22, 20),
                Font = new Font("Segoe UI", 16F, FontStyle.Bold, GraphicsUnit.Point),
                Text = "Welcome to Nocly"
            };

            helpLabel = new Label
            {
                AutoSize = false,
                Location = new Point(24, 58),
                Size = new Size(700, 40),
                Text = "Choose an existing registered project or add a new one. The launcher will open Nvim, Opencode and Lazygit."
            };

            projectsListBox = new ListBox
            {
                Location = new Point(24, 115),
                Size = new Size(710, 220),
                IntegralHeight = false,
                HorizontalScrollbar = true
            };
            projectsListBox.DoubleClick += (sender, args) => OpenSelectedProject();

            browseRegisteredButton = new Button
            {
                Location = new Point(24, 355),
                Size = new Size(165, 34),
                Text = "Open Existing Project"
            };
            browseRegisteredButton.Click += (sender, args) => BrowseRegisteredProject();

            addProjectButton = new Button
            {
                Location = new Point(205, 355),
                Size = new Size(140, 34),
                Text = "Add Project"
            };
            addProjectButton.Click += (sender, args) => AddProject();

            openProjectButton = new Button
            {
                Location = new Point(571, 355),
                Size = new Size(163, 34),
                Text = "Launch Selected Project"
            };
            openProjectButton.Click += (sender, args) => OpenSelectedProject();

            cancelButton = new Button
            {
                Location = new Point(463, 355),
                Size = new Size(92, 34),
                Text = "Cancel"
            };
            cancelButton.Click += (sender, args) => Close();

            statusLabel = new Label
            {
                AutoSize = false,
                Location = new Point(24, 404),
                Size = new Size(710, 36),
                ForeColor = Color.DimGray,
                Text = "No project selected."
            };

            Controls.Add(welcomeLabel);
            Controls.Add(helpLabel);
            Controls.Add(projectsListBox);
            Controls.Add(browseRegisteredButton);
            Controls.Add(addProjectButton);
            Controls.Add(openProjectButton);
            Controls.Add(cancelButton);
            Controls.Add(statusLabel);

            Load += (sender, args) => InitializeApp();
        }

        private void InitializeApp()
        {
            EnsureExampleFile();
            LoadProjects();

            if (!File.Exists(launcherPath))
            {
                SetStatus("Launcher script not found. Expected: " + launcherPath, true);
            }
        }

        private void EnsureExampleFile()
        {
            if (File.Exists(projectsExamplePath))
            {
                return;
            }

            File.WriteAllLines(projectsExamplePath, new[] { @"D:\Projects\example-project" });
        }

        private void LoadProjects()
        {
            registeredProjects = ReadProjects();
            projectsListBox.Items.Clear();

            foreach (var project in registeredProjects)
            {
                projectsListBox.Items.Add(project);
            }

            if (projectsListBox.Items.Count > 0)
            {
                projectsListBox.SelectedIndex = 0;
                SetStatus("Loaded " + projectsListBox.Items.Count + " registered project(s).", false);
            }
            else
            {
                SetStatus("No registered projects yet. Use Add Project to save one.", false);
            }
        }

        private List<string> ReadProjects()
        {
            if (!File.Exists(projectsFilePath))
            {
                return new List<string>();
            }

            return File.ReadAllLines(projectsFilePath)
                .Select(line => line.Trim())
                .Where(line => !string.IsNullOrWhiteSpace(line))
                .Where(Directory.Exists)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(line => line, StringComparer.OrdinalIgnoreCase)
                .ToList();
        }

        private void SaveProjects(List<string> projects)
        {
            File.WriteAllLines(projectsFilePath, projects);
        }

        private void BrowseRegisteredProject()
        {
            using (var dialog = new FolderBrowserDialog())
            {
                dialog.Description = "Select a registered project folder";
                dialog.ShowNewFolderButton = false;

                if (dialog.ShowDialog(this) != DialogResult.OK)
                {
                    return;
                }

                var selectedPath = dialog.SelectedPath.Trim();
                var match = registeredProjects.FirstOrDefault(path => string.Equals(path, selectedPath, StringComparison.OrdinalIgnoreCase));

                if (match == null)
                {
                    MessageBox.Show(this, "The selected folder is not registered yet. Use Add Project to save it first.", "Project Not Registered", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }

                projectsListBox.SelectedItem = match;
                SetStatus("Selected registered project: " + match, false);
            }
        }

        private void AddProject()
        {
            using (var dialog = new FolderBrowserDialog())
            {
                dialog.Description = "Select a project folder to add";
                dialog.ShowNewFolderButton = false;

                if (dialog.ShowDialog(this) != DialogResult.OK)
                {
                    return;
                }

                var selectedPath = dialog.SelectedPath.Trim();

                if (!Directory.Exists(selectedPath))
                {
                    MessageBox.Show(this, "The selected folder does not exist.", "Invalid Folder", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                var updatedProjects = new List<string>(registeredProjects);

                if (!updatedProjects.Contains(selectedPath, StringComparer.OrdinalIgnoreCase))
                {
                    updatedProjects.Add(selectedPath);
                    updatedProjects = updatedProjects
                        .Distinct(StringComparer.OrdinalIgnoreCase)
                        .OrderBy(path => path, StringComparer.OrdinalIgnoreCase)
                        .ToList();

                    SaveProjects(updatedProjects);
                    registeredProjects = updatedProjects;
                    LoadProjects();
                }

                projectsListBox.SelectedItem = registeredProjects.First(path => string.Equals(path, selectedPath, StringComparison.OrdinalIgnoreCase));
                SetStatus("Project ready: " + selectedPath, false);
            }
        }

        private void OpenSelectedProject()
        {
            var selectedPath = projectsListBox.SelectedItem as string;

            if (string.IsNullOrWhiteSpace(selectedPath))
            {
                MessageBox.Show(this, "Select a project first.", "No Project Selected", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            if (!Directory.Exists(selectedPath))
            {
                MessageBox.Show(this, "The selected project path no longer exists.", "Invalid Project Path", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (!File.Exists(launcherPath))
            {
                MessageBox.Show(this, "The launcher script was not found: " + launcherPath, "Launcher Missing", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            try
            {
                var startInfo = new ProcessStartInfo
                {
                    FileName = launcherPath,
                    Arguments = QuoteArgument(selectedPath),
                    WorkingDirectory = repoRoot,
                    UseShellExecute = true
                };

                Process.Start(startInfo);
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, "The launcher could not be started.\n\n" + ex.Message, "Launcher Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void SetStatus(string message, bool isError)
        {
            statusLabel.Text = message;
            statusLabel.ForeColor = isError ? Color.Firebrick : Color.DimGray;
        }

        private static string QuoteArgument(string value)
        {
            return "\"" + value.Replace("\"", "\\\"") + "\"";
        }
    }
}
