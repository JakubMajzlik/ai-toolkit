# Git conventions

- Before creating a branch, always pull changes from the remote repository.
- Before pushing a branch:
  - if the branch does not exist remotely, rebase it with `main`
  - if the branch already exists remotely, merge `main` into the branch


## Commit
Use the following commit message format: `<type>: <issue-number> <description>`

<type> can be:
- `feat` for new features
- `chore` for chores like updates, ci/cd, ...
- `fix` for bugfixes
- `doc` for documentation updates
- `refactor` for code refactoring
- `test` for test changes
- `ci` for CI/CD changes
- `revert` for reverting previous changes

`<issue-number>` is optional. Add it only if the user asks you to do so. Do not ask the user for an issue number.

`<description>` should be short and one line.

## Branch
Use the following branch name format: `<issue-number>/<type>/<description>`

If no issue number is used, use: `<type>/<description>`.

Rules for `<type>`, optional issue number, and description are the same as for commit messages.
