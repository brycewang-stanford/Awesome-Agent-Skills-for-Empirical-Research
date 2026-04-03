# Stack Detection

## Python
Look for `pyproject.toml`, `uv.lock`, `requirements.txt`, or `pytest.ini`.
Prefer `uv` commands when the repo is uv-managed.

## Node.js / TypeScript
Look for `package.json`, `pnpm-lock.yaml`, `tsconfig.json`.
Use the package manager already used by the repo.

## Mixed repos
Run only the checks relevant to touched areas; do not force every language tool when the change is clearly scoped.
