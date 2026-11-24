# NVIM-2 — Pomodoro pets

Status: implemented and verified within the bounds in CHANGES.md. User approved implementation, local commit and feature-branch push.

Problem: a compact desktop and LazyVim focus timer should reuse existing pet artwork and audio.
Scope: Linux/Kitty Bash launcher, local Lazy plugin, automatic 25/5/15 cycles, four focus sessions
per long break, music, alerts and independent desktop/editor persistence. No daemon, plugin upgrades,
PetsADHD source changes, cross-process synchronization or separate plugin repository.

AC-1: Deadline countdown, pause/resume/reset and long break after four focus completions.
AC-2: Existing pets animate; resizing, themes, hide/reopen preserve timer and user buffers.
AC-3: Focus-only music, one alert per boundary, independent mute and complete job cleanup.
AC-4: Atomic save, paused restore, corrupt-state preservation and exclusive state ownership.
AC-5: Launch from arbitrary directories and paths with spaces; validate desktop entries and dependencies.
AC-6: Lazy command loading and all five existing user diffs preserved.

Decision NVIM-2-D1 (accepted and implemented): keep the Lua engine independent of UI,
reuse petsadhd.pets.render and petsadhd.audio through small adapters. Alternative: extend PetsADHD
or duplicate rendering in Bash. Reuse keeps one artwork source and avoids another repository release,
at the cost of coupling to its public Lua functions. Verify both locally available dependency revisions;
reconsider extraction if other configurations need independent distribution. Bash owns launching only.

First launch runs; restored sessions pause. Hidden editor timers continue. Reset returns to paused focus.
Each phase starts at full duration after a late callback (no catch-up alert storm). Linux monotonic time
excludes suspend. State keys: desktop or editor working-directory hash; a second owner fails clearly.
State writes every five seconds and on controls/transitions; crash loss is bounded by that interval.
Music defaults to the installed PetsADHD soundtrack; internet failure must not stop the timer.


Implementation mapping: timer.lua → AC-1; init.lua plus existing pets renderer → AC-2/6;
audio.lua → AC-3; state.lua with flock ownership → AC-4; bin/, bootstrap and installer → AC-5.
Tests live under tests/ and are orchestrated by scripts/test-pomodoro.sh.

Ownership uses an stdin-held flock child rather than PID lockfiles. The kernel releases ownership
after crashes without risking deletion of another writer's lock; the lock file itself may remain.
Close resumes/terminates owned music through the existing PetsADHD lifecycle and releases the lock.
Timer snapshots retain session durations; reset applies new configured durations. Late callbacks start
one full next phase rather than replaying missed phases. Unavailable streams require an explicit music
toggle to retry, avoiding retries on every animation tick. No new dependency revisions or data migration.

Remaining tradeoff: Linux-only ownership and playback signals. Reconsider for a macOS/Windows request.
Do not assume visual/audio backend success proves a listener heard the output.
