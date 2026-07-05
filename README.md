# wmux-orchestrator

Claude Code plugin that decomposes complex dev tasks into parallel agents coordinated through dependency-aware waves with automated review.

**With wmux**: Each agent gets its own visible terminal pane — watch them work in real-time.
**Without wmux**: Falls back to native Claude Code subagents.

## Local build (production/local)

This is **tawman's fork** of [amirlehmam/wmux-orchestrator](https://github.com/amirlehmam/wmux-orchestrator),
run from the `production/local` branch. We consume the plugin directly from this working tree via a
Claude Code **local-directory marketplace** (not the upstream GitHub marketplace):

```bash
# one-time: register this fork as the wmux-orchestrator marketplace
claude plugin marketplace add C:\git\wmux-orchestrator-fork

# after pulling new production/local commits, refresh the plugin cache:
claude plugin marketplace update wmux-orchestrator
```

Versioning is `<upstream-base>-local.<N>`, kept in sync across `package.json` and the functional
`.claude-plugin/plugin.json`; fork releases are cut on `production/local` for release notes — see
[`docs/LOCAL-RELEASE.md`](docs/LOCAL-RELEASE.md).

**📖 For install, usage, how-it-works, and requirements, see the [upstream wmux-orchestrator README](https://github.com/amirlehmam/wmux-orchestrator/blob/master/README.md).**

## License

MIT
