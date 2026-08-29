#Terminal & Git August 28th 2026: Mistakes I Actually Made Building This

I'm learning the terminal, git and SQL from scratch by building this project. Rather than write a tutorial pretending I got it on the first try, this is a log of the real mistakes I hit - what I ran, what broke, why it broke, and how I fixed it. If you're new to this too, you might find yourself in the same situation but that is part of the learning process.

## "Nothing Happened" usually means it worked

My first real confusion: I ran 'mkdir' to make a folder and... nothing printed. I assumed there had to have been a failure. 

**The concept:** most Unix commands are silent on success and only speak up when something's wrong - the opposite of a GUI, where every action gets a confirmation popup. 'mkdir', 'cd', 'git add', 'chown' - all silent when they work. The way I felt better was to prove they worked. This way to *prove* something worked isn't to expect an output. it's to check state afterwards ('pwd' to confirm location, 'ls' to confirm a file exists, 'git status' to confirm a stage happened and so forth).

## The .gitignore line that ate my pattern

**What I Ran:** typed a '.gitignore' in 'nano', including a comment followed by a pattern ('data/raw/') meant to be its own line.

**What happened:** 'git status' showed my "Private" data folder as untracked - meaning it wasn't actually being ignored. Normally fine if the name of the file isn't ignore.

**Why:** in 'gitignore' (and most config formats), a line starting with '#' is a comment, and *everything after it is on the same line* is part of the comment. I never pressed Enter between the comment and the pattern - the terminals visual word-wrap mode made it look like two lines on screen but it in fact one real line underneath.

**the fix:** reopened it in 'nano', placed the cursor right before the pattern, pressed Enter to create a real line break, then verified with 'cat -n .gitignore' (the '-n' numbers each line, making it obvious whether each pattern actually has its own line).

**The concetp:** a new line only exists where you specifically Enter/Return - visual wrapping in the terminal is not a real line break.

## The one-character bug: a leading space

**What I ran:** the fixed line-merge above, but the cursor landed one character off when I split the line. 

**What happened:** 'cat -n' showed' data/raw' - a leading space before the pattern - and the ignore rule still didnt work.

**Why:** git treats a leading space in a '.gitnignore' pattern as a literal character to match against file paths. No real path starts with a space, so the pattern matched nothing - silently. It looked almost right, which is what made it dangerous.

**The fix:** deleted the stray space, then didn't just trust the file contents - actually tested it: 'mkdir -p data/raw && touch data/raw/test.csv && git status', confriming 'data/' never showed up as untracked

**The concept:** don't just read a config file and assume it's correct - verify its *behavior*.

## Missing a space turned a whole command into a broken URL

**What I ran:** 'git clone httpsL//github.com/Homebrew/brew/opt/homebrew'

**What happaned:** 'remote: Not Found' - git tried to clone a repository that doesn't exist.

**Why:** I left out the space between the source URL and the destination folder. The shell splits what you type into separate arguments by whitespace - no space meant 'git clone' recieved one merged arguemnt (...brew/opt/homebrew') instead of two (a URL, followed by the destination path), and tried to treat the whole thing as a single (non existant) repo address.

**The fix:** added the space back: 'git clone https://github.com/Homebrew/brew /opt/ghomebrew'.

**The concept:** in the terminal, whitespace isn't cosmetic - it's how arguments get separated. One missing space can and will completely change what a command means.

## Editing a config file doesn't affect the shell that's already running

**What I ran:** append a 'brew' PATH setup line to '~/.zprofile', then ran 'brew --version' in the *same* terminal tab.

**What happened:** 'zsh: command not found:brew' - even though the line was now sitting right in there in the file.

**Why:** '.zprofile' (and files like it) are only read once, when a shell starts up. That terminal tab had already started - and already the old empty version of the file - before I appended the new line. Editing the line afterward doesn't reach into an already-running shell and update it. 

**The fix:** either re-run the setup command directly in the current session ('eval "$(/opt/homebrew/bin/brew shellenv)" '), or open a *new* terminal tab, which reads the file fresh and picks up the change immediately.

**The concept:**Shell config files configure *future* shells, not the ones you're sitting in right now, unless you explicitly reload it.
