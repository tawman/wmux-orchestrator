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

# Once reconcile rolls the run up to "complete", stamp the workspace's sidebar
# badge so it stops reading "Running" and signals the human that the run awaits
# review — the coordinator "owns the status when work is done" without having to
# remember to. Fires once (marker file), only in wmux mode, only when a
# workspaceId was recorded (Phase 6b). Needs the `set-status --workspace` verb
# (wmux fork >= 0.19.0-local.1); on older apps it's a harmless no-op.
if [ ! -f "$ORCH_DIR/.status-badge-set" ]; then
  RUN_STATUS=$(read_state "$ORCH_DIR" '.status')
  if [ "$RUN_STATUS" = "complete" ]; then
    WS_ID=$(read_state "$ORCH_DIR" '.workspaceId')
    if [ -n "$WS_ID" ] && [ "$WS_ID" != "null" ] && command -v wmux >/dev/null 2>&1; then
      wmux set-status --workspace "$WS_ID" --state idle \
        --text "orchestration complete — awaiting review" >/dev/null 2>&1 \
        && touch "$ORCH_DIR/.status-badge-set"
    fi
  fi
fi
