# Local Fork Release Workflow (`production/local`)

> Lives only on `production/local` of the `tawman/wmux-orchestrator` fork. Mirrors
> the versioning approach used by the wmux app fork (`tawman/wmux`), adapted for a
> Claude Code plugin (no Electron/build/updater machinery).

## Versioning convention

**`<upstream-base>-local.<N>`** — currently `0.1.1-local.1` (upstream base `0.1.1`,
from tag `v0.1.1`). `N` resets to 1 when the upstream base changes.

Two version fields — keep them **identical**:
- **`.claude-plugin/plugin.json` `version`** — *functional*. wmux's
  `claude-context.ts` (`ensureOrchestratorPlugin`) reads it to install the plugin
  into `~/.claude/plugins/cache/wmux-orchestrator/{version}/`, register it in
  `installed_plugins.json`, and decide when to reinstall. A `-local.N` value gives
  your local plugin a distinct cache dir. *(One-time check: confirm Claude Code
  loads a plugin whose version is a semver prerelease.)*
- **`package.json` `version`** — cosmetic/source identity. (Was drifted at `0.1.0`;
  realigned to the plugin.json base.)

## Coupling with the wmux app

The orchestrator that actually **runs** is the copy wmux bundles at
`wmux-fork/resources/wmux-orchestrator/`. A bump here versions the *source* and the
fork release notes; to make it take effect in the running plugin, sync this repo's
contents into `wmux-fork/resources/wmux-orchestrator/` and let wmux reinstall it
(or rebuild/ship the wmux app). Keep the bundled copy's `plugin.json` version in
step with this repo.

## Branch & PR hygiene

Same as the app fork: `master` mirrors upstream; feature work is `feature/*` off
`master`, PR'd into `production/local`; the `-local.N` bump lives only on
`production/local`, never on feature branches headed upstream.

## Per-release steps

Run in `C:\git\wmux-orchestrator-fork` on `production/local`:

1. **Bump** both version fields to the next `-local.N` (keep them identical), commit.
2. **Tag**: `git tag v0.1.1-local.1` (first release; the version is already set).
   Subsequent: bump then tag the new value.
3. **Push**: `git push origin production/local --follow-tags`.
4. **Publish notes on the fork**:
   ```bash
   gh release create v0.1.1-local.1 --repo tawman/wmux-orchestrator \
     --target production/local --generate-notes --notes-start-tag v0.1.1
   ```
   No binary to attach (plugin is source files); optionally attach a tarball. No
   `latest.yml` — there is no auto-update feed.

## Syncing upstream

1. `git fetch upstream`
2. `git checkout master && git merge --ff-only upstream/master && git push origin master`
3. `git checkout production/local && git merge master` — on version conflicts, take
   the new upstream base and reset to `<new-base>-local.1` in **both** files.
