# Lab 15: Git LFS Failures

## Difficulty: 🔴 Advanced

## Scenario

A machine learning project uses Git LFS for model files (*.model), data files (*.dat, *.bin), and images (assets/*.png). The `.gitattributes` correctly declares LFS patterns, but:

1. `git lfs install` was never run — the `filter.lfs.*` config is missing
2. Model/data files show LFS **pointer text** instead of real binary content
3. `data/embeddings.bin` (100KB) was committed as raw binary, bypassing LFS

When you `cat models/trained.model`, you see pointer file text instead of the actual model binary.

## What You'll See

```bash
$ cd /tmp/git-lab-15
$ cat models/trained.model
version https://git-lfs.github.com/spec/v1
oid sha256:4d7a214614ab2935c943f9e0ff69d22eadbb8f32b1258daaa5e2ca24d17e2393
size 52428800

$ cat .gitattributes
*.bin filter=lfs diff=lfs merge=lfs -text
*.dat filter=lfs diff=lfs merge=lfs -text
*.model filter=lfs diff=lfs merge=lfs -text
assets/*.png filter=lfs diff=lfs merge=lfs -text

$ git config --list | grep lfs
# EMPTY — no LFS config!

$ file data/embeddings.bin
data/embeddings.bin: data     # Raw binary, NOT an LFS pointer
```

## Hints

1. **Hint 1**: The first step is `git lfs install --local` to add the filter configuration to `.git/config`. Without this, git doesn't know how to invoke the LFS clean/smudge filters.

2. **Hint 2**: After installing LFS config, use `git lfs migrate import` to convert files that were committed wrong (either as raw pointer text or as raw binary) into proper LFS objects.

3. **Hint 3**: `git lfs status` shows which files should be LFS-tracked vs. what's actually in the repo. `git lfs ls-files` shows what LFS is currently managing. Compare these to find the discrepancies.

## Useful Commands

```bash
git lfs install --local             # Set up LFS filter in repo config
git lfs status                      # Show LFS tracking status
git lfs ls-files                    # List LFS-managed files
git lfs ls-files --size             # With file sizes
git lfs track                       # Show tracked patterns
git lfs migrate import --include="*.model" # Convert files to LFS
git lfs pointer --check --file X    # Verify pointer format
git lfs pull                        # Download LFS content
git config --list | grep lfs        # Check filter config
cat .gitattributes                  # LFS pattern definitions
file <path>                         # Check if file is binary or text
```

## Success Criteria

- `git config --list | grep lfs` shows all filter.lfs.* entries
- `git lfs ls-files` shows all tracked files
- LFS pointer files are valid (correct format)
- `git lfs status` shows no errors
- Large binary files are handled through LFS, not stored directly in git objects
