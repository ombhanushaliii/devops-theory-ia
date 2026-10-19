## Slide 1

Presenter 1. Introduce the full project title. We use one Ansible playbook to configure a shared application differently for development, staging, and production. Fill the two student name and roll-number lines before presenting. The letterhead image comes from the user-provided report-format reference.

## Slide 2

Presenter 1. The same application can need different settings in different environments. Manual copying can leave the wrong value on a server. Our project separates environment data from shared deployment tasks. This is a configuration-management example, not a performance-testing project. Source: https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html

## Slide 3

Presenter 1. Inventory means the list of hosts. A playbook is a YAML task list. Variables supply environment values. Templates produce files. A handler runs after a relevant change. Ansible connects to these Linux nodes over SSH and uses Python. Sources: https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html
https://docs.ansible.com/projects/ansible/latest/inventory_guide/intro_inventory.html
https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/template_module.html
https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_handlers.html

## Slide 4

Presenter 1. Docker provides the Linux lab machines. The controller reads the project files and makes actual SSH connections to three managed nodes. Each target has Nginx and Python, with no persistent Ansible agent. This graph is captured from the actual ansible-inventory command. Source: https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html
Project evidence: evidence/inventory-graph.txt

## Slide 5

Presenter 1. Open inventory/group_vars and compare the environment YAML files. The same application and templates receive these different values. The debug flag illustrates a configuration value in this static site. The Nginx error-log level affects actual server configuration. Docker Compose owns the host-side port mappings. Source: project inventory/group_vars and compose.yaml.

## Slide 6

Presenter 1. The YAML file defines values. Jinja2 placeholders insert them into a shared file. This small Nginx example uses the real log-level value. The playbook template tasks also generate the page and JSON file. Sources: https://docs.ansible.com/projects/ansible/latest/inventory_guide/intro_inventory.html
https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/template_module.html

## Slide 7

Presenter 2. Open playbooks/deploy.yml. The tasks validate input, create the directory, deploy the page and JSON, validate Nginx configuration, then verify HTTP health. A changed Nginx template notifies the reload handler. Explain that nginx -t tests the proposed configuration before installation. Source: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/template_module.html
https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_handlers.html
Project source: playbooks/deploy.yml.

## Slide 8

Presenter 2. Show the baseline deployment, then rerun exactly the same playbook. The actual verification below reported no changes on any target, with no failed or unreachable hosts. Idempotence depends on the tasks used; a shell command does not automatically compare desired state. The handler is absent on this unchanged run. Source: https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html
Recorded evidence: evidence/06-baseline-repeat.txt

## Slide 9

Presenter 2. Preview the production override with --check --diff, then apply it with --limit production and the prepared extra-variable file. The preview left live configuration unchanged. The actual update changed production alone. Development and staging retained their original JSON settings. This image renders HTML captured from the running production node after the update. Source: https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_checkmode.html
Recorded evidence: evidence/07-preview-production.txt and evidence/08-apply-production-update.txt

## Slide 10

Presenter 2 operates the terminal and browser while Presenter 1 explains observations. Follow docs/DEMO-GUIDE.md for complete copy-ready Windows and macOS commands. Prefix each Ansible command with docker compose run --rm controller. Before class, build and start the targets. During the demo, show connectivity, baseline settings, an unchanged rerun, a production preview and update, and a repeat of the same override. Open localhost:8081, localhost:8082 and localhost:8083.

## Slide 11

Presenter 2. These values come from the actual Windows-laptop run on 19 October 2026. A changed count is a count of tasks, not settings or servers. Five initial changes include the directory, three templates and reload handler. The production update changes three templates and runs its handler. Check mode proposed file changes but wrote no deployment changes. All deployment runs had failed=0 and unreachable=0. The macOS commands are documented, but this execution occurred on Windows. Evidence: evidence/results.json.

## Slide 12

Presenter 1 closes. One playbook and shared templates produce each environment configuration. Scoped updates and repeated runs make the process easy to demonstrate and review. This is a local Docker lab with a static site, not publicly hosted infrastructure. Future extensions can add real servers, roles, protected secrets and application monitoring. No GitHub Actions workflow is needed for this assessment. References: https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html
https://docs.ansible.com/projects/ansible/latest/inventory_guide/intro_inventory.html
https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/template_module.html
https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html
https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_handlers.html
https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_checkmode.html
