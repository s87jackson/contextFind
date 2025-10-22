## Resubmission

Per CRAN feedback, I have unwrapped the executable examples and added a verbose parameter to easily suppress the messages written to the console. CRAN also suggested adding references descibing the methods used in the package, but there are none as this is mainly a workflow enhancement tool.


## Test environments

-   Local windows install (x86_64-w64-mingw32 (64-bit)), R 4.4.0
-   Via GitHub's R CMD Check workflow: macOS-latest (release), windows-latest (release), ubuntu-latest (devel, release, oldrel-1)


## Latest R CMD check results

```         
Duration: 35.5s

> checking for future file timestamps ... NOTE
  unable to verify current time

0 errors v | 0 warnings v | 1 note x
```
