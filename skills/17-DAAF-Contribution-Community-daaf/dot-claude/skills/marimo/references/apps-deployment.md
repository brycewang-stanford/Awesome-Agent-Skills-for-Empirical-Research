# Apps, Scripts & Deployment

## Run as App

Transform any notebook into an interactive web app:

```bash
marimo run notebook.py
```

- Code is hidden
- Outputs are displayed
- UI elements remain interactive
- Reactive execution still works

### Options

```bash
# Custom host/port
marimo run notebook.py --host 0.0.0.0 --port 8080

# Include code in app view
marimo run notebook.py --include-code

# Watch for file changes
marimo run notebook.py --watch

# Disable authentication
marimo run notebook.py --no-token
```

## App Layouts

### Vertical (Default)

Cell outputs stacked vertically, code hidden.

### Grid Layout

Drag-and-drop positioning:

1. In editor, click preview button (bottom-right)
2. Select "Grid" from layout dropdown
3. Drag outputs to arrange

Grid metadata saved in `layouts/` folder - include in version control.

### Slides Layout

Presentation mode:

1. In editor preview, select "Slides"
2. Each cell becomes a slide
3. Navigate with arrow keys

## Run as Script

marimo notebooks are valid Python:

```bash
python notebook.py
```

### CLI Arguments

Access command-line args:

```python
# In notebook
args = mo.cli_args()
input_file = args.get("input", "default.csv")

# Usage
python notebook.py -- --input data.csv --output results.json
```

### Query Parameters (Web)

When running as app:

```python
params = mo.query_params()
# params["key"] from URL ?key=value
```

Set params:

```python
mo.query_params.set({"page": 2})
```

## Export

### HTML (Static)

```bash
marimo export html notebook.py -o output.html

# Include code
marimo export html notebook.py -o output.html --include-code

# Watch mode
marimo export html notebook.py -o output.html --watch
```

### HTML-WASM (Interactive, Browser-Only)

Runs entirely in browser via WebAssembly:

```bash
marimo export html-wasm notebook.py -o output_dir/

# Edit mode (code editable)
marimo export html-wasm notebook.py -o output_dir/ --mode edit

# Run mode (read-only)
marimo export html-wasm notebook.py -o output_dir/ --mode run
```

Must be served over HTTP (not `file://`).

### Jupyter Notebook

```bash
marimo export ipynb notebook.py -o output.ipynb

# Include outputs
marimo export ipynb notebook.py -o output.ipynb --include-outputs
```

### Flat Python Script

```bash
marimo export script notebook.py -o flat_script.py
```

Cells merged in topological order.

### Markdown

```bash
marimo export md notebook.py -o output.md
```

## Deployment Options

### Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY notebook.py .

EXPOSE 8080
CMD ["marimo", "run", "notebook.py", "--host", "0.0.0.0", "--port", "8080", "--headless"]
```

```bash
docker build -t my-marimo-app .
docker run -p 8080:8080 my-marimo-app
```

### Docker with Sandbox

```dockerfile
FROM ghcr.io/marimo-team/marimo:latest

COPY notebook.py /app/
WORKDIR /app

CMD ["marimo", "run", "notebook.py", "--sandbox", "--host", "0.0.0.0"]
```

### HuggingFace Spaces

1. Create new Space with Docker SDK
2. Add `Dockerfile`:

```dockerfile
FROM ghcr.io/marimo-team/marimo:latest
COPY --chown=user notebook.py /app/
CMD ["marimo", "run", "/app/notebook.py", "--host", "0.0.0.0", "--port", "7860"]
```

### Railway / Render / Fly.io

Similar Docker-based deployment. Set:
- Build: `docker`
- Port: match your `--port` flag

### Cloudflare Pages (WASM)

```bash
marimo export html-wasm notebook.py -o dist/ --include-cloudflare
# Deploy dist/ to Cloudflare Pages
```

### GitHub Pages (WASM)

```bash
marimo export html-wasm notebook.py -o docs/
# Enable GitHub Pages from docs/ folder
```

## Authentication

### Token Auth (Default)

```bash
# Random token (printed to console)
marimo run notebook.py --token

# Custom token
marimo run notebook.py --token-password mysecret

# Disable (not recommended for public)
marimo run notebook.py --no-token
```

### Custom Auth

Use ASGI middleware for OAuth, SSO, etc.

## Programmatic Execution

### Run from Python

```python
from marimo import App

app = App("notebook.py")
outputs, defs = app.run()
```

### Embed in Other Apps

```python
# FastAPI example
from fastapi import FastAPI
from marimo import create_asgi_app

app = FastAPI()
marimo_app = create_asgi_app().with_app(path="", root="notebook.py").build()
app.mount("/marimo", marimo_app)
```

## Sharing

### molab (Cloud)

Free cloud notebooks at https://molab.marimo.io:

1. Create notebook on molab
2. Share link directly

### GitHub Rendering

GitHub renders marimo `.py` files. Add to repo, share link.

### Embedding

Embed WASM notebooks in other sites:

```html
<iframe src="https://your-wasm-export.com" width="100%" height="600"></iframe>
```

## Best Practices

1. **Test as app** before deploying: `marimo run notebook.py`
2. **Pin dependencies** in requirements.txt or inline
3. **Use `--sandbox`** for reproducible environments
4. **Include layouts/** folder in version control
5. **Set appropriate auth** for public deployments
6. **Use WASM export** for static hosting (no server needed)

## Summary

| Goal | Command |
|------|---------|
| Interactive app | `marimo run notebook.py` |
| Execute as script | `python notebook.py` |
| Static HTML | `marimo export html ...` |
| Browser-only (WASM) | `marimo export html-wasm ...` |
| Convert to Jupyter | `marimo export ipynb ...` |
| Docker deploy | Use official image |
| Serverless | WASM + static hosting |
