# Sysmantic manual

Welcome! This manual shows you how to use Sysmantic on your SysML v2 and KerML models. To install
it, see the [README](README.md).

## Contents

- [Getting started](#getting-started)
  - [Your model](#your-model)
  - [In VS Code](#in-vs-code)
  - [With AI agents](#with-ai-agents)
  - [On the command line](#on-the-command-line)
- [Using Sysmantic](#using-sysmantic)
  - [Check your model](#check-your-model)
  - [Compute values and verdicts](#compute-values-and-verdicts)
  - [Ask questions](#ask-questions)
  - [See it as a graph](#see-it-as-a-graph)
  - [See it in the standard views](#see-it-in-the-standard-views)
  - [Style the views](#style-the-views)
  - [Work in a notebook](#work-in-a-notebook)
  - [Change the model](#change-the-model)
  - [Export and import](#export-and-import)
  - [Use it from programs](#use-it-from-programs)
  - [Check it in CI](#check-it-in-ci)
- [Reference](#reference)
  - [Commands](#commands)
  - [MCP tools](#mcp-tools)
  - [VS Code commands and settings](#vs-code-commands-and-settings)
  - [Query vocabulary](#query-vocabulary)
  - [Settings](#settings)

## Getting started

Open your model and use it from wherever you work.

### Your model

Your model is a folder of `.sysml` and `.kerml` files, and Sysmantic reads it with no setup.

The standard libraries are built in. One Sysmantic server per model keeps it loaded and current,
so VS Code, agents and commands all see the same model, unsaved edits included, and answer in
milliseconds.

- **The model's folder** is the nearest one upward with a `sysmantic.toml` (it can be empty), or
  else the folder you are in.
- **The server starts and stops on its own:** it starts when needed and stops after 15 idle
  minutes. `sysmantic start` and `sysmantic stop` control it yourself.
- **Staying up to date:** when a newer Sysmantic is out, a command in your terminal says so in one
  line, with how to update. It checks GitHub at most once a day and sends nothing about your
  model; `SYSMANTIC_NO_UPDATE_CHECK=1` turns it off. The VS Code extension updates itself.

### In VS Code

Open your model's folder, and Sysmantic checks it as you type.

You get problems in the Problems view, values and verdicts on hover and inline, navigation,
rename, completion and formatting, the Sysmantic panel for questions, the graph view, and the
standard views. This
manual opens with *Sysmantic: Open Manual*, or the book icon in the panel.

### With AI agents

Agents can read, compute with and change your model through Sysmantic, on the same live model you
see.

In **VS Code**, agents such as Copilot get Sysmantic's tools with nothing to set up. **Claude
Code** and other agents run the `sysmantic` command, so it must be on your PATH: install it (see
the [README](README.md)), or, if you have the VS Code extension, run *Sysmantic: Install
'sysmantic' Command in PATH*. Then add it once per model:

```sh
claude mcp add sysmantic -- sysmantic mcp --workspace /path/to/model
```

To share it with your team, put this in the model's `.mcp.json`. Other agents take the same
command:

```json
{ "mcpServers": { "sysmantic": { "command": "sysmantic", "args": ["mcp"] } } }
```

Then ask in plain words: "Which requirements fail, and why?"

### On the command line

The `sysmantic` command works in any terminal, in your model's folder. The install script puts it
on your PATH; with only the VS Code extension, run *Sysmantic: Install 'sysmantic' Command in PATH*
to use the command it includes.

```sh
sysmantic check      # problems in the whole model
sysmantic help       # every command
```

Other editors with Language Server Protocol support can use Sysmantic too, by running
`sysmantic attach`. For example, Neovim:

```lua
vim.lsp.config('sysmantic', { cmd = { 'sysmantic', 'attach' }, filetypes = { 'sysml', 'kerml' }, root_markers = { 'sysmantic.toml', '.git' } })
vim.lsp.enable('sysmantic')
```

## Using Sysmantic

The things you can do with your model, wherever you work.

### Check your model

Sysmantic checks your whole model for problems: syntax, names that do not resolve, the language's
rules, and constraints or requirements that fail.

- **In VS Code**, problems appear in the Problems view as you type, for every file, open or not.
- **On the command line:** `sysmantic check`, or `sysmantic check <files>` for some files only.
- **Agents** use the `check` tool, and check again after changing the model.

### Compute values and verdicts

Sysmantic computes your model's values, with units, and decides whether constraints and
requirements are met.

- **In VS Code**, hover over an element for its value or verdict, and see values inline
  (`= 2214000 kg`).
- **On the command line:**

  ```sh
  sysmantic evaluate 'Vehicle::mass' --unit kg
  sysmantic verify 'Vehicle::massLimit'
  ```

- **Agents** use the `evaluate` and `verify` tools.

A verdict is **satisfied**, **violated** or **undetermined**, with the reason. Units are checked:
a mass asked for in metres is an error, not a wrong number. To evaluate an expression inside an
element: `sysmantic evaluate 'e1.thrust * 2' --context 'M::Rocket'`.

### Ask questions

Ask your model anything in SPARQL, with values and verdicts in the answers.

```sparql
SELECT ?requirement (eval:verdict(?requirement) AS ?verdict) (eval:why(?requirement) AS ?why)
WHERE { ?requirement a sysml:Requirement }
```

- **In VS Code**, write it at the bottom of the Sysmantic panel and see the answer as a table, a
  chart or a value. Your queries and sessions are kept.
- **On the command line:** `sysmantic query '<query>'`, or `sysmantic query @queries/<name>.rq`.
- **Agents** use the `query` tool, or just ask in plain words.

Queries are easy to write:

- **Familiar names:** classes follow the keywords (`sysml:Part`, `sysml:Requirement`), relations
  the notation (`kerml:typedBy`, `kerml:ownedFeature`).
- **No prefixes to declare:** `kerml:`, `sysml:` and `eval:` are ready.
- **Kinds are understood:** asking for parts finds every kind of part.
- **Shortcuts and functions** such as `sysml:satisfies` and `eval:value` (see
  [Query vocabulary](#query-vocabulary)).

Save queries as `.rq` files in the model's `queries` folder, to keep them with the model.

### See it as a graph

See your model as a graph in VS Code, and explore how its elements relate.

- *Sysmantic: Open Model Graph* draws the whole model, or a file or folder (right-click it in the
  Explorer).
- *Sysmantic: Show in Graph* (right-click in the editor) draws an element and its neighbors.
- *Open as graph* draws a CONSTRUCT or DESCRIBE answer from the panel.
- **Agents** can show you one with the `graph` tool: "show me how the requirements trace to the
  parts".

Hover to highlight neighbors, double-click to open an element, drag to pin. *Save* keeps the
view, layout included, as a query file to commit with the model.

### See it in the standard views

See your model in SysML's standard views, as diagrams in VS Code. Open one from the editor
(right-click on an element) or the Model Explorer (right-click an element), or from the Command
Palette:

| View | Shows | Open it on |
|---|---|---|
| *Open General View* | Definitions, usages and packages, with their compartments, and how they specialize, define, compose, satisfy and depend on one another | A package (its members), an element (it and what it relates to), or a `view` in the model (what it exposes and its filter keeps) |
| *Open Interconnection View* | A part's parts, nested, their ports, and the connections, interfaces, flows and bindings between them | A part definition or usage |
| *Open Action Flow View* | An action's actions, their parameters as pins, the control nodes, and the successions and flows between them | An action, or a state (its `do` action) |
| *Open State Transition View* | A state's states, their entry, do and exit actions, and the transitions between them with their triggers, guards and effects | A state definition or usage |
| *Open Sequence View* | Lifelines and what happens to each, in order: events and the messages between them, or a timeline of timeslices and snapshots | An occurrence or part with events and messages, or with timeslices |
| *Open Grid View* | Tables of a package's elements, a table per kind, with their ids, types, documentation, metadata, values and traces; and matrices of their relationships (satisfy, dependencies, allocation) | A package or definition |
| *Open Geometry View* | Parts as the Geometry library's solids, sized by their dimensions and placed by their coordinate frames, in three dimensions | A part whose parts are shaped (`:> ShapeItems::Cylinder`, …) |

A `view` you declare in the model opens as it declares: as the standard view it is defined by
(`view propulsion : StandardViewDefinitions::InterconnectionView { expose Rocket; }`), else as
its rendering asks (`render asElementTable;`), of what it exposes. *Open View* opens it so (on
anything else, a General View).

Opened on something it does not show (an Interconnection View of a package), a view lists what it
can show there, to pick from.

**Agents** can show you one with the `show_view` tool ("show me how the spacecraft's interfaces
connect"), and read what one shows with `read_view`, as text or as a picture: "which of these
requirements does nothing satisfy?". To make a point clear, an agent can highlight what matters
(it stands out, the rest steps back, and the view opens on it), say in a note above the view what
to see, and style that view alone; close the note to see the view as usual. `show_view`, and a
picture from `read_view`, need the model open in VS Code; its text, not.

In a diagram: scroll to pan, pinch (or Ctrl/Cmd and scroll) to zoom, **F** to fit, **M** for the
minimap. Hover an element to bring out its relationships; double-click it to open its
declaration, or a package to open its view (**Alt+←** goes back). The element at the cursor in the
editor is selected in the views of its model, and the views follow the model as you edit. Export a
diagram as SVG or PNG, a Grid View's table as CSV, a Geometry View as PNG.

In an Interconnection View, ⊕ on a part opens it in place, to show its definition's parts and
ports (⊖ folds them back). A `view`'s filters keep what they name: by metaclass (`filter
@SysML::PartUsage;`), by metadata (`@Safety`), or by type (`hastype Engine`), with `not`, `and`
and `or`; a filter on an expose (`expose P::*[@Safety];`) keeps what that expose brings in.

In a Grid View, click a column's heading to sort by it and type in *Filter rows* to narrow the
rows; the links in a cell open what they name. In a Geometry View, drag to turn it, right-drag to
move it, and choose *Iso*, *Front*, *Top* or *Side*; *Ortho* shows it without perspective, *Wireframe* as edges only, and *Color* colors the parts
by a value they give (mass, temperature, …), with its scale; *Names* labels the parts, and *Parts* lists
them with their dimensions.

### Style the views

Restyle the standard views with your own CSS.

Set `sysmantic.views.stylesheet` to a CSS file (relative to the model's root, or absolute): it
applies after the views' own style, to every view of the model, and to their exports. Saving it
updates the views.

Every shape is classed for what it shows, so you can style any of it:

| Classes | What they are |
|---|---|
| `.node` | A box; with `.definition`, `.usage` or `.package`, and its kind (`.part`, `.port`, `.action`, `.requirement`, `.state`, …), and `.abstract`, `.library`, `.focus` (what the view is of), `.selected` |
| `.node .body`, `.node .accent` | A box's outline, and the stripe along its top |
| `.node .keyword`, `.node .name` | `«part def»`, and the name (`.label`, then `.suffix`: `: Engine [1]`) |
| `.compartment.attributes` (`.ports`, `.parts`, `.doc`, `.parameters`, …) | A compartment: its `.compartment-title` and its `.line`s |
| `.edge.specialization` (`.definition`, `.composition`, `.satisfy`, `.dependency`, `.connection`, `.interface`, `.flow`, `.binding`, `.succession`, `.transition`, `.message`, …) | A relationship: its `.line`, and its `.edge-label` |
| `.port` (`.in`, `.out`, `.inout`, `.conjugated`, `.pin`) | A port or parameter pin: its `.port-box`, `.port-label` (`.port-name`, `.port-type`) |
| `.node.control` (`.start`, `.done`, `.fork`, `.join`, `.decide`, `.merge`) | A control node or pseudo-state |
| `.seq-band`, `.seq-row`, `.lifeline`, `.seq-card`, `.seq-item` (`.perform`, `.value`, `.event`) | A Sequence View's parts |
| `.grid-table`, `.grid-matrix`, `.mark` | A Grid View's tables and matrices; a matrix's `.row-head`, `.col-head`, `.total` |
| `.col-Rationale`, `.col-dryMass`, `.col-Satisfied-by`, `.col-refinement-to`, `.col-from-refinement`, … | A table's column, by its heading (its `th` and every `td`) |
| `.row-requirement`, `.row-part`, … with `.row-definition` or `.row-usage` | A row, by the kind of element it is (a matrix's columns: `.col-kind-requirement`, …) |

And variables set the colors and sizes. Sizes are measured before the layout, so changing them
lays the diagram out anew:

| Variables | What they set |
|---|---|
| `--accent` | A box's color (each kind sets it: `.node.requirement { --accent: #d1242f; }`) |
| `--font`, `--font-size`, `--name-size`, `--keyword-size` | Type |
| `--node-padding-x`, `--node-padding-y`, `--line-height`, `--node-min-width`, `--node-max-width` | A box's size |
| `--node-spacing`, `--layer-spacing` | The space between boxes, and between rows of them |
| `--edge-corner-radius`, `--port-size` | Edges' bends, ports' size |
| `--canvas`, `--ink`, `--muted`, `--edge`, `--node-fill`, `--node-stroke` | The page's colors (else the theme's) |
| `--solid-1` … `--solid-8` | A Geometry View's colors, a kind of part each |

For example:

```css
/* Requirements in red; no documentation in boxes; types beside ports; square bends. */
.node.requirement { --accent: #d1242f; }
.compartment.doc { display: none; }
.port-label .port-type { display: inline; }
:root { --edge-corner-radius: 0; --layer-spacing: 80px; }
```

To style some views and not others, start a rule with the view's kind or, for a `view` declared
in the model, its name:

```css
.view-grid .col-Values { display: none; }             /* no Values column */
.view-grid tr.row-requirement.row-usage td { background: #fff7e6; }
.view-sequence .seq-card { font-size: 11px; }        /* Sequence Views only */
.view-propulsion .node.part { --accent: #c4610f; }    /* the view `propulsion` only */
```

The kinds: `.view-general`, `.view-interconnection`, `.view-action-flow`, `.view-state-transition`,
`.view-sequence`, `.view-grid`, `.view-geometry`.

A stylesheet can change how the views look and what they leave out (`display: none`), not what
they show or where: the layout is the views' own.

### Work in a notebook

Analyze your model in Jupyter or VS Code notebooks: add SysML in cells, query it into tables,
compute values and verdicts in Python, and draw the standard views in the notebook.

Install the `sysmantic` Python package, with what notebooks need:

```sh
pip install "sysmantic[notebook]"
```

It runs the `sysmantic` command: the one on your PATH, the one `SYSMANTIC_PATH` names, or the one
the VS Code extension includes. In the notebook's first cell:

```python
import sysmantic
```

The notebook works on the model of its folder (see [Your model](#your-model)), the same model VS
Code and agents see.

**In cells:**

| Command | What it does |
|---|---|
| `%%sysml [name]` | Adds the cell's SysML to the model, as if it were a file (none is written), and shows what it declares and its problems. Running the cell again replaces it. |
| `%sysml <expression>` | Gives a value: `%sysml Rover::rover.mass` gives `1900 kg` |
| `%sysml check` | Gives the model's problems |
| `%sysml clear` | Removes the SysML the notebook added |
| `%%sparql [-o var] [--no-entailment]` | Gives a query's answer as a table (true or false for an `ASK`). With `-o`, keeps it in `var` instead of showing it. |
| `%viz [--view=V] <element>` | Draws one of the [standard views](#see-it-in-the-standard-views) of an element |

`%viz` options:

| Option | What it does |
|---|---|
| `--view=` | `general`, `interconnection`, `action-flow`, `state-transition`, `sequence`, `grid` or `geometry`; also `tree`, `mixed`, `case`, `state`, `action` and `table`. Without it, the view that suits the element. |
| `--highlight=A,B` | Outlines these elements |
| `--fade` | With `--highlight`, makes the rest step back |
| `--note="…"` | Says above the view what to see |
| `--style="…"` | CSS for this view only, as in [Style the views](#style-the-views): `--style=".col-Documentation { display: none; }"` |
| `--height=` | The view's height, in pixels |

The views work as they do in VS Code: open a package, open a part in place, go back, hover,
export.

**In Python:**

| Function | What it does |
|---|---|
| `sysmantic.evaluate(target, unit=None, context=None)` | A value: a number with its unit (use it as a float; `.unit` gives the unit), a boolean, or text |
| `sysmantic.verify(target)` | Whether a requirement, constraint or `satisfy` holds: `.verdict` is `satisfied`, `violated` or `undetermined`, with `.why`; true if satisfied |
| `sysmantic.query(sparql)` | As `%%sparql`: a pandas table, true or false, or N-Triples for a `CONSTRUCT` |
| `sysmantic.sysml(text, name)` | As `%%sysml`: adds SysML under `name`, replacing what was there |
| `sysmantic.view(element, kind, highlight=[…], fade=False, note=None, style=None, height=None)` | As `%viz` |
| `sysmantic.table(df, formats=None)` | Shows a table as a report does: no row numbers, text left, numbers right; `formats` by column (`{"mass (kg)": "{:.2f}"}`) |
| `sysmantic.model()` | The notebook's model, with these and `check()` and `drop(name=None)` |

A problem (an element that does not exist, a view that does not apply) raises
`sysmantic.SysmanticError` with the reason.

For example, a trade study that writes each candidate into the model, and lets the model compute
its mass and decide its requirement. The model gives the drone's battery mass as a `default`, so a
candidate can change it:

```python
import pandas as pd

rows = []
for pack, kg in [("4S 5000", 0.50), ("4S 8000", 0.78), ("6S 5000", 0.75)]:
    name = "Option_" + pack.replace(" ", "_")
    sysmantic.sysml(f"""package {name} {{
        private import Drone::*;
        private import SI::*;
        part design :> drone {{ part :>> battery {{ attribute :>> mass = {kg} [kg]; }} }}
        requirement mass : TakeoffMass {{ subject :>> d = design; }}
    }}""", name)
    rows.append({
        "pack": pack,
        "takeoff mass (kg)": float(sysmantic.evaluate(f"{name}::design.takeoffMass", unit="kg")),
        "mass requirement": sysmantic.verify(f"{name}::mass").verdict,
    })
sysmantic.table(pd.DataFrame(rows), {"takeoff mass (kg)": "{:.3f}"})
```

```
%viz --view=general Drone::TakeoffMass --highlight=Drone::drone
```

While the notebook runs, the SysML it adds is part of the model everywhere: in VS Code's
problems, Model Explorer and views, and for agents. The views draw when the notebook runs, in
Jupyter or VS Code. Opened elsewhere, a notebook shows its tables and charts, and a placeholder
for each view.

### Change the model

Name what to change, and Sysmantic edits the files for you, touching only that.

`sysmantic update`, and the agents' `update` tool, take a list of changes:

```json
{ "operations": [
  { "op": "create",  "owner": "Vehicles::Vehicle", "text": "part battery : Battery[1];" },
  { "op": "set",     "element": "Vehicles::Vehicle::mass", "property": "value", "value": "1450 [kg]" },
  { "op": "rename",  "element": "Vehicles::Engine", "name": "PowerUnit" },
  { "op": "replace", "element": "Vehicles::Wheel", "text": "part def Wheel { attribute size; }" },
  { "op": "move",    "element": "Vehicles::Spare", "owner": "Vehicles::Storage" },
  { "op": "delete",  "element": "Vehicles::OldPart" }
]}
```

- **create** adds members to an element, next to another (`after`, `before`), or to a file (a
  new file is created).
- **set** changes one property: `value`, `multiplicity`, `typedBy`, `specializes`, `doc`,
  `isAbstract`, and more. `null` removes it.
- **rename** renames an element and every reference to it.
- **replace** rewrites an element from new text.
- **move** moves an element, with its notes, and keeps references working.
- **delete** removes an element and its notes. If something refers to it, Sysmantic stops,
  unless you add `"references": "detach"` (remove them) or `"leave"` (keep them).

Changes apply all or nothing, and the answer shows each file's diff and the problems added or
fixed. `--dry-run` previews them; `--if-version <n>` refuses them if the model changed since.

### Export and import

Save your model as standard notation or RDF, and bring models in from RDF or a `.kpar` archive.

```sh
sysmantic export --format text      # each file in the standard style
sysmantic export --format ttl       # the model as RDF (also trig, nq)
sysmantic import model.trig         # add files from RDF or a .kpar archive
```

`//` notes are not part of the model, so exports leave them out. `import` never overwrites your
files unless you add `--force`.

### Use it from programs

Any program can query and change your model over HTTP. In notebooks, the `sysmantic` package
does it for you (see [Work in a notebook](#work-in-a-notebook)).

Run `sysmantic start` first. The server's address is in the model's `.sysmantic/server.json`.

**Queries** go to `/query`, as standard SPARQL. In Python:

```python
import json, requests

url = json.load(open(".sysmantic/server.json"))["url"]
query = "SELECT ?r (eval:verdict(?r) AS ?verdict) WHERE { ?r a sysml:Requirement }"
rows = requests.post(f"{url}/query", data={"query": query},
                     headers={"Accept": "application/sparql-results+json"}).json()
```

In JavaScript, or from the shell:

```js
const res = await fetch(`${url}/query`, {
  method: "POST",
  headers: { "Content-Type": "application/sparql-query", Accept: "text/csv" },
  body: "SELECT ?p WHERE { ?p a sysml:Part }",
});
```

```sh
curl -s "$URL/query" -H 'Accept: text/csv' --data-urlencode 'query=SELECT ?p WHERE { ?p a sysml:Part }'
```

**Keep your queries in the model,** as `.rq` files in `queries/`, and pass values with a
`VALUES` clause added at the end (`VALUES ?name { "dryMass" }`).

**Changes** go to `/update`, as the JSON of [Change the model](#change-the-model). Pass the
version you read from `/inspect`, so a change made meanwhile by someone else is refused:

```python
version = requests.get(f"{url}/inspect").json()["version"]
change = {"ifVersion": version, "operations": [
    {"op": "set", "element": "Vehicle::mass", "property": "value", "value": "1450 [kg]"}]}
requests.post(f"{url}/update", json=change).raise_for_status()
```

Answers come as JSON, CSV, TSV or XML. `/check`, `/evaluate`, `/verify`, `/export` and
`/inspect` work like the commands.

### Check it in CI

Check your model, and its requirements, on every change.

Install Sysmantic in a step (see the [README](README.md)), then:

```yaml
- run: sysmantic check                          # fails on errors
- run: sysmantic verify 'Vehicle::massLimit'    # fails if not satisfied
```

## Reference

Commands, tools, settings and query vocabulary, in one place.

### Commands

Every `sysmantic` command; `sysmantic help <command>` gives the details.

| Command | What it does |
|---|---|
| `check [files]` | Reports problems |
| `evaluate <target> [--context <element>] [--unit <unit>]` | Computes values |
| `verify <target>` | Decides constraints and requirements |
| `query <sparql \| @file.rq> [--format csv]` | Answers a SPARQL query |
| `export [--format text\|ttl\|trig\|nq]` | Writes the model as notation or RDF |
| `update <changes.json> [--dry-run]` | Changes the model |
| `import <file> [--force]` | Adds files from RDF or a `.kpar` archive |
| `start`, `stop`, `restart` | Controls the model's server |
| `inspect`, `status` | Shows this model's server, or all servers |
| `attach`, `mcp` | Connects an editor, or an agent |
| `manual [section \| --all]` | Shows this manual |
| `version`, `license` | Shows the version or the license |

Every command also takes `--workspace <dir>` and `--json`.

### MCP tools

The tools Sysmantic gives AI agents.

| Tool | What it does |
|---|---|
| `describe` | Shows an element as notation |
| `export` | Shows a file, or lists the model's files |
| `check` | Reports problems |
| `query` | Answers a SPARQL query |
| `evaluate`, `verify` | Computes values and verdicts |
| `update` | Changes the model |
| `graph` | Shows you a graph in VS Code |
| `show_view` | Shows you one of the standard views of an element in VS Code |
| `read_view` | Gives what a standard view shows, as text or a picture |
| `manual` | Gives a section of this manual |

The manual is also available as MCP resources: `sysmantic://manual`, and one per section.

### VS Code commands and settings

The extension's commands and settings.

| Command | What it does |
|---|---|
| Sysmantic: Show Query Panel | Opens the panel (⌘Enter or Ctrl+Enter runs the query) |
| Sysmantic: New Session in an Editor Tab | Starts a session in its own tab |
| Sysmantic: Run Query in Sysmantic | Runs the selection or query file |
| Sysmantic: Open Model Graph | Draws the model as a graph |
| Sysmantic: Show in Graph | Draws an element and its neighbors |
| Sysmantic: Open General View (Interconnection, Action Flow, State Transition, Sequence, Grid, Geometry) | Opens that standard view of the element at the cursor |
| Sysmantic: Open View | Opens a `view` declared in the model, as it declares |
| Sysmantic: Open Manual | Opens this manual |
| Sysmantic: Show Model Server | Shows the model's server |
| Sysmantic: Restart Model Server | Restarts it |
| Sysmantic: Show Output | Shows the extension's log |
| Sysmantic: Install 'sysmantic' Command in PATH | Makes the included `sysmantic` command available in terminals and to other agents |

| Setting | What it does |
|---|---|
| `sysmantic.path` | The `sysmantic` command to use (default: the one included) |
| `sysmantic.queriesFolder` | Where the panel saves queries (default: `queries`) |
| `sysmantic.views.stylesheet` | A CSS file that restyles the standard views (see [Style the views](#style-the-views)) |
| `sysmantic.inlayHints.values` | Computed values inline (on) |
| `sysmantic.inlayHints.impliedSpecializations` | What elements specialize implicitly (on) |
| `sysmantic.inlayHints.defaultVisibility` | `private` before imports without one (on) |
| `sysmantic.inlayHints.memberVisibility` | `public` before other members (off) |
| `sysmantic.inlayHints.effectiveNames` | Names that unnamed elements take (on) |

### Query vocabulary

The shortcuts and functions you can use in queries.

| Shortcut | Holds when |
|---|---|
| `kerml:type` | a feature has a type, declared or inherited |
| `kerml:owns`, `kerml:within` | an element is inside another, at any depth |
| `kerml:conformsTo` | a type is a kind of another, at any depth |
| `sysml:performs`, `sysml:exhibits` | an element performs an action or exhibits a state |
| `sysml:satisfies`, `sysml:satisfiedBy` | an element satisfies a requirement |
| `sysml:verifies` | a verification case verifies a requirement |
| `kerml:dependsOn` | an element depends on another |
| `kerml:connectedTo` | two features are connected |

| Function | Gives |
|---|---|
| `eval:value` | the value: a number, Boolean or text |
| `eval:unit` | its unit |
| `eval:text` | the value as shown, or why it cannot be computed |
| `eval:verdict`, `eval:why` | a verdict, and why |
| `eval:name`, `eval:qualifiedName` | an element's name and qualified name |

Each function takes an element, a qualified name or an expression, and optionally the elements
to read it in and a unit.

### Settings

A `sysmantic.toml` at the model's root holds its settings, all optional.

```toml
libraries = ["../sysml.library"]   # other libraries: .kpar archives or folders
exclude = ["build"]                # folders that are not part of the model
port = 7878                        # a fixed address for programs (default: any free port)
idle-minutes = 15                  # how long an idle server keeps running (0: until stopped)

[format]
indent = 4                         # spaces per level, or "tab"
break-conditions = 3               # break and/or chains this long, one condition per line
```
