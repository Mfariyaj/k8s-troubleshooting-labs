FROM python:3.11-slim

WORKDIR /app

COPY tool.py ./

# BUG: Shell form ENTRYPOINT - this runs as /bin/sh -c "python tool.py"
# CMD arguments will NOT be appended because the shell eats them
ENTRYPOINT python tool.py

# This CMD will be IGNORED because ENTRYPOINT is in shell form
CMD ["process", "--all"]
