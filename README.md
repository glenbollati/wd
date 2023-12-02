A tool to bookmark directories. Copy and paste into .bashrc (or a file sourced by `.bashrc`) to use. Includes bash completion

Bookmark file is created at `$HOME/.wd` by default

## Usage

```
USAGE: wd                               shows current bookmarks
   OR: wd             <NAME>            jump to directory saved as <NAME>
   OR: wd a (add)     <NAME> <DIR>      adds <DIR> to bookmarks as <NAME>
   OR: wd r (replace) <NAME> <NEW_DIR>  sets <NAME> to point to <NEW_DIR>
   OR: wd clear       <NAME>            clear <NAME> from bookmarks 
   OR: wd e (edit)                      opens the bookmarks file for editing
   OR: wd p                             jump to previous directory
```

## Example:

```
[hostname ~] $ wd a proj /mnt/git/projects/myproject
[hostname ~] $ wd proj
Moved to /mnt/git/projects/myproject
[/mnt/git/projects/myproject ~] $ wd p
Moved to ~
[hostname ~] $
```
