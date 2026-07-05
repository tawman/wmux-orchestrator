#!/usr/bin/env bash
# sync-status.sh <orch-dir>
# Reconcile per-agent completion into state.json from result-file presence, then roll
# wave + run status up so the live cockpit/dashboard stay current.
#
# Why this exists: in wmux mode agents are spawned as independent interactive processes
# (`wmux agent spawn`), so the SubagentStop hook (on-agent-stop.sh) never fires for them
# and nothing advances their status past "running". The orchestrator loop calls this each
# poll to keep state.json — and therefore the sidebar cockpit — live.
#
# Idempotent and cheap; safe to call on every poll.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/orchestration-state.sh"

ORCH_DIR="$1"
[ -z "$ORCH_DIR" ] && ORCH_DIR=$(find_active_orch)
[ -z "$ORCH_DIR" ] && exit 0
[ -f "$ORCH_DIR/state.json" ] || exit 0

acquire_lock "$ORCH_DIR"
node "$JSON_TOOL" reconcile "$ORCH_DIR/state.json" "$ORCH_DIR" >/dev/null
release_lock "$ORCH_DIR"
