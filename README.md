#vim-timelapse

Allow to navigate history changes for a file

##Usage

When editing a file inside a git repo, run 

    :TimeLapse

to open a new tab showing how that commit changed that file in vim's
diff mode (:help diff), with a window at the bottom showing the commit message.
Left and right arrows move through the history. Shift-left and shift-right go
all the way to the end. Return on a line from right buffer goes back to the 
last commit that touched that line (using git blame).

Close the tab when you're done. You can open as many time-lapse tabs on 
different files in one vim session as you want.

##Dependencies

For simplicity and consistency, this plugin uses [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)

##Supported VCS

- git

##Credits

This starts as a fork of [vim-scripts/git-time-lapse](http://www.vim.org/scripts/script.php?script_id=3849)

Inspired by the "time lapse view" in the Perforce gui.

