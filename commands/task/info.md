---
description: Show config requirements for a specific trestle task
allowed-tools: Bash
user-invocable: true
argument-hint: "<task_name>"
---

Show the config requirements and options for a specific trestle task.

## Steps

1. Read $ARGUMENTS for:
   - `task_name`: the task to get info about

2. Run the task info command:
   ```
   trestle task <task_name> -i
   ```

3. Show the output. The output includes:
   - Required config keys
   - Optional config keys with defaults
   - Expected input and output formats
   - Example config.ini section

4. Show a sample `config.ini` section for the task:
   ```ini
   [task.<task_name>]
   input-dir = data/input
   output-dir = component-definitions/my-component
   ```

5. Tell the user that this section goes in `.trestle/config.ini`. Run the task with:
   ```
   trestle task <task_name>
   ```
