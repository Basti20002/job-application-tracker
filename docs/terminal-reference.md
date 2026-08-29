# Terminal Command Reference

Every command I've used so far, what it does, and why. Reference Doc, not a tutorial - see 'docs/terminal-lessons.md' for the mistakes and stories.

## Navigating the filesystem

| Command | What it does |

|---|---| 
| 'pwd' | Print Working Directory - prints the full path of where you currently are |
| 'ls' | List the contents of the current directory |
| 'ls -a' | Lists all contents, including hidden files (anything starting with '.') |
| 'ls -l' | Lists in long format; permissions, size, owner, group, modified date |
| 'ls -la' | Combines both; all files and long format |
| 'cd <path> | Change directory - move into '<path>' |
| 'cd ~' | '~' is shorthand for your home directory |
| 'mkdir <name>' | Make a new directory |
| 'mkdir -p <path>' | Make a directory, creating any missing parent directories too, no error if already exists |
| 'touch <file>' | create an empty file, or update its modified timestamp if it already exists |
| 'rm <file>' | Remove a file (permanent - no trash/recycle bin |
| 'rm -r <dir>' | Remove a directory and everything inside it ('-r' = recursive; required for directories) |

## Viewing and editing files 

| Command | What it does |
|---|---|
| 'cat <file>' | Print a file's full contents to the terminal |
| 'cat -n <file>' | Same, but with line numbers - useful for spotting merged or missing lines |
| 'less <file>' | Open a file in a scrollable pager instead of dumping it all at once ('Space'=page down, 'b'=page up (back), 'q'=quit) |
| 'nano <file>' | Open a file in the nano text editor (What this is being written in). 'Ctrl+O'=write out (save), 'Enter'= confirm filename, 'Ctrl+X' = exit |

## Redirection, piping, substitution
| Syntax | What it does |
|---|---|
| '>' | Redirect output to a file, **overwriting** it entirely |
| '>>' | Redirect output to a file **appending** to the end (safe - doesn't destroy existing content) |
| '$(command)' | Command subsitution - run 'command', and drop its output directly into the surrounding command as text |
| '&&' | Run the next command only if the previous one succeeded (exit code 0) |

## Git basics

|Command | What it does |
|---|---|
| 'git init' | Turn the current folder into a git repository (creates a hidden '.git/' folder) |
| 'git status' | Show what's staged, unstaged, and untracked right now |
| 'git add <file>' | Stage a file - mark it to be included in the next commit |
| 'git commit -m "message"' | Save a permanent snapshot of everything staged, with a one-line message |
| 'git commit --amend -m "message"' | Replaces the most recent commit's message/content instead of creating a new one - only safe before pushing/sharing it |
| 'git log' | Show commit history: author, date, message, and each commit's unique hash |
| 'git remote -v' | List configured remotes (e.g. 'origin') and their URLs, for fetch and push |
| 'git push' | Upload local commits to the remote |
| 'git clone <url> <dest>' | Copy a remote repository down to '<dest>' locally (two separate arguements - a missing space merges them into a broken URL) |

## .gitignore syntax notes

- Lines starting with '#' are comments - nothing else should share that label
- A pattern like *.db' ignores any files in '.db', anywhere
- A pattern like data/raw ignores that specific directory
- **Leading/trailing spaces are read literally** - an accidental leading space breaks the pattern silently, since no real file starts with a space

## Permissions & ownership

| Command | What it does |
|---|---|
| 'sudo <command>' | Run '<command>' as the superuser/root - needed for actions on system-level directories |
| 'chown -R <user> <path>' | Change ownership of '<path>' (recursively, '-R') to '<user>' |
| 'whoami' | Print your current username |

## Networking 

| Command | What it does |
|---|---|
| 'curl -fsSL <url>' | Fetch '<url>' 's contents. '-f'= fail silently on HTTP errors, '-s'=no progress bar, '-S'=still show real errors, '-L'=follow redirects |
| 'curl -fsSL <url> -o <file>' | Same as above, but save to '<file>' instead of printing or piping it |

## Package management (Homebrew)

| Command | What it does |
|---|---|
| 'brew install <package>' | Install '<package>' via Homebrew |
| 'brew --version' | Confirm Homebrew is installed and check its version |
| '~/.zprofile' | Shell startup file zsh reads once, everytime a new terminal session begins - the right place for permanent PATH/environment setup |

##Github CLI ('gh')

| Command | What it does |
|---|---|
| 'gh --version' | Confirms 'gh' is installed and check its version |
| 'gh auth login' | Authenticate 'gh' with your Github account (interactive prompts) |
| 'gh auth status' | Check current authentication state |
| 'gh repo create <name> --public\|--private --source --remote=origin --push' | Create a GitHub repo from an existing local repo, link it as 'origin', and push in one command |

##macOS-specific

| Command | What it does |
|---|---|
| 'uname -m' | Print CPU architecture ('arm64' = Apple silicon, 'x86_64' = Intel) - determines Homebrew install path in my instance |
| 'open <url> or <file>' | Open something with its default macOS application (a URL in your browser, a file in whatever normally handles it) |
