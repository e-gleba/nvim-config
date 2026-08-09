-- prepare-commit-msg hook, in Lua.
--
-- Git cannot run this file directly (hooks must be named exactly
-- `prepare-commit-msg` and are executed by sh), so the sibling shim
-- hooks/prepare-commit-msg runs it via `nvim -l`. Written in pure Lua
-- (no vim API), so a standalone `lua`/`luajit` interpreter works too.
--
-- What it does: if the current branch name contains a Jira-style key
-- (e.g. feature/PROJ-123-fix), prepend "PROJ-123: " to the commit message.
-- No auth, no API, works offline. Silently no-ops when there is no key.
--
-- Git passes: $1 = commit message file, $2 = source
-- (message|template|merge|squash|commit), $3 = commit SHA (-c/-C/amend).

-- Never block a commit unless the message file itself is unwritable.
local function pass()
    os.exit(0)
end

local msg_file = arg[1]
local source = arg[2] or ''

if not msg_file then
    pass()
end

-- Skip merge/squash commits and -c/-C/--amend (message already exists).
if source == 'merge' or source == 'squash' or source == 'commit' then
    pass()
end

local pipe = io.popen('git branch --show-current 2>/dev/null')
if not pipe then
    pass()
end
local branch = pipe:read('*l') or ''
pipe:close()

-- Detached HEAD: no branch, no key.
if branch == '' then
    pass()
end

-- Jira-style key: uppercase project, dash, number (PROJ-123).
local key = branch:match('([A-Z][A-Z0-9]*%-%d+)')
if not key then
    pass()
end

local file = io.open(msg_file, 'r')
if not file then
    pass()
end
local message = file:read('*a') or ''
file:close()

-- Idempotent: never double-prefix.
if message:sub(1, #key + 1) == key .. ':' then
    pass()
end

local out = io.open(msg_file, 'w')
if not out then
    os.exit(1) -- real I/O failure: block loudly, not silently
end
out:write(key .. ': ' .. message)
out:close()
