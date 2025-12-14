-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function lumen_commit_push()
  -- constants
  local exit_success = 0
  local exit_git_precommit_fail = 1
  local exit_git_error = 128
  local defer_delay_ms = 100

  local icon_stage = ""
  local icon_cancel = ""
  local icon_push = ""
  local icon_warning = ""
  local icon_commit = ""
  local icon_retry = "󰑓"

  -- state preservation
  local state = {
    last_message = nil,
    should_push = false,
  }

  local function log(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO)
  end

  local function git_staged_check()
    local result = vim.system({ "git", "diff", "--cached", "--quiet" }):wait()
    return result.code ~= exit_success
  end

  local function run_precommit_hooks()
    log("running pre-commit hooks (dry-run)...")
    local result = vim.system({ "git", "hook", "run", "pre-commit" }):wait()

    if result.code ~= exit_success then
      -- hooks failed, show error
      local stderr = result.stderr or ""
      log(
        string.format("%s pre-commit hooks failed => %s", icon_warning, stderr ~= "" and stderr or "check output"),
        vim.log.levels.ERROR
      )
      return false
    end

    log("pre-commit hooks passed")
    return true
  end

  local function stage_files(callback)
    vim.ui.select({ "Yes", "No" }, {
      prompt = "no staged changes => stage all?",
      format_item = function(item)
        return item == "Yes" and string.format("%s stage all", icon_stage) or string.format("%s cancel", icon_cancel)
      end,
    }, function(choice)
      if choice ~= "Yes" then
        return log("operation canceled", vim.log.levels.INFO)
      end

      vim.system({ "git", "add", "-A" }, {}, function(obj)
        vim.schedule(function()
          if obj.code == exit_success then
            if git_staged_check() then
              log("changes staged successfully")
              callback()
            else
              log("no changes to commit after staging", vim.log.levels.WARN)
            end
          else
            log(string.format("git add failed => code=%d stderr=%q", obj.code, obj.stderr or ""), vim.log.levels.ERROR)
          end
        end)
      end)
    end)
  end

  local function push_changes()
    vim.system({ "git", "push" }, {}, function(obj)
      vim.schedule(function()
        if obj.code == exit_success then
          log(string.format("%s push successful", icon_push), vim.log.levels.INFO)
        else
          log(
            string.format("%s push failed => code=%d stderr=%q", icon_warning, obj.code, obj.stderr or ""),
            vim.log.levels.ERROR
          )
        end
      end)
    end)
  end

  local function commit_changes(message, should_push)
    -- preserve state before attempting commit
    state.last_message = message
    state.should_push = should_push

    -- open terminal for git commit (handles gpg signing)
    vim.cmd("belowright split")
    local term_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, term_bufnr)

    vim.fn.termopen(string.format("git commit -m %s", vim.fn.shellescape(message)), {
      on_exit = function(_, code)
        vim.schedule(function()
          vim.cmd("close")

          if code == exit_success then
            log(string.format("%s commit successful", icon_commit), vim.log.levels.INFO)
            -- clear state on success
            state.last_message = nil
            state.should_push = false

            if should_push then
              push_changes()
            end
          elseif code == exit_git_precommit_fail or code == exit_git_error then
            -- commit failed => offer retry with preserved message
            local err_type = code == exit_git_precommit_fail and "pre-commit hook" or "git commit (exit 128)"
            log(string.format("%s %s failed => message preserved", icon_warning, err_type), vim.log.levels.ERROR)

            vim.ui.select({ "retry commit", "fix and retry", "cancel" }, {
              prompt = "commit failed => choose action:",
              format_item = function(item)
                if item == "retry commit" then
                  return string.format("%s retry with same message", icon_retry)
                elseif item == "fix and retry" then
                  return string.format("%s fix issues and retry", icon_stage)
                else
                  return string.format("%s cancel", icon_cancel)
                end
              end,
            }, function(choice)
              if choice == "retry commit" then
                commit_changes(state.last_message, state.should_push)
              elseif choice == "fix and retry" then
                log(string.format("fix issues, then use message: %q", state.last_message), vim.log.levels.INFO)
                -- optionally re-stage after fixes
                vim.ui.select({ "Yes", "No" }, {
                  prompt = "re-stage all files after fixes?",
                }, function(restage)
                  if restage == "Yes" then
                    vim.system({ "git", "add", "-A" }, {}, function(obj)
                      vim.schedule(function()
                        if obj.code == exit_success then
                          commit_changes(state.last_message, state.should_push)
                        else
                          log("git add failed", vim.log.levels.ERROR)
                        end
                      end)
                    end)
                  else
                    commit_changes(state.last_message, state.should_push)
                  end
                end)
              else
                log(
                  string.format("%s commit canceled => message: %q", icon_cancel, state.last_message),
                  vim.log.levels.INFO
                )
              end
            end)
          else
            log(string.format("%s commit failed => code=%d", icon_warning, code), vim.log.levels.ERROR)
          end
        end)
      end,
    })

    vim.cmd("startinsert")
  end

  local function edit_commit_message(message)
    vim.ui.input({
      prompt = "edit commit message:",
      default = message,
    }, function(final_msg)
      if not final_msg or final_msg:match("^%s*$") then
        return log(string.format("%s commit aborted => empty message", icon_warning), vim.log.levels.WARN)
      end

      vim.ui.select({ "commit only", "commit and push" }, {
        prompt = "choose action:",
        format_item = function(item)
          return item == "commit only" and string.format("%s commit only", icon_commit)
            or string.format("%s commit and push", icon_push)
        end,
      }, function(choice)
        if choice == "commit only" then
          commit_changes(final_msg, false)
        elseif choice == "commit and push" then
          commit_changes(final_msg, true)
        else
          log(string.format("%s operation canceled", icon_cancel), vim.log.levels.INFO)
        end
      end)
    end)
  end

  -- main workflow
  if not git_staged_check() then
    return stage_files(function()
      vim.defer_fn(lumen_commit_push, defer_delay_ms)
    end)
  end

  -- check if we have a preserved message from previous failure
  if state.last_message then
    vim.ui.select({ "use preserved message", "generate new message", "cancel" }, {
      prompt = "previous commit failed => reuse message?",
      format_item = function(item)
        if item == "use preserved message" then
          return string.format("%s reuse: %q", icon_retry, state.last_message)
        elseif item == "generate new message" then
          return string.format("%s generate new (costs resources)", icon_commit)
        else
          return string.format("%s cancel", icon_cancel)
        end
      end,
    }, function(choice)
      if choice == "use preserved message" then
        edit_commit_message(state.last_message)
      elseif choice == "generate new message" then
        state.last_message = nil -- clear old message
        vim.defer_fn(lumen_commit_push, 10) -- restart workflow
      else
        log("operation canceled", vim.log.levels.INFO)
      end
    end)
    return
  end

  log("generating commit message with lumen...")
  vim.system({ "lumen", "draft" }, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= exit_success then
        return log(
          string.format("%s lumen draft failed => code=%d stderr=%q", icon_warning, obj.code, obj.stderr or ""),
          vim.log.levels.ERROR
        )
      end

      local msg = obj.stdout and vim.trim(obj.stdout) or ""
      if msg == "" then
        return log(string.format("%s lumen returned empty message", icon_warning), vim.log.levels.ERROR)
      end

      edit_commit_message(msg)
    end)
  end)
end

vim.keymap.set("n", "<leader>ga", lumen_commit_push, { desc = "ai commit and push (lumen)" })
