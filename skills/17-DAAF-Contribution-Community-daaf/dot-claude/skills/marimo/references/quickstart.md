# Quickstart

## Installation

### Minimal Install

```bash
pip install marimo
# or
uv add marimo
# or
conda install -c conda-forge marimo
```

### Recommended Install (SQL, AI, Plotting)

```bash
pip install "marimo[recommended]"
# or
uv add "marimo[recommended]"
```

This unlocks: SQL cells (DuckDB), AI completion, plotting in data viewer, Ruff formatting.

## CLI Commands

### Create/Edit Notebooks

```bash
# Launch notebook server (browse/create notebooks)
marimo edit

# Create or edit specific notebook
marimo edit my_notebook.py

# Watch for external edits (VS Code, vim, etc.)
marimo edit --watch my_notebook.py
```

### Run as App

```bash
# Serve notebook as read-only web app
marimo run my_notebook.py

# With custom host/port
marimo run my_notebook.py --host 0.0.0.0 --port 8080
```

### Run as Script

```bash
# Execute notebook as Python script
python my_notebook.py

# With CLI arguments
python my_notebook.py -- --arg1 value1
```

### Tutorials

```bash
# List all tutorials
marimo tutorial

# Recommended sequence
marimo tutorial intro      # Start here
marimo tutorial dataflow   # Understand reactivity
marimo tutorial ui         # Interactive elements
marimo tutorial markdown   # Formatting
marimo tutorial plots      # Visualization
marimo tutorial sql        # SQL cells
```

### Export

```bash
# Export to HTML
marimo export html notebook.py -o output.html

# Export to WASM (runs in browser)
marimo export html-wasm notebook.py -o output_dir/

# Export to Jupyter notebook
marimo export ipynb notebook.py -o output.ipynb

# Export to flat Python script
marimo export script notebook.py -o flat_script.py
```

### Convert from Jupyter (Inbound)

```bash
# Convert .ipynb INTO marimo (inbound only — marimo convert is for importing)
marimo convert notebook.ipynb -o notebook.py
# To export FROM marimo to other formats, use: marimo export {format}
# e.g., marimo export md notebook.py, marimo export html notebook.py
```

## First Notebook

### Basic Structure

Every marimo notebook starts with importing the library:

```python
import marimo as mo
```

### Cell Basics

- Each cell is a block of Python code
- The **last expression** in a cell is its output
- Cells execute based on **variable dependencies**, not position

```python
# Cell 1: Define data
data = [1, 2, 3, 4, 5]

# Cell 2: Process (runs after Cell 1 because it reads 'data')
total = sum(data)
total  # This is the output
```

### Adding Markdown

```python
mo.md("# My Analysis")
```

With Python values:

```python
mo.md(f"The total is **{total}**")
```

### Adding Interactivity

```python
slider = mo.ui.slider(1, 100, value=50, label="Choose a value")
slider  # Display it
```

Access value in another cell:

```python
mo.md(f"You selected: {slider.value}")
```

## File Format

marimo notebooks are **pure Python** (`.py` files):

```python
import marimo

__generated_with = "0.10.0"
app = marimo.App()

@app.cell
def _():
    import marimo as mo
    return (mo,)

@app.cell
def _(mo):
    mo.md("# Hello marimo!")
    return

if __name__ == "__main__":  # marimo framework boilerplate (auto-generated)
    app.run()
```

Benefits:
- Git-friendly (no JSON merge conflicts)
- Executable as scripts
- Import functions from other notebooks

## Package Management

### Auto-install on Import

marimo can detect missing packages and offer to install them. Enable in settings.

### Inline Dependencies (PEP 723)

Add dependencies to notebook header:

```python
# /// script
# dependencies = ["pandas", "altair"]
# ///
```

Run in isolated environment:

```bash
marimo edit --sandbox notebook.py
```

## VS Code / Cursor Integration

Install the [marimo VS Code extension](https://marketplace.visualstudio.com/items?itemName=marimo-team.vscode-marimo) for:
- Edit notebooks in VS Code
- Syntax highlighting
- Run notebooks directly

## Next Steps

- Learn about [reactivity](./reactivity.md) to understand how cells execute
- Add [UI elements](./ui-elements.md) for interactivity
- Work with [data and SQL](./sql-data.md)

## Official Resources

- Docs: https://docs.marimo.io
- GitHub: https://github.com/marimo-team/marimo
- Discord: https://marimo.io/discord
- Gallery: https://marimo.io/gallery
