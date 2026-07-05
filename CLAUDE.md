# wmux-orchestrator — Development Guide

Claude Code plugin (shell scripts + skills + hooks) that decomposes dev tasks into parallel agents in
wmux panes. This repo is **tawman's fork** of `amirlehmam/wmux-orchestrator`, run from local builds of
the `production/local` branch.

## Fork Build on production/local

Follow these tenets when working in this fork even if the local `wmux` skill isn't installed on your
machine.

**Branches**
- `master` — pure mirror of upstream `amirlehmam/wmux-orchestrator`. Never merge fork features into
  it; it's only the clean base for upstream PRs and pulling upstream changes.
- `production/local` — long-lived integration branch and the **default branch**; what we run.
- Feature branches by upstreamability: `feature/orch-<slug>` off `master` (upstream-candidate);
  `feature/local-<slug>` off `production/local` (local-only).

**Merging features → release notes**
- Land features on `production/local` via a **fork PR** (`gh pr create --base production/local`),
  merged on GitHub — NOT a local `git merge` — so GitHub `--generate-notes` groups the changelog by
  PR. (PR-merge commits are GitHub-signed: "Verified" on GitHub, `%G?`=`E` locally — normal.)

**Versioning (semver)**
- `<upstream-base>-local.<N>` (e.g. `0.1.1-local.1`), kept **identical** in two files:
  `.claude-plugin/plugin.json` (functional — drives the `~/.claude/plugins/cache/…/{version}/`
  install) and `package.json` (cosmetic). `<N>` resets when the upstream base changes.

**How the plugin is consumed locally**
- Registered as a Claude Code **local-directory marketplace** on this working tree:
  `claude plugin marketplace add C:\git\wmux-orchestrator-fork`. Pick up new `production/local`
  commits with `claude plugin marketplace update wmux-orchestrator` (re-copies the tree into the
  plugin cache; no GitHub round-trip). Do **not** junction the cache dir — use the marketplace CLI.

**Releases (fork, for notes)**
- No build step (source files). Push a `v<version>` tag on `production/local` → the
  `.github/workflows/release.yml` workflow creates a GitHub Release with generated notes, or run
  `gh release create v<version> --repo tawman/wmux-orchestrator --generate-notes` manually. Runbook:
  `docs/LOCAL-RELEASE.md`.

**Coupling with the wmux app**
- The plugin the wmux app *ships* lives in `wmux-fork/resources/wmux-orchestrator/`; this standalone
  repo is the dev source consumed via the marketplace above. Keep the two in step when it matters.

**Upstream sync — inspect BEFORE it reaches production/local (security gate)**
Upstream orchestrator is dormant but still untrusted; isolate, scan, then merge. Never
`git pull upstream` straight into `production/local`.
1. **Isolate:** `git fetch upstream` → `git checkout master` → `git merge --ff-only upstream/master`.
2. **Review the incoming diff on `master`** — this plugin is shell + markdown that runs on your
   machine, so read `git log -p master@{1}..master` for: new network calls
   (`curl`/`wget`/`Invoke-WebRequest`), `curl | sh` / `base64 -d | sh` / `eval`, changes to
   `hooks/*.json` and `scripts/*.sh` / `launch-agent.js` (esp. anything touching `~/.claude`,
   credentials, or `rm -rf`), and prompt-injection-style instructions in `skills/**/*.md` or
   `agents/*.md`. Run `gitleaks git --log-opts="master@{1}..master"` (if installed).
3. **Merge only if clean:** merge `master` into `production/local` and reset the version to
   `<new-base>-local.1` in both version files.

**Authorship**
- Commits are the fork owner's, SSH-signed. Do **not** add AI/Claude attribution to commits, PR
  descriptions, or comments.
