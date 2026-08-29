# Terminal Command Reference

Every command I've used so far, what it does, and why. Reference Doc, not a tutorial - see 'docs/terminal-lessons.md' for the mistakes and stories.

## Navigating the filesystem

| Command | What it does |
|---|---| 
| `pwd` | Print Working Directory - prints the full path of where you currently are |
| `ls` | List the contents of the current directory |
| `ls -a` | Lists all contents, including hidden files (anything starting with `.`) |
| `ls -l` | Lists in long format; permissions, size, owner, group, modified date |
| `ls -la` | Combines both; all files and long format |
| `cd <path>` | Change directory - move into `<path>` |
| `cd ~` | `~` is shorthand for your home directory |
| `mkdir <name>` | Make a new directory |
| `mkdir -p <path>` | Make a directory, creating any missing parent directories too, no error if already exists |
| `touch <file>` | create an empty file, or update its modified timestamp if it already exists |
| `rm <file>` | Remove a file (permanent - no trash/recycle bin |
| `rm -r <dir>` | Remove a directory and everything inside it (`-r` = recursive; required for directories) |

## Viewing and editing files 

| Command | What it does |
|---|---|
| `cat <file>` | Print a file's full contents to the terminal |
| `cat -n <file>` | Same, but with line numbers - useful for spotting merged or missing lines |
| `less <file>` | Open a file in a scrollable pager instead of dumping it all at once (`Space`=page down, `b`=page up (back), `q`=quit) |
| `nano <file>` | Open a file in the nano text editor (What this is being written in). `Ctrl+O`=write out (save), `Enter`= confirm filename, `Ctrl+X` = exit |

## Redirection, piping, substitution
| Syntax | What it does |
|---|---|
| `>` | Redirect output to a file, **overwriting** it entirely |
| `>>` | Redirect output to a file **appending** to the end (safe - doesn't destroy existing content) |
| `$(command)` | Command subsitution - run `command`, and drop its output directly into the surrounding command as text |
| `&&` | Run the next command only if the previous one succeeded (exit code 0) |

## Git basics

|Command | What it does |
|---|---|
| `git init` | Turn the current folder into a git repository (creates a hidden `.git/` folder) |
| `git status` | Show what's staged, unstaged, and untracked right now |
| `git add <file>` | Stage a file - mark it to be included in the next commit |
| `git commit -m "message"` | Save a permanent snapshot of everything staged, with a one-line message |
| `git commit --amend -m "message"` | Replaces the most recent commit`s message/content instead of creating a new one - only safe before pushing/sharing it |
| `git log` | Show commit history: author, date, message, and each commit's unique hash |
| `git remote -v` | List configured remotes (e.g. `origin`) and their URLs, for fetch and push |
| `git push` | Upload local commits to the remote |
| `git clone <url> <dest>` | Copy a remote repository down to `<dest>` locally (two separate arguements - a missing space merges them into a broken URL) |

## .gitignore syntax notes

- Lines starting with '#' are comments - nothing else should share that label
- A pattern like `*.db`  ignores any files in `.db`, anywhere
- A pattern like data/raw ignores that specific directory
- **Leading/trailing spaces are read literally** - an accidental leading space breaks the pattern silently, since no real file starts with a space

## Permissions & ownership

| Command | What it does |
|---|---|
| `sudo <command>` | Run `<command>` as the superuser/root - needed for actions on system-level directories |
| `chown -R <user> <path>` | Change ownership of `<path>` (recursively, `-R`) to `<user>` |
| `whoami` | Print your current username |

## Networking 

| Command | What it does |
|---|---|
| `curl -fsSL <url>` | Fetch `<url>` 's contents. `-f`= fail silently on HTTP errors, `-s`=no progress bar, `-S`=still show real errors, `-L`=follow redirects |
| `curl -fsSL <url> -o <file>` | Same as above, but save to `<file>` instead of printing or piping it |

## Package management (Homebrew)

| Command | What it does |
|---|---|
| `brew install <package>` | Install `<package>` via Homebrew |
| `brew --version` | Confirm Homebrew is installed and check its version |
| `~/.zprofile` | Shell startup file zsh reads once, everytime a new terminal session begins - the right place for permanent PATH/environment setup |

## Github CLI (`gh`)

| Command | What it does |
|---|---|
| `gh --version` | Confirms `gh` is installed and check its version |
| `gh auth login` | Authenticate `gh` with your Github account (interactive prompts) |
| `gh auth status` | Check current authentication state |
| `gh repo create <name> --public\|--private --source --remote=origin --push` | Create a GitHub repo from an existing local repo, link it as `origin`, and push in one command |

## macOS-specific

| Command | What it does |
|---|---|
| `uname -m` | Print CPU architecture (`arm64` = Apple silicon, `x86_64` = Intel) - determines Homebrew install path in my instance |
| `open <url> or <file>` | Open something with its default macOS application (a URL in your browser, a file in whatever normally handles it) |

## SQLite CLI

| Command | What it does |
|---|---|
| `sqlite3 --version` | Confirms SQLite is installed and check its version |
| `sqlite3 <file>` | Open (or create, if it doesn't exist) a database file and drop into an interactive `sqlite` prompt |
| `sqlite3 database.db <  script.sql` | Run every statement in `script.sql` against `database.db`, noninteractively (input redirection) |
| `sqlite3 <file> ".tables"` | List the tables in a database, without opening the interactive shell |
| `.tables` | (inside the interactive shell) same as above |
| `.schema <table>` | Print the exact `CREATE TABLE` statement SQLite has stored for `<table>` - the real source of truth for what a table actually looks like right now |
| `.quit` | Exit the interactive `sqlite>` shell, back to zsh |
| `...>` | The continuation prompt - SQLite is still waiting for a `;` to know your statement is finished; typing `;` by itself abandons/executes whatever's been entered so far |

## SQL: defining tables
| Concept | Syntax / Notes |
|---|---|
| Create a table | `CREATE TABLE name (col1 TYPE, col 2 TYPE, ...);` |
| Storage types | `INTEGER`, `REAL`, `TEXT`, `BLOB`, `NULL` - SQLite uses "type affinity," meaning declared types are a strong hint, not strictly enforced |
| Primary key | `id INTEGER PRIMARY KEY` -auto-generates a unique ID per row |
| Required field | `NOT NULL` - rejects inserts that omit this column |
| Fallback value | `DEFAULT `value'` - used automatically when a column is omitted on insert |
| Restricted allowed values | `CHECK (col IN('a','b','c,'))` - rejects any value that is not in the list |
| Modifiy an existing table | `ALTER TABLE name ADD COLUMN col TYPE DEAFULT 'value';` - adds a column without touching existing rows (SQLite's `ALTER TABLE` is more limited than some db's and doesn't change the nano, so nano will need to be also changed if the table is to be used more than once: no adding `PRIMARY KEY`/`UNIQUE` this way, and `NOT NULL` requires a `DEFAULT` if the table already has rows) |

## SQL: reading and writing data

| Concept | Syntax / Notes |
|---|---|
| Insert a row | `INSERT INTO table (col1, col2) VALUES (val1,val2);` |
| Insert multiple rows at once | `INSERT INTO table (...) VALUES (...),(...),(...);` - comma- separated value groups |
| Escaping an apostrophe in text | Double it: `'Master''s'`-a lone `'` inside a string would end the string early |
| Select Data | `SELECT col1, col2 FROM table;`- `SELECT *` selects all columns |
| Filter rows | `SELECT ... FROM table WHERE condition;` |
| Pattern matching | `WHERE col LIKE '%text%'` - `%` is a wildcard matching any (or no) characters |
| Sort results | `SELECT ... ORDER BY col;` (ascending by default, `DESC` reverses it) |
| Case-insensitive sort | `ORDER BY col COLLATE NOCASE` - otherwise SQLite sorts by raw character code, capitals before lowercase |
| Aggregate/summarize | `SELECT col, COUNT(*) FROM table GROUP BY col;` - collapses rows sharing the same `col` value into one summary row each |
| Rename a computed column | `COUNT(*) AS total` - an alias for the output column's label |

## Shell command caching

| Command | What it does |
|---|---|
| `hash -r` | Clear the shell's cached command locations, forcing a fresh `$PATH` search next time each command is used - needed after installing something new earlier in the PATH than an already-cached version (quite useful after installation) |

## Terminal customization

| Tool/command | What it does |
|---|---|
| `brew install nano` | Installs a modern `nano` with real syntax-highlighting support (macOS's built-in `nano` at `usr/bin/nano` is version 2.0.6 and barely supports it) |
| `~/.nanorc` | `nano`'s own config file, read fresh every time `nano` starts. `include "/opt/homebrew/share/nano/.nanorc"` loads Homebrew's bundled syntax-highlighting definitions (SQL, Markdown, etc.) |
| `litecli <database-file>` | A modern, syntax-highlighted, autocompleted-enabled replacement for the plain `sqlite3` CLI - must be pointed at an actual `.db` file, not a text file |
| `Ctrl+D` | Universal-ish "end of input" signal - exits most interactive REPLs/shells cleanly, regardless of that program's specific quit command |

