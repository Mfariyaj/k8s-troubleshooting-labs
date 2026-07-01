# Lab 09 - Entrypoint vs CMD Confusion

## Difficulty: ⭐⭐⭐

## Scenario
A containerized CLI tool is built to accept command-line arguments. Users should be able to run different commands by passing arguments to `docker run`. But no matter what arguments are passed, the container always runs the same default command.

## What You'll See
When you run `./deploy.sh`:

```
$ docker run lab09-tool --version
Starting CLI tool...
Running default command: process --all
Processing all items...
Done.

$ docker run lab09-tool list --format json
Starting CLI tool...
Running default command: process --all
Processing all items...
Done.

$ docker run lab09-tool help
Starting CLI tool...
Running default command: process --all
Processing all items...
Done.
```

Arguments are completely ignored! The container ALWAYS runs `process --all`.

## Hints
1. What's the difference between ENTRYPOINT in shell form vs exec form?
2. In shell form (`ENTRYPOINT command arg`), the command runs as `/bin/sh -c "command arg"`
3. When ENTRYPOINT uses shell form, CMD arguments are NOT appended
4. How would you make the container accept arguments?

## Troubleshooting Commands
```bash
# Try passing arguments
docker run --rm lab09-tool --version
docker run --rm lab09-tool help
docker run --rm lab09-tool list

# Check what ENTRYPOINT and CMD are set to
docker inspect lab09-tool --format='ENTRYPOINT: {{.Config.Entrypoint}}'
docker inspect lab09-tool --format='CMD: {{.Config.Cmd}}'

# Override entrypoint to see what's happening
docker run --rm --entrypoint /bin/sh lab09-tool -c "echo 'shell form test'"
```

## Resolution
The ENTRYPOINT uses **shell form** (`ENTRYPOINT python tool.py`) which wraps the command in `/bin/sh -c "python tool.py"`. This means CMD arguments are never appended.

**Fix:** Use **exec form** for ENTRYPOINT:
```dockerfile
# Shell form (broken - ignores CMD/runtime args):
ENTRYPOINT python tool.py

# Exec form (correct - CMD args are appended):
ENTRYPOINT ["python", "tool.py"]
CMD ["process", "--all"]
```

With exec form, `docker run lab09-tool list --format json` executes `python tool.py list --format json`.
