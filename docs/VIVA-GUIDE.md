# Ansible theory IA explanation and viva guide

## Explain the project in 30 seconds

“We use Ansible to configure the same web application for development, staging, and production. The tasks stay in one playbook, and each inventory group has its own variable values. Ansible connects to the servers over SSH, generates their files from shared templates, validates Nginx configuration, and reloads Nginx when necessary. We also show a production-only update and repeat the run to demonstrate idempotence.”

## Terms you should understand

| Term | Plain meaning | This project |
|---|---|---|
| Control node | The machine running Ansible | A temporary controller container |
| Managed node | A server Ansible configures | The development, staging, or production container |
| Inventory | List of hosts and groups | `inventory/hosts.ini` |
| Playbook | YAML instructions describing tasks and targets | `playbooks/deploy.yml` |
| Module | Ansible's implementation of a task | `file`, `template`, `uri`, `assert` |
| Variable | A value that can differ between environments | `app_log_level`, `app_debug` |
| Template | A file with placeholders filled from variables | `templates/config.json.j2` |
| Handler | A task triggered by a reported change | Reload Nginx |
| Idempotence | Repeating the same desired state needs no extra changes | `changed=0` on a repeat run |
| Configuration drift | Actual settings differ from the intended values | A manually edited file can be corrected by rerunning the playbook |
| Agentless | No persistent Ansible agent is installed on each target | SSH and Python run the modules |

## Questions and answers

**Why Ansible instead of manually copying files?** The same tasks run consistently across selected hosts. Variables avoid keeping three independent copies of the deployment logic, and the recap shows which tasks changed state or failed.

**Why does this use Docker?** Docker creates the small Linux lab machines on one laptop. Ansible performs configuration management inside them over SSH. Docker is the lab infrastructure, while Ansible is the tool under study.

**Are these real production servers?** No. They are three separate containers representing environment roles. The demo proves the configuration behavior locally and does not claim a public production deployment.

**Does Ansible need to be installed on every server?** No persistent Ansible agent is needed. These Linux targets provide SSH, Python, and a user account with the required privileges.

**What do YAML and Jinja2 do?** YAML stores the playbook and variable data. Jinja2 fills placeholders in templates to produce HTML, JSON, and Nginx configuration.

**Why can the second run report changed=0?** The file and template tasks compare the requested values with the files already present. When they match, there is nothing to update. The reload handler is only notified when the Nginx template changes.

**Does every Ansible task automatically behave this way?** No. A plain shell or command task can run every time. Here the reload command is a handler tied to configuration changes, and the stateful file/template modules manage their own comparisons.

**What does the debug variable actually do?** It is a visible application configuration example in the generated JSON and page. The static demo has no framework debugger. The Nginx log-level setting does affect the server's real error logging configuration.

**Does changing the displayed port change Docker's port mapping?** No. Docker Compose controls the host port mapping. The variable documents the corresponding public port on the page. Change both if you deliberately choose different ports.

**Why use an override file for the update?** It makes the live demo repeatable without editing YAML during the presentation. Extra variables take precedence over baseline group variables for that invocation. `--limit production` prevents that override from targeting the other groups.

**Does check mode guarantee a deployment will work?** No. It previews changes for modules that support it. This project's runtime HTTP checks are skipped during the preview; an actual deployment still verifies the health endpoint afterward.

**Why does Nginx reload rather than restart?** A reload makes Nginx read its new configuration. The template task first runs `nginx -t` against the candidate configuration and only installs valid configuration. The handler then reloads it.

**How would this expand to real servers?** Replace the container DNS names with server addresses in the inventory, use verified SSH keys and appropriate access control, and adapt service management and paths to the operating system. Protect secrets separately, for example with Ansible Vault. The playbook design still separates shared tasks from environment data.

**Why is there no GitHub Actions workflow?** The assessment demonstrates Ansible directly. A CI workflow is not needed to show configuration management and idempotence.
