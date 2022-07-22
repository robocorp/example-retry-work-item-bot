# Automatic Work Item Retrier Bot

This robot will list all processes in a workspace as configured from the provided vault and then find those work items which failed with an exception type of "APPLICATION", "ORCHESTRATOR", or "UNSPECIFIED" and retry them.

The robot expects the environment variable `WORKSPACE_CREDS` to point to the name of the vault item which contains the workspace api key. It defaults to "workspace_credentials". The vault object should have
two keys:
- `api_key`
- `workspace_id`

The vault item can include the key `process_id` to restrict this bot's actions to only one process.

The api key used must have the following permissions for this bot to function:
- `read_processes`
- `read_runs`
- `write_work_items`
- `read_work_items`
- `trigger_processes`