#!/usr/bin/env -S uv run --script
"""Execute tasks from YAML configuration file."""

# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "pyyaml",
# ]
# ///
import os
import subprocess
import sys
from logging import INFO, basicConfig, getLogger
from pathlib import Path
from typing import Any

import yaml

TASK_KEY: str = "tasks"

basicConfig(level=INFO, format="%(message)s")
logger = getLogger(__name__)


def load_yaml_files(filepaths: list[str]) -> dict[str, Any]:
    """Load and merge multiple YAML files."""
    merged_data: dict[str, Any] = {}
    for filepath in filepaths:
        with Path(filepath).open() as file:
            data = yaml.safe_load(file) or {}
            merged_data = deep_merge(merged_data, data)
    return merged_data


def deep_merge(a: dict[str, Any], b: dict[str, Any]) -> dict[str, Any]:
    """Deep merge two dictionaries, appending lists instead of replacing them.

    If both a and b are lists, returns their concatenation.
    For other types, b overwrites a.
    """
    if not isinstance(a, dict) or not isinstance(b, dict):
        if isinstance(a, list) and isinstance(b, list):
            return a + b  # Concatenate lists
        return b  # Overwrite with b for other types

    merged: dict[str, Any] = a.copy()
    for key, value in b.items():
        if key in merged:
            if isinstance(merged[key], dict) and isinstance(value, dict):
                merged[key] = deep_merge(merged[key], value)
            elif isinstance(merged[key], list) and isinstance(value, list):
                merged[key].extend(value)  # Concatenate lists
            else:
                merged[key] = value  # Overwrite for other types
        else:
            merged[key] = value

    return merged


def execute_task(task_name: str, cmds: list[str], envs: dict[str, str]) -> None:
    """Execute a task as a subprocess with an isolated environment."""
    msg = f"Running step: {task_name}"
    logger.info(msg)

    # Prepare environment variables
    task_env = os.environ.copy()
    task_env.update(envs)
    try:
        for cmd in cmds:
            subprocess.run(cmd, check=True, env=task_env, shell=True)  # noqa: S602
    except subprocess.CalledProcessError as e:
        msg = f"Step '{task_name}' failed (exit code: {e.returncode}). Aborting."
        logger.exception(msg)
        sys.exit(e.returncode)


def main() -> None:
    """Main function."""
    min_narg: int = 2
    if len(sys.argv) < min_narg:
        logger.info(
            "Usage: python3 run_tasks.py [--debug] <config1.yml> [config2.yml ...]"
        )
        sys.exit(1)

    args: list[str] = sys.argv[1:]
    if args[0] in ["--debug", "-d"]:
        debug_mode: bool = True
        args.pop(0)
    else:
        debug_mode = False

    yaml_files: list[str] = args

    # Merge YAML files
    yaml_data: dict[str, Any] = load_yaml_files(yaml_files)

    if debug_mode:
        logger.info("========== Merged YAML ==========================")
        logger.info(yaml.dump(yaml_data, default_flow_style=False))
        logger.info("=================================================")

    # Error if 'tasks' phase does not exist or is empty in YAML.
    tasks: Any = yaml_data.get(TASK_KEY) or []
    if not tasks:
        msg = f"'{TASK_KEY}' not found or empty in YAML."
        logger.info(msg)
        sys.exit(1)

    msg = f"Executing {len(tasks)} tasks."
    logger.info(msg)

    global_envs: dict[str, str] = {
        env.split("=")[0]: env.split("=", 1)[1]
        for env in (yaml_data.get("global", {}).get("envs", []) or [])
        if isinstance(env, str) and "=" in env
    }

    # Execute tasks
    for task in tasks:
        task_name: str = task.get("name", "Unnamed Task")
        cmds: list[str] = task.get("cmds", [])

        if not cmds:
            msg = f"Skipping step '{task_name}' due to missing cmds."
            logger.info(msg)
            continue

        step_envs: dict[str, str] = {
            env.split("=")[0]: env.split("=", 1)[1]
            for env in (task.get("envs", []) or [])
            if isinstance(env, str) and "=" in env
        }
        all_envs: dict[str, str] = global_envs.copy()
        all_envs.update(step_envs)
        execute_task(task_name, cmds, all_envs)

    logger.info("All steps completed successfully.")


if __name__ == "__main__":
    main()
