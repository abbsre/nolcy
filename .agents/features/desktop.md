# Feature: Desktop App

## Objective

Create a Windows `.exe` desktop app that uses the existing workspace scripts and lets the user select which project path should be opened.

## Current State

The current implementation is a first working version.

1. It is a WinForms desktop app compiled with the Windows .NET Framework C# compiler.
2. It opens a centered, non-maximized window.
3. It stores registered projects in a local text file with one path per line.
4. It launches `start-work.bat` with the selected project path as a parameter.
5. It closes after triggering the launcher.

## Language

1. The application UI must be written in English.

## Window Requirements

1. The app must open a Windows desktop window.
2. The window must start centered on the primary screen.
3. The window must not start maximized.
4. The top area of the window must show a welcome message.

## Main User Flows

The app must let the user choose between two actions:

1. `Open Existing Project`
2. `Add Project`

## Open Existing Project Flow

1. Show the list of project paths already stored in the persistent file.
2. Let the user click a path from the list to select it.
3. Provide a file-system browser to help the user find a registered project path more easily.
4. Only allow selection of paths that already exist in the persistent file.

## Add Project Flow

1. Let the user browse for a project folder using a native Windows folder picker.
2. Add the selected path to the persistent file.
3. Avoid duplicate entries in the persistent file.
4. After the path is added, allow the user to use that path as the selected project.

## Launch Behavior

1. Once the user selects a project, the app must pass that path as a parameter to the existing launcher script.
2. After starting the launcher script, the desktop app must close.

## Persistence

1. Project paths must be stored in a persistent local file.
2. The persistent file must not be versioned with Git.
3. The repository must include an example file with a generic sample path.
4. The persistent file format must be simple to read and update from the desktop app.
5. In the current version, the persistent format is a plain text file with one project path per line.

## Restrictions

1. This feature must reuse the existing scripts instead of replacing their logic.
2. The desktop app is responsible for selecting and passing the project path, not for reimplementing workspace startup.
3. The project path must be selected through Windows UI, not typed as a required primary flow.

## Minimum Expected Behavior

1. Open a centered, non-maximized desktop window.
2. Show the welcome message in English.
3. Let the user choose between `Open Existing Project` and `Add Project`.
4. Load the stored paths from the persistent file.
5. Let the user select an existing stored project.
6. Let the user add a new project through a folder browser.
7. Save new valid paths to the persistent file.
8. Pass the selected path to the existing launcher script.
9. Close the app after the launcher script starts.
10. Fail with a clear message if the selected path is invalid or the launcher script cannot be started.

## Implementation Files

1. `desktop-app/WorkspaceDesktop.cs`: WinForms source code.
2. `desktop-app/build-desktop-app.ps1`: build script for the `.exe`.
3. `desktop-app/projects.example.txt`: example persistent file.
4. `desktop-app/projects.txt`: local persistent file created by the app and excluded from Git.

## Acceptance Criteria

1. The app is delivered as a Windows `.exe`.
2. The UI text is in English.
3. The app opens in a centered, non-maximized window.
4. The user can open a previously registered project from a visible list.
5. The user can add a new project with a Windows folder picker.
6. New projects are persisted locally and are available in future runs.
7. The persistent file is excluded from Git, while an example file is committed.
8. Selecting a project launches the existing script with the chosen path.
9. The desktop app closes after triggering the launcher.
10. The build process produces `desktop-app/WorkspaceDesktop.exe`.
