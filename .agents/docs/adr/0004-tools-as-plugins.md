# Tools as self-describing plugins; profiles as tool selections

Each tool is a self-contained plugin in `src/tools/<id>/` (`tool.json` metadata + `tool.sh` exposing `check`/`install`), and a profile (`src/profiles/<id>.json`) is just a list of tool ids; the core resolves the dependency graph from the selected tools. Descriptors are JSON, read with the vendored `jq`. We chose this so that adding a tool or building a new profile never requires touching the core.

## Considered Options

- **Plain-text descriptors**: initially preferred to avoid a JSON parser, then rejected once the `jq` bootstrap problem was solved by vendoring `jq` — JSON gives richer, validated structure for free.
- **A monolithic, hard-coded checklist**: rejected — it couples every tool to the core and makes profiles impossible to compose.
