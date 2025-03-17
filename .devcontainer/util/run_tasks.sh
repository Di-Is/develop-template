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
# 1. Remove leading '*'や空白を削除
# 2. 先頭のフィールド(タスク名)のみを抽出
TASK_LIST=$(task --list-all | sed 's/^[*[:space:]]*//' | awk '{print $1}' | grep -E "((^)|(:))${PREFIX}:[0-9]+_")

if [ -z "$TASK_LIST" ]; then
  echo "Error: No tasks with prefix '${PREFIX}' found."
  exit 1
fi

# Extract and sort tasks by the sequential number following the provided prefix.
SORTED_TASKS=$(echo "$TASK_LIST" | awk -v prefix="$PREFIX" '{
  taskName = $0;
  # Remove trailing colon if present.
  sub(/:$/, "", taskName);
  pos = index(taskName, prefix ":");
  if (pos > 0) {
    pos += length(prefix) + 1;
    sub_line = substr(taskName, pos);
    if (match(sub_line, /^[0-9]+_/)) {
      num = substr(sub_line, 1, RLENGTH-1);
      print num "\t" taskName;
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
