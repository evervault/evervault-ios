[![Evervault](https://evervault.com/evervault.svg)](https://evervault.com/)

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/evervault/evervault-ios/issues.

## Commit Formatting & Releases

We use [changesets](https://github.com/changesets/changesets) to version manage in this repo.

When creating a pr that needs to be rolled into a version release, do `npx changeset`, select the level of the version bump required and describe the changes for the change logs. DO NOT select major for releasing breaking changes without team approval.

To release:

Merge the version PR that the changeset bot created to bump the version numbers. This will bump the versions of the packages, create a git tag for the release, and release the new version to npm.