---
description: release with git tag
model: opencode/minimax-m2.5-free
subtask: true
---

release with git tag

When making a new release:

1. If $1 is a valid semantic version, use it as the tag name
2. If $1 is null or blank
  - get the latest git tag starts with 'v' (must follow the semantic versioning patterns, e.g. `v1.0.7`) as current version, 
  - Increase current version (e.g. `v1.0.8`) , if you are not sure, ask user to confirm
3. Update `VERSION` in `install.sh` (if exists), `<version>` in `pom.xml` (if exists), or any other text files which are used in project build and contain current version (e.g. `v1.0.7`), to the new tag (e.g. `v1.0.8`)
4. Update any version references in `README.md`
5. Commit with message with new version, e.g. `chore: bump version to v1.0.8`
6. Tag the commit with new version, e.g. `git tag v1.0.8`
7. Push: `git push && git push --tags`
8. Let the CI/CD workflow create the GitHub release with built assets

References:

1. Semantic Versioning: https://semver.org/
