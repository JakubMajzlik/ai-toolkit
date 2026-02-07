# AGENTS.md Cookbook

## Context management

Context is one of the most important thing for AI agents, better context equals better result of the work. Having all the information about project in AI context can be expensive and it can cause bad results (more content, more place for confusion of AI). Because of that it is good to store context in different files. To make AI know where to find right information it is good to annotate files with short semantic description about the file. This semantic information about files can be stored in `AGENTS.md` file or in some register files, for example `.contextregistry`.

### Prompt
```markdown
# Context Management
context-folder=.ai/context

All context you can find in `<context-folder`. The folder contains subfolders, `.contextregistry` file and files with context. `.contextregistry` file,contains information what different files and folders in the current folder contains information about. Always read `.contextregistry` first, the read just necessary files, do not read files if you do not need information from them.

```

### Example of `.contextregistry`

```markdown
# kotlin-coding-conventions.md
Convention that have to be followed if programming in kotlin.

# git-conventions.md
Conventions that have to be followed when working with git versioning system.
```