#!/bin/bash
set -euo pipefail

# Usage: <script> <prefix> [taskfile directory]
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <prefix> [taskfile directory]"
  exit 1
fi

PREFIX="$1"
TASKDIR="${2:-.}"

# Change to the specified directory containing the Taskfile(s)
cd "$TASKDIR" || { echo "Error: Cannot change directory to $TASKDIR"; exit 1; }

# List all tasks using task --list-all.
# Remove any leading '*' or whitespace and any trailing colon.
# Filter lines that contain the provided prefix followed by a colon and then digits.
TASK_LIST=$(task --list-all | sed 's/^[*[:space:]]*//; s/:[[:space:]]*$//' | grep -E "((^)|(:))${PREFIX}:[0-9]+_")

if [ -z "$TASK_LIST" ]; then
  echo "Error: No tasks with prefix '${PREFIX}' found."
  exit 1
fi

# Extract and sort tasks by the sequential number following the provided prefix.
# This AWK command finds the first occurrence of "prefix:" in the line.
# It then extracts the substring immediately following that pattern and matches digits up to the underscore.
SORTED_TASKS=$(echo "$TASK_LIST" | awk -v prefix="$PREFIX" '{
  pos = index($0, prefix ":");
  if (pos > 0) {
    # Move past the prefix and the colon.
    pos += length(prefix) + 1;
    sub_line = substr($0, pos);
    # Look for digits at the beginning of the substring followed by an underscore.
    if (match(sub_line, /^[0-9]+_/)) {
      # Extract the number (excluding the trailing underscore).
      num = substr(sub_line, 1, RLENGTH-1);
      print num "\t" $0;
    }
  }
}' | sort -n | cut -f2)

if [ -z "$SORTED_TASKS" ]; then
  echo "Error: Failed to extract task numbers from tasks."
  exit 1
fi

# Execute each task in sorted order.
for task in $SORTED_TASKS; do
  echo "Running task: $task"
  task "$task"
done
