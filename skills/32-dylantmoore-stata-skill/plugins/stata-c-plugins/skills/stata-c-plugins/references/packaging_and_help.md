# Stata Package Structure and Distribution

## Required Files for net install

### stata.toc (Table of Contents)

List **all package variants** — one all-platforms package plus one per OS:

```
v 3
d packagename - Short description of the package
d Author Name, Institution
d Distribution-Date: YYYYMMDD
p packagename All platforms (macOS, Linux, Windows)
p packagename_mac macOS only (ARM64 + Intel)
p packagename_linux Linux only (x86_64)
p packagename_win Windows only (x86_64)
```

- Line 1: `v 3` (version)
- `d` lines: description, author, date
- `p packagename` lines: each references a `.pkg` file. Text after the name is a description shown to users.

### Platform-Specific .pkg Files

Create **one .pkg per platform**. All packages install the same `.ado` and `.sthlp` files — only the `.plugin` binary differs. This way users download only the binary for their OS.

**packagename_mac.pkg** (macOS — includes both ARM64 and Intel):
```
v 3
d packagename: One-line description
d
d Author Name, Institution
d email@example.com
d
d Distribution-Date: YYYYMMDD
d
f mycommand.ado
f mycommand.sthlp
f mycommand_sub.ado
f mycommand_sub.sthlp
f myplugin_macosx.plugin
```

**packagename_linux.pkg** (Linux x86_64):
```
v 3
d packagename: One-line description
d
d Author Name, Institution
d email@example.com
d
d Distribution-Date: YYYYMMDD
d
f mycommand.ado
f mycommand.sthlp
f mycommand_sub.ado
f mycommand_sub.sthlp
f myplugin_unix.plugin
```

**packagename_win.pkg** (Windows x86_64):
```
v 3
d packagename: One-line description
d
d Author Name, Institution
d email@example.com
d
d Distribution-Date: YYYYMMDD
d
f mycommand.ado
f mycommand.sthlp
f mycommand_sub.ado
f mycommand_sub.sthlp
f myplugin_windows.plugin
```

**packagename.pkg** (all platforms — for users who don't care about download size):
```
v 3
d packagename: One-line description
d
d Author Name, Institution
d email@example.com
d
d Distribution-Date: YYYYMMDD
d
f mycommand.ado
f mycommand.sthlp
f mycommand_sub.ado
f mycommand_sub.sthlp
f myplugin_macosx.plugin
f myplugin_unix.plugin
f myplugin_windows.plugin
```

- `f` lines list every file to install
- Files install to the user's PLUS ado directory in a letter-subdirectory (e.g., `plus/g/`)
- Only list `.plugin` files that actually exist — listing a nonexistent file fails the install
- Stata loads the right plugin at runtime via gtools-style OS detection

### Installation Commands

```stata
* macOS
net install packagename_mac, from("https://raw.githubusercontent.com/user/repo/main") replace
* Linux
net install packagename_linux, from("https://raw.githubusercontent.com/user/repo/main") replace
* Windows
net install packagename_win, from("https://raw.githubusercontent.com/user/repo/main") replace
* All platforms (larger download)
net install packagename, from("https://raw.githubusercontent.com/user/repo/main") replace
```

The `from()` URL must point to a directory containing `stata.toc`. The repo must be **public** — private repos return 404 from `raw.githubusercontent.com`.

### Plugin Loading (gtools-style)

Use the **gtools-style OS detection pattern** in every .ado that calls the plugin. This detects the OS and constructs a bare filename that Stata resolves via the adopath:

```stata
/* ---- Load plugin (gtools-style: detect OS, bare filename) ---- */
if ( inlist("`c(os)'", "MacOSX") | strpos("`c(machine_type)'", "Mac") ) local c_os_ macosx
else local c_os_: di lower("`c(os)'")

cap program drop myplugin
program myplugin, plugin using("myplugin_`c_os_'.plugin")
```

**WARNING — DO NOT use `findfile` + absolute paths.** `findfile` returns absolute paths that fail with Stata's `LoadLibrary` on Windows. The gtools-style bare filename pattern is proven reliable across all platforms.

## Help File Naming

**Help files use the short command name, not the package/repo name.** The repo might be called `mypackage_stata` for GitHub discoverability, but the help file should be `mypackage.sthlp` so that `help mypackage` works. Package name and help file name are independent: `mypackage_stata_mac.pkg` installs `mypackage.sthlp`.

For multi-command packages, create:
- **One overview help file** with the short package name (e.g., `mypackage.sthlp`) listing all subcommands
- **One help file per subcommand** (e.g., `mypackage_subcommand1.sthlp`, `mypackage_subcommand2.sthlp`)

## Help File (.sthlp) Template

```smcl
{smcl}
{* *! version 1.0.0  DDmonYYYY}{...}
{viewerjumpto "Syntax" "commandname##syntax"}{...}
{viewerjumpto "Description" "commandname##description"}{...}
{viewerjumpto "Options" "commandname##options"}{...}
{viewerjumpto "Examples" "commandname##examples"}{...}
{viewerjumpto "Stored results" "commandname##results"}{...}

{title:Title}

{phang}
{bf:commandname} {hline 2} Short description of what the command does

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:commandname}
{depvar} {indepvars}
{ifin}
{cmd:,} {opt gen:erate(newvar)} [{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt gen:erate(newvar)}}name of new variable to create{p_end}

{syntab:Method}
{synopt:{opt m:ethod(string)}}method name; default is {bf:default}{p_end}
{synopt:{opt q:uantile(#)}}target quantile; default is 0.5{p_end}

{syntab:Other}
{synopt:{opt seed(#)}}random seed; default is 12345{p_end}
{synopt:{opt replace}}replace existing variable{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:commandname} does X based on Y.

{marker options}{...}
{title:Options}

{phang}
{opt method(string)} specifies the method. Options are:
{phang2}{bf:method1} - Description{p_end}
{phang2}{bf:method2} - Description{p_end}

{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}

{pstd}Basic usage{p_end}
{phang2}{cmd:. commandname price mpg weight, gen(price_imputed)}{p_end}

{marker results}{...}
{title:Stored results}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(seed)}}random seed used{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(method)}}method used{p_end}
```

### SMCL Formatting Cheat Sheet

- `{txt}` — plain text color
- `{res}` — result/highlight color
- `{err}` — error color
- `{bf:text}` — bold
- `{it:text}` — italic
- `{cmd:text}` — command formatting
- `{hline 60}` — horizontal rule
- `{pstd}` — standard paragraph indent
- `{phang}` — hanging indent
- `{phang2}` — double hanging indent
- `{p_end}` — end paragraph
- `{browse "URL"}` — clickable link
- `{manhelp cmd SECTION}` — link to Stata manual

## Build Script Template

```python
#!/usr/bin/env python3
"""Build Stata plugins for multiple platforms."""
import subprocess
import sys

PLATFORMS = {
    'macosx': {
        'cc': 'gcc',
        'cflags': '-O3 -fPIC -DSYSTEM=APPLEMAC -arch arm64',
        'ldflags': '-bundle -arch arm64',
    },
    'unix': {
        'cc': 'gcc',
        'cflags': '-O3 -fPIC -DSYSTEM=OPUNIX',
        'ldflags': '-shared -static-libstdc++ -static-libgcc',
    },
    'windows': {
        'cc': 'x86_64-w64-mingw32-gcc',
        'cflags': '-O3 -DSYSTEM=STWIN32',
        'ldflags': '-shared',
    },
}

def build_plugin(name, sources, platforms=None):
    """Build a plugin for specified platforms."""
    if platforms is None:
        platforms = PLATFORMS.keys()

    for platform in platforms:
        cfg = PLATFORMS[platform]
        output = f"{name}_{platform}.plugin"
        cmd = (
            f"{cfg['cc']} {cfg['cflags']} {cfg['ldflags']} "
            f"-o {output} {' '.join(sources)}"
        )
        # Add pthreads
        if platform == 'windows':
            cmd += " -lwinpthread"
        else:
            cmd += " -pthread"

        print(f"Building {output}...")
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"FAILED: {result.stderr}")
            sys.exit(1)
        print(f"  OK")

if __name__ == '__main__':
    build_plugin(
        'myplugin',
        ['algorithm.c', 'stplugin.c'],
    )
```

## Makefile Template (C++ Plugin)

Alternative to the Python script. Compile `stplugin.c` as C separately per platform.

```makefile
PLUGIN_NAME = myplugin
CPP_SOURCES = wrapper.cpp
CC = gcc
CXX = g++

TARGET_MACOSX  = $(PLUGIN_NAME)_macosx.plugin
TARGET_UNIX    = $(PLUGIN_NAME)_unix.plugin
TARGET_WINDOWS = $(PLUGIN_NAME)_windows.plugin

.PHONY: all macosx windows linux all-platforms clean

all: macosx

$(TARGET_MACOSX): $(CPP_SOURCES) stplugin.c
	$(CC) -O3 -fPIC -DSYSTEM=APPLEMAC -arch arm64 -c stplugin.c -o stplugin.o
	$(CXX) -std=c++14 -O3 -fPIC -DSYSTEM=APPLEMAC -arch arm64 -bundle \
	    -o $@ $(CPP_SOURCES) stplugin.o -lm
	rm -f stplugin.o

$(TARGET_UNIX): $(CPP_SOURCES) stplugin.c
	# Run inside Docker: docker run --rm --platform linux/amd64 -v "$$(pwd):/build" -w /build ubuntu:18.04 \
	#   bash -c "apt-get update -qq && apt-get install -y -qq g++ gcc make > /dev/null 2>&1 && make linux"
	gcc -O3 -fPIC -DSYSTEM=OPUNIX -c stplugin.c -o stplugin.o
	g++ -std=c++14 -O3 -fPIC -DSYSTEM=OPUNIX -shared -static-libstdc++ -static-libgcc \
	    -o $@ $(CPP_SOURCES) stplugin.o -lm
	rm -f stplugin.o

$(TARGET_WINDOWS): $(CPP_SOURCES) stplugin.c
	x86_64-w64-mingw32-gcc -O3 -DSYSTEM=STWIN32 -c stplugin.c -o stplugin.o
	x86_64-w64-mingw32-g++ -std=c++14 -O3 -DSYSTEM=STWIN32 -shared \
	    -static-libstdc++ -static-libgcc -o $@ $(CPP_SOURCES) stplugin.o -lm
	rm -f stplugin.o

macosx: $(TARGET_MACOSX)
linux: $(TARGET_UNIX)
windows: $(TARGET_WINDOWS)
all-platforms: macosx linux windows

clean:
	rm -f *.plugin stplugin.o
```

## Naming Conventions

- Use `method()` not `model()` for method selection options
- Use `generate()` (abbreviation `gen()`) for output variable naming
- Use `replace` as a flag option, not `replace()`
- Plugin files: `algorithm_plugin_os.plugin` where os is `macosx`, `unix`, or `windows`
- .ado files: lowercase, underscores for multi-word commands
- Stata convention: options use lowercase, abbreviations capitalized (`GENerate`, `MAXDepth`)
- Target Stata 14.0+ for plugin support (`version 14.0`)
- **Help files use the short command name, not the repo name.** Repo `mypackage_stata` → help file `mypackage.sthlp` → user types `help mypackage`. Don't add "stata" to names the user types — they're already in Stata.
- **Commands also use the short name.** `mypackage_subcommand`, not `mypackage_stata_subcommand`. The package name (used for `net install`) can include "stata" for GitHub discoverability, but commands and help files should not.

## Useful Stata Idioms

- `quietly` — suppresses output (use liberally in wrapper code)
- `capture` — suppresses errors and sets `_rc`
- `noisily` inside `capture` — re-enables display while still capturing rc
- `tempvar`, `tempfile` — auto-cleaned temporary names
- `preserve` / `restore` — save/restore dataset state
- `gettoken depvar indepvars : varlist` — split varlist into depvar + rest
