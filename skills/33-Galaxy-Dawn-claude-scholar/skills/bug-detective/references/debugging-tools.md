# Debugging Tools

## Python
```bash
python -m pdb script.py
python -m traceback your_script.py
pytest -x -vv tests/test_target.py
```

## Node.js
```bash
node --inspect-brk app.js
node --trace-warnings app.js
npm test -- --runInBand
```

## Git
```bash
git bisect start
git bisect bad
git bisect good <known-good-commit>
```

## Shell
```bash
bash -n script.sh
bash -x script.sh
shellcheck script.sh
```
