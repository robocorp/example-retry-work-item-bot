*** Settings ***
Documentation
...                 This robot will list all processes in a workspace as configured from the
...                 provided vault and then find those work items which failed with an
...                 exception type of "APPLICATION", "ORCHESTRATOR", or "UNSPECIFIED" and
...                 retry them.
...
...                 The robot expects the environment variable ``WORKSPACE_CREDS`` to point
...                 to the name of the vault item which contains the workspace apikey.
...                 It defaults to "workspace_credentials". The vault object should have
...                 two keys:
...                 - ``api_key``
...                 - ``workspace_id``
...
...                 The vault item can include the key ``process_id`` to restrict this bot's
...                 actions to only one process.

Library             RPA.Robocorp.Process
Library             RPA.Robocorp.Vault


*** Tasks ***
Retry Failed Work Items
    [Documentation]
    ...    Pulls all processes within the provided workspace and retries those
    ...    that failed with an exception type of "APPLICATION", "ORCHESTRATOR",
    ...    or "UNSPECIFIED"
    ${one_process}=    Setup process library
    IF    ${one_process}
        Retry failed work items
    ELSE
        ${processes}=    List processes
        FOR    ${process}    IN    @{processes}
            Retry failed work items    ${process}[id]
        END
    END


*** Keywords ***
Setup process library
    [Documentation]
    ...    Sets the secrets needed by the Process library to perform the retry actions.
    ...    Returns a bool indicating whether a single process id was set or not.
    ${workspace_creds}=    Get secret    %{WORKSPACE_CREDS=workspace_credentials}
    Set apikey    ${workspace_creds}[api_key]
    Set workspace id    ${workspace_creds}[workspace_id]
    IF    $workspace_creds.get("process_id")
        Set process id    ${workspace_creds}[process_id]
        RETURN    ${True}
    ELSE
        RETURN    ${False}
    END

Retry failed work items
    [Documentation]
    ...    Retries all failed work items in the provided process_id with an exception type
    ...    of "APPLICATION", "ORCHESTRATOR", or "UNSPECIFIED".
    [Arguments]    ${process_id}=${None}
    ${failed_work_items}=    List process work items    ${process_id}    item_state=FAILED
    FOR    ${work_item}    IN    @{failed_work_items}
        IF    "${work_item}[exception][type]" in ["APPLICATION", "ORCHESTRATOR", "UNSPECIFIED"]
            Retry work item    ${work_item}[id]    ${process_id}
        END
    END
