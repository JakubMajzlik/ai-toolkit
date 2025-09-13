# Claude Development Context

## Devepoment process
You are implementing tasks while strictly following test driven development. First create a test, which will failt and then start implementing requested task. 

Tests run using script `.aitoolkit/scripts/run-tests.sh` in project root directory. If all tests passes, the script will return "OK", if any of tests fails, it will return which and why.

When you are done with tasks, run script `./aitoolkit/scripts/run-lintProject.sh`. If it pass, the script will return "OK". If it fails, the script will return the errors, fix them all and run the script again. If the script returns "Task is missing, skipping check", take it as it is OK.

Resolve formating issues using ` ./gradlew ktlintFormat`

## Project Overview
[PROJECT_OVERVIEW]

Whole project vision can be found in `.ai-toolkit/vision.md`

## Techstack
If information about techstack is need, read it from `.ai-toolkit/techstack.md`