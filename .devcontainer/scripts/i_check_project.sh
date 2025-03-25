#!/bin/bash
# Usage: $0 /path/to/docker-compose.yml

# Check if exactly one argument (the YAML file path) is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/docker-compose.yml"
    exit 1
fi

YML_FILE="$1"

# Verify that the specified YAML file exists
if [ ! -f "$YML_FILE" ]; then
    echo "Error: File does not exist: $YML_FILE"
    exit 1
fi

# Determine the project directory from the YAML file's location
PROJECT_DIR=$(dirname "$YML_FILE")

# If a .env file exists in the directory, load it (docker compose auto-loads .env in the same directory)
if [ -f "$PROJECT_DIR/.env" ]; then
    set -a
    source "$PROJECT_DIR/.env"
    set +a
fi

# Docker compose uses the COMPOSE_PROJECT_NAME environment variable if set;
# otherwise, it defaults to the name of the directory.
if [ -n "$COMPOSE_PROJECT_NAME" ]; then
    PROJECT_NAME="$COMPOSE_PROJECT_NAME"
else
    PROJECT_NAME=$(basename "$PROJECT_DIR")
fi

echo "Using project name: $PROJECT_NAME"

# Check if a project with the same name already exists by looking for running containers
EXISTING_CONTAINERS=$(docker compose -p "$PROJECT_NAME" ps -q)

if [ -n "$EXISTING_CONTAINERS" ]; then
    echo "Project '$PROJECT_NAME' already exists."
    echo "Do you want to continue with the subsequent processing? (y/n)"
    read -r ANSWER
    if [ "$ANSWER" != "y" ] && [ "$ANSWER" != "Y" ]; then
        echo "Subsequent processing has been cancelled."
        exit 0
    fi
fi

echo "Continuing with subsequent processing..."
# Add further processing commands below as needed

exit 0
