## Terminal & Git August 28th 2026: Mistakes I Actually Made Building This

I'm learning the terminal, git and SQL from scratch by building this project. Rather than write a tutorial pretending I got it on the first try, this is a log of the real mistakes I hit - what I ran, what broke, why it broke, and how I fixed it. If you're new to this too, you might find yourself in the same situation but that is part of the learning process.

### "Nothing Happened" usually means it worked

My first real confusion: I ran `mkdir` to make a folder and... nothing printed. I assumed there had to have been a failure. 

**The concept:** most Unix commands are silent on success and only speak up when something's wrong - the opposite of a GUI, where every action gets a confirmation popup. `mkdir`, `cd`, `git add`, `chown` - all silent when they work. The way I felt better was to prove they worked. This way to *prove* something worked isn't to expect an output. it's to check state afterwards (`pwd` to confirm location, `ls` to confirm a file exists, `git status` to confirm a stage happened and so forth).

### The .gitignore line that ate my pattern

**What I ran:** typed a `.gitignore` in `nano`, including a comment followed by a pattern (`data/raw/`) meant to be its own line.

**What happened:** `git status` showed my "Private" data folder as untracked - meaning it wasn't actually being ignored. Normally fine if the name of the file isn't ignore.

**Why:** in `gitignore` (and most config formats), a line starting with `#` is a comment, and *everything after it is on the same line* is part of the comment. I never pressed Enter between the comment and the pattern - the terminals visual word-wrap mode made it look like two lines on screen but it in fact one real line underneath.

**the fix:** reopened it in `nano`, placed the cursor right before the pattern, pressed Enter to create a real line break, then verified with `cat -n .gitignore` (the `-n` numbers each line, making it obvious whether each pattern actually has its own line).

**The concept:** a new line only exists where you specifically Enter/Return - visual wrapping in the terminal is not a real line break.

### The one-character bug: a leading space

**What I ran:** the fixed line-merge above, but the cursor landed one character off when I split the line. 

**What happened:** `cat -n` showed` data/raw` - a leading space before the pattern - and the ignore rule still didnt work.

**Why:** git treats a leading space in a `.gitnignore` pattern as a literal character to match against file paths. No real path starts with a space, so the pattern matched nothing - silently. It looked almost right, which is what made it dangerous.

**The fix:** deleted the stray space, then didn't just trust the file contents - actually tested it: `mkdir -p data/raw && touch data/raw/test.csv && git status`, confirming `data/` never showed up as untracked

**The concept:** don't just read a config file and assume it's correct - verify its *behavior*.

### Missing a space turned a whole command into a broken URL

**What I ran:** `git clone https://github.com/Homebrew/brew/opt/homebrew`

**What happened:** `remote: Not Found` - git tried to clone a repository that doesn't exist.

**Why:** I left out the space between the source URL and the destination folder. The shell splits what you type into separate arguments by whitespace - no space meant `git clone` received one merged argument (`...brew/opt/homebrew`) instead of two (a URL, followed by the destination path), and tried to treat the whole thing as a single (nonexistent) repo address.

**The fix:** added the space back: `git clone https://github.com/Homebrew/brew /opt/homebrew`.

**The concept:** in the terminal, whitespace isn't cosmetic - it's how arguments get separated. One missing space can and will completely change what a command means.

### Editing a config file doesn't affect the shell that's already running

**What I ran:** append a `brew` PATH setup line to `~/.zprofile`, then ran `brew --version` in the *same* terminal tab.

**What happened:** `zsh: command not found: brew` - even though the line was now sitting right there in the file.

**Why:** `.zprofile` (and files like it) are only read once, when a shell starts up. That terminal tab had already started - and already had the old empty version of the file - before I appended the new line. Editing the line afterward doesn't reach into an already-running shell and update it. 

**The fix:** either re-run the setup command directly in the current session (`eval "$(/opt/homebrew/bin/brew shellenv)" `), or open a *new* terminal tab, which reads the file fresh and picks up the change immediately.

**The concept:** Shell config files configure *future* shells, not the ones you're sitting in right now, unless you explicitly reload it.

## Session 2 - SQL & SQLite

### The unquoted string in a CHECK constraint

**What I ran:** typed a `CHECK (status IN (...))` constraint listing allowed status values in `schema.sql`.

**What happened:** `sqlite3 db/job_applications.db < sql/schema.sql` threw a parse error the moment I tried to build a database.

**Why:** one value in the list, `withdrawn`, was missing its opening quote - it read `withdrawn'` instead of `'withdrawn'`. A closing quote with no matching opening quote just starts an unterminated string.

**The fix:** added the missing `'`, re-ran the build, confirmed with `cat -n schema.sql`.

**The concept:** SQL string literals need a quote on both ends, no exceptions - and unlike some earlier mistakes, this one *does* throw an error immediately, so its actually one of the easier bugs to catch.

### The invisible bug: a space inside a quoted string

**What I ran:** fixed the missing quote above, but typed `' withdrawn'` instead of `'withdrawn'` - a stray space landed *inside* the quotes this time, not outside them.

**What happened:** the table built with zero errors. Looked completely fine. The bug was invisible until later, the first time I'd try to insert or match on the value `'withdrawn'` - which would fail the CHECK constraint, because the only value actually allowed was `' withdrawn'` (with a leading space), a different string as far as SQL is concerned.

**Why this one's worse than the last one:** it's syntactically perfect SQL. Nothing complains at creation time. The two strings look nearly identical to the eye.

**The fix:** deleted the stray space, rebuilt, and started actually reading `.schema` output character-by-character instead of skimming it.

**The concept:** a bug that produces no error is more dangerous than one that does - "it ran without complaining" is not the same as "it's correct."

### Schema first, reality second

**What happened:** I designed `applications` assuming every row represented a job I'd already applied to (`date_applied NOT NULL`, `status` limited to `applied/interviewing/offer/rejected/withdrawn`). Then I got a real list of companies I was still *researching*, not applying to yet - and the schema had no way to represent that state at all; inserting one would've either violated the `NOT NULL` constraint or forced a lie (`status = 'applied'` when it wasn't true).

**The fix:** added `'researching'` to the allowed status values and dropped the `NOT NULL` on `date_applied`. Cheap to fix because the table was still empty - rewrote `schema.sql` and rebuilt from scratch. 

**The concept:** a schema is a hypothesis about your data, not a fact. The first version is basically always wrong in some way you can't predict until real data shows up - the skill is noticing the mismatch and fixing it early, before it's expensive to fix.

### ALTER TABLE vs. starting over

**What happened:** needed to add an `employment_type` column, but this time the table already had 11 real rows in it - deleting and rebuilding the database would've thrown that data away.

**The fix:** `ALTER TABLE applications ADD COLUMN employment_type TEXT DEFAULT 'unspecified' CHECK (...)` - modifies the table's structure in place. Every existing row automatically got `'unspecified'` for the new column (the `DEFAULT`), no manual backfilling needed.

**The follow-up mistake:** after altering the live database, I forgot that `schema.sql` - the file that's supposed to be the source of truth - didn't know about the new column at all. Anyone rebuilding from that file would've gotten a table missing `employment_type`, silently different from the real one.

**The concept:** changing a live database's structure and updating your schema *source file* are two separate steps. Skipping the second one means your documentation quietly lies about what the database actually looks like.

### A trailing comma before FROM

**What I ran:** `...> SELECT id, company_name, location, status, employment_type, FROM applications;`

**What happened:** `Parse error: near "FROM": syntax error`, with SQLite pointing an arrow at almost exactly the right spot.

**Why:** a comma after a column name means "expect another column name next." `FROM` isn't a column - it's the start of the next clause - so the parser broke exactly where the comma promised something that never came.

**The fix:** removed the trailing comma.

**The concept:** trailing commas are fine (even preferred) in some languages; in SQL, a comma always means "more items of this kind are coming," so one at the very end of a list is always wrong.

### Alphabetical isn't what you think it is

**What happened:** `ORDER BY company_name` put `"mgm technology partners"` dead last, after `"Zalando"` - which looks alphabetically wrong at a glance.

**Why:** SQLite's default text comparison is byte-by-byte on the underlying character codes (ASCII), not human alphabetical order. Every uppercase letter has a lower code than every lowercase letter (`Z`= 90, `m`=109), so any capitalized name sorts before any lowercase one, regardless of the actual letters.

**The fix:** `ORDER BY company_name COLLATE NOCASE` - tells SQLite to compare case-insensitively for this sort.

**The concept:** "sorted" has more than one correct meaning depending on what's doing the comparing - computers default to comparing raw character codes unless you explicitly ask for something more human.

### Stuck inside a program that won't exit the way I expected

**What I ran:** `litecli docs/terminal-reference.md` — meant to test a colorized SQL tool, but pointed it at a markdown file instead of an actual database.

**What happened:** it printed `file is not a database` (correct — a `.md` file obviously isn't one) but dropped me into its interactive prompt anyway instead of just exiting. Typing `.quit` (which works in `sqlite3`) got `dot command not implemented` — I was stuck.

**Why:** `litecli` isn't `sqlite3` — different tool, different exit convention. It uses plain words like `exit`, not dot-commands.

**The fix:** `Ctrl+D` — sends an "end of input" signal that exits almost any interactive program cleanly, regardless of what that specific tool calls its quit command.

**The concept:** when you're stuck inside an unfamiliar interactive program and don't know its specific exit command, `Ctrl+D` is the closest thing to a universal escape hatch — works across `sqlite3`, `litecli`, `python`, and most REPLs you'll ever run into.

### A correct PATH that still gave the wrong answer

**What happened:** installed a newer `nano` via Homebrew, confirmed `$PATH` correctly listed `/opt/homebrew/bin` before `/usr/bin` — and `which nano` *still* reported the old system version.

**Why:** the shell caches ("hashes") where it last found a command, so it doesn't have to re-search the entire `$PATH` on every single use. I'd already run `nano` many times earlier in this session, back when only the old version existed — the shell kept using that cached answer even after a newer one appeared earlier in the PATH.

**The fix:** `hash -r` — clears the cache, forces the shell to actually re-search `$PATH` next time.

**The concept:** `$PATH` being correct doesn't guarantee the shell is currently *using* it correctly — like `.zprofile` only loading at shell startup, command hashing is another case of "state that doesn't auto-refresh just because the underlying truth changed."
