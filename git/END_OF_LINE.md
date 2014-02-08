Dealing with line endings
=========================

#Global setting

Git will automatically manage line endings for you if you set the core.autocrlf option.  
On Linux/OSX, you usually want to use input for this setting.
```
git config --global core.autocrlf input
```
On Windows, you usually want to use true for this setting.
```
git config --global core.autocrlf true
```

#Per-repository settings

Git allows you to set the line ending properties for a repository directly using the text attribute in the .gitattributes file. This file is committed into the repository and overrides the core.autocrlf setting, allowing you to ensure consistent behaviour for all users regardless of their git settings.

The .gitattributes file should be created in the root of the repository and committed into the repository like any other file.
```
text=auto
```
This setting will tell git to handle the files specified automatically. This is a good default option.
```
text
```
This setting tells git to always normalize the files specified. When committed they are stored with LF, on checkout they are converted to the OS's native line endings.
```
text eol=crlf
```
This setting tells git to normalize the files specified on commit, and always convert them to CRLF on checkout. You should use this for files that must retain CRLF endings, even on OSX or Linux.
```
text eol=lf
```
This setting tells git to normalize the files specified on commit, and always convert them to LF on checkout. You should use this for files that must retain LF endings, even on Windows.
```
binary
```
This setting tells git that the files specified are not text at all, and it should not try to change them. The binary setting is an alias for -text -diff.

##Example

Here's an example .gitattributes file, you can use it as a template for all your repositories:
```
# Set default behaviour, in case users don't have core.autocrlf set.
* text=auto

# Explicitly declare text files we want to always be normalized and converted 
# to native line endings on checkout.
*.c text
*.h text

# Declare files that will always have CRLF line endings on checkout.
*.sln text eol=crlf

# Denote all files that are truly binary and should not be modified.
*.png binary
*.jpg binary
```
The advantage of this is that your end of line configuration now travels with your repository and you don't need to worry about whether or not collaborators have the proper global settings.

#Re-normalizing a repository

After you've set the core.autocrlf option and committed a .gitattributes file, you may find that git wants to commit files that you've not modified. This is because git wants to normalize the line endings for you. The best way to do this is wipe out your working tree (all the files except the .git directory) and then restore them. Make sure you've committed any work before you do this, or it will be lost.
```
git rm --cached -r .
# Remove everything from the index.

git reset --hard
# Write both the index and working directory from git's database.

git add .
# Prepare to make a commit by staging all the files that will get normalized.
# This is your chance to inspect which files were never normalized. You should
# get lots of messages like: "warning: CRLF will be replaced by LF in file."

git commit -m "Normalize line endings"
# Commit
```

Thanks to Charles Bailey's post on [stack overflow](http://stackoverflow.com/questions/1510798/trying-to-fix-line-endings-with-git-filter-branch-but-having-no-luck/1511273#1511273) for the basis to this solution.

#Links

[.gitattributes](http://git-scm.com/docs/gitattributes#_checking-out_and_checking-in) man page
[git-config](http://git-scm.com/docs/git-config) man page
[Progit: Getting Started - First-Time Git Setup](http://git-scm.com/book/en/Getting-Started-First-Time-Git-Setup)
[Mind the End of Your Line](http://adaptivepatchwork.com/2012/03/01/mind-the-end-of-your-line/) - The full story of line endings in Git by Tim Clem
