# git-cliff template

Template repo for using [git-cliff](https://github.com/orhun/git-cliff)

## Prerequisites

Before you begin, ensure that you have the following tools installed:

- **direnv** and **direnv-nix**): To automatically enter the development-environment
- **nix**: Each assignment comes with a flake.nix (easily install dependencies)

### Installing Dependencies

You can install all necessary tools using Nix by running:

```bash
direnv allow
```

## Commit Message Guidelines

To maintain a consistent and meaningful commit history, adhere to the following commit message conventions. Each commit message should start with one of the predefined prefixes and match the following groups:

| Prefix       | Group Description          | Notes                              |
|--------------|----------------------------|------------------------------------|
| `feat`       | 🚀 **Features**            | For new features or improvements. |
| `fix`        | 🐛 **Bug Fixes**           | For bug fixes.                    |
| `doc`        | 📚 **Documentation**       | For documentation updates.        |
| `perf`       | ⚡ **Performance**         | For performance improvements.     |
| `refactor`   | 🚜 **Refactor**            | For code refactoring.             |
| `style`      | 🎨 **Styling**             | For UI or code style updates.     |
| `test`       | 🧪 **Testing**             | For adding or improving tests.    |
| `chore`      | ⚙️ **Miscellaneous Tasks** | For minor changes or setup tasks. |
| `ci`         | ⚙️ **Miscellaneous Tasks** | For continuous integration updates. |
| `revert`     | ◀️ **Reverts**             | For reverting changes.            |

### Special Notes

- **Security-related updates**: If the commit message body contains "security", it will be grouped under 🛡️ **Security** regardless of the prefix.
- **Releases**: Messages starting with `chore(release): prepare for` will be skipped in the changelog.
- **Dependency updates**: Messages starting with `chore(deps...)` will be skipped in the changelog.
- **PR-related messages**: Messages starting with `chore(pr)` or `chore(pull)` will also be skipped.
- **Catch-all category**: Any commit message that doesn't match the above patterns will fall under 💼 **Other**.

**Note:** Use lowercase letters for prefixes and follow them with a colon and a space (e.g., `feat: Add new feature`).

## Release Process

Releasing a new assignment version is straightforward. Follow these steps to create a new release:

```bash
./release.sh vx.y.z
git push && git push --tags
```

If you are encountering any issues feel free to look at the [git-cliff docs](https://github.com/orhun/git-cliff.git)
