# Sysmantic examples

Worked SysML v2 examples: each a model, and a notebook that analyzes it.

| Example | What it shows |
|---|---|
| [CubeSat power](cubesat-power) | A 3U Earth-observation CubeSat's electrical power system: the battery simulated through a day of orbits, the requirements decided by the model, and the standard views in the notebook |

## Running the examples

1. Install Sysmantic, once for all the examples: see [Install](../README.md#install) (the
   `sysmantic` command, or the VS Code extension, which includes it).

2. Clone this repository and set up one Python environment for all the examples:

   ```sh
   git clone https://github.com/modelware/sysmantic.git
   cd sysmantic/examples
   python3 -m venv .venv
   source .venv/bin/activate        # Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. Open an example's notebook and run all its cells, in Jupyter (`jupyter lab`) or in VS Code
   (with the `.venv` environment as its kernel).

The views draw when the notebook runs; on GitHub, a notebook shows its tables and charts. See the
manual's [Work in a notebook](../MANUAL.md#work-in-a-notebook) for the notebook commands.

## License

Unlike Sysmantic itself, the examples are open source: copyright 2026 Modelware, licensed under
the [Apache License 2.0](LICENSE). Keep the [NOTICE](NOTICE) with copies and works based on them.
