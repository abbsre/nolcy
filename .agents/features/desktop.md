# Feature: Desktop App

## Objective

Create a Windows `.exe` desktop app that uses the existing workspace scripts and lets the user select which project path and editor should be opened.

## Current State

The current implementation is a first working version.

1. It is a WinForms desktop app compiled with the Windows .NET Framework C# compiler.
2. The current desktop UI is branded as `Nocly`.
3. It opens a centered, non-maximized window.
4. It stores registered projects in a local text file with one path per line.
5. It launches `start-work.bat` with the selected project path and selected editor as parameters.
6. It closes after triggering the launcher.

## Language

1. The application UI must be written in English.

## Window Requirements

1. The app must open a Windows desktop window.
2. The window must start centered on the primary screen.
3. The window must not start maximized.
4. The top area of the window must show a welcome message.

## Main User Flows

The app must let the user work from the registered project list and provide one primary creation action:

1. Select a project from the visible registered list.
2. Choose which editor should open for that launch.
3. `Add Project`

## Open Existing Project Flow

1. Show the list of project paths already stored in the persistent file.
2. Let the user click a path from the list to select it.
3. Allow double click on a listed project to launch it directly.
4. Keep `VSCode` selected by default and allow `Nvim` as the alternative.
5. Only allow launching paths that already exist in the persistent file.

## Add Project Flow

1. Let the user browse for a project folder using a native Windows folder picker.
2. Add the selected path to the persistent file.
3. Avoid duplicate entries in the persistent file.
4. After the path is added, allow the user to use that path as the selected project.

## Launch Behavior

1. Once the user selects a project, the app must pass that path and the selected editor as parameters to the existing launcher script.
2. The editor selection must behave as a single-choice checkbox group.
3. After starting the launcher script, the desktop app must close.

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
3. Let the user select a registered project from the visible list, choose an editor, and use `Add Project` when needed.
4. Load the stored paths from the persistent file.
5. Let the user select an existing stored project.
6. Let the user add a new project through a folder browser.
7. Save new valid paths to the persistent file.
8. Default the editor selection to `VSCode` and allow `Nvim` as the alternative.
9. Pass the selected path and selected editor to the existing launcher script.
10. Close the app after the launcher script starts.
11. Fail with a clear message if the selected path is invalid or the launcher script cannot be started.

## Implementation Files

1. `desktop-app/Nocly.cs`: WinForms source code.
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
8. Selecting a project launches the existing script with the chosen path and editor.
9. `VSCode` is selected by default and `Nvim` remains available as an alternative.
10. The desktop app closes after triggering the launcher.
11. The build process produces `desktop-app/Nocly.exe`.
