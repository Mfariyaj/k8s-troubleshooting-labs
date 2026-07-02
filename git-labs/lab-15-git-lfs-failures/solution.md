# Lab 15: Solution — Git LFS Failures

## Root Cause

Multiple LFS issues:
1. `.gitattributes` declares LFS patterns, but `git lfs install` was never run in this repo
2. The filter configuration (`filter.lfs.clean`, `filter.lfs.smudge`, `filter.lfs.process`) is missing from `.git/config`
3. Model/data files were committed as raw pointer-file TEXT (not actual LFS objects)
4. `data/embeddings.bin` was committed as raw binary (bypassing LFS entirely)

## Fix Commands

### Step 1: Install LFS Filters

```bash
cd /tmp/git-lab-15

# Initialize LFS in this repo (sets up filter config)
git lfs install --local

# Verify filter config
git config --list | grep lfs
# Should show:
# filter.lfs.clean=git-lfs clean -- %f
# filter.lfs.smudge=git-lfs smudge -- %f
# filter.lfs.process=git-lfs filter-process
# filter.lfs.required=true
```

### Step 2: Handle Existing Pointer Files

```bash
# Check current LFS status
git lfs ls-files
# May show tracked files

git lfs status
# Shows which files should be LFS vs what's actually committed

# The pointer files committed as text need to be re-committed through LFS
# First, "migrate" existing files to proper LFS objects:
git lfs migrate import --include="*.model,*.dat,*.bin" --include-ref=HEAD

# OR if you want to rewrite all history:
git lfs migrate import --include="*.model,*.dat,*.bin,assets/*.png" --everything
```

### Step 3: Handle the Raw Binary File

```bash
# embeddings.bin was committed as raw binary, not through LFS
# After migration, it should be converted to an LFS pointer + LFS object

# Verify
git lfs ls-files
# Should list: data/embeddings.bin, models/trained.model, data/training.dat
```

### Step 4: Verify Everything Works

```bash
# Check that .gitattributes patterns match what LFS is tracking
git lfs track
# Should show:
#   *.bin (data/embeddings.bin)
#   *.dat (data/training.dat)
#   *.model (models/trained.model)
#   assets/*.png (assets/logo.png)

# Verify pointer files are correct format
git lfs pointer --check --file models/trained.model

# Check repository size impact
git lfs ls-files --size
```

### Alternative: If git-lfs is NOT installed

```bash
# If you can't install git-lfs, at minimum fix the config to stop errors:
# Option A: Remove .gitattributes LFS rules
sed -i '/filter=lfs/d' .gitattributes
git add .gitattributes
git commit -m "Remove LFS filters (LFS not available)"

# Option B: Set up dummy filters that pass through
git config filter.lfs.clean cat
git config filter.lfs.smudge cat
git config filter.lfs.required false
```

## Git Internals Explained

### How Git LFS Works

```
Normal Git:  working-tree → staging → blob object → pack file
Git LFS:     working-tree → LFS filter (clean) → pointer file (blob) → pack
                         → LFS storage (.git/lfs/objects/) → actual content
```

### LFS Pointer File Format

```
version https://git-lfs.github.com/spec/v1
oid sha256:<64-char-hex-hash>
size <file-size-in-bytes>
```

This tiny text file replaces the actual binary in Git's object store. The real file is in `.git/lfs/objects/`.

### Filter Process

| Operation | Filter | What Happens |
|-----------|--------|--------------|
| `git add` | `clean` | Replaces file content with pointer, stores real content in LFS |
| `git checkout` | `smudge` | Replaces pointer with real file content from LFS |
| Batch | `process` | Handles multiple files efficiently |

### Key Locations

```
.gitattributes                    # Defines which files use LFS
.git/config                       # filter.lfs.* entries
.git/lfs/objects/                 # Local LFS object store
.git/lfs/tmp/                     # Temp files during transfer
```

### Common LFS Problems

| Problem | Cause | Fix |
|---------|-------|-----|
| Pointer files visible | smudge filter missing | `git lfs install && git lfs pull` |
| File committed without LFS | Added before .gitattributes | `git lfs migrate import` |
| Push fails (bandwidth) | LFS server quota | Buy more storage or use different remote |
| Clone shows pointers | `--skip-smudge` was used | `git lfs pull` |
| Checkout slow | Large files downloading | `git lfs install --skip-smudge` + selective pull |
