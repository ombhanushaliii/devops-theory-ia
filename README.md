# Environment Specific Application Configuration and Deployment Using Ansible

A theory IA project with a practical configuration-management demonstration. One playbook configures a Campus Helpdesk web page differently in development, staging, and production.

The project uses a Linux Ansible controller and three Linux managed nodes in Docker containers. Ansible makes real SSH connections to the nodes. Docker provides the lab machines; Ansible writes their application and Nginx configuration.

## Report and presentation

- [Editable report](deliverables/Ansible-Theory-IA-Report.docx): 20 pages following the supplied report format, with two student-detail slots.
- [Report PDF](deliverables/Ansible-Theory-IA-Report.pdf): the matching rendered report.
- [Presentation](deliverables/Ansible-Theory-IA-Presentation.pptx): 12 editable slides with speaker notes.
- [Live demo guide](docs/DEMO-GUIDE.md): copy-ready Windows and macOS commands with explanations.
- [Viva guide](docs/VIVA-GUIDE.md): definitions and likely questions.
- [Presenter notes](docs/PRESENTER-NOTES.md): a separate copy of the slide notes.

The local demonstration was verified on Windows on 19 October 2026. Recorded evidence confirms baseline deployment, unchanged reruns, a preview without deployment changes, and an update confined to production. The same container-based commands are documented for macOS; they have not been executed on a Mac in this verification.

## Start here

Install and start Docker Desktop with Linux containers. No separate Ansible, Python, Node.js, or WSL Ubuntu installation is needed on the host. The first build needs internet access to download images and packages. Later runs use the built images.

Windows PowerShell:

```powershell
cd D:\ansible-theory-ia
```

macOS Terminal, if the folder is in your home directory:

```bash
cd ~/ansible-theory-ia
```

Run these commands one at a time on either operating system:

```text
docker compose up -d --build development staging production
docker compose run --rm controller ansible web -m ansible.builtin.ping
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

Open the three environments:

- Development: http://localhost:8081
- Staging: http://localhost:8082
- Production: http://localhost:8083

Run the same playbook again. Each host should report `changed=0`, `failed=0`, and `unreachable=0` when its files already match the requested state:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

Preview a production update without applying it:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml --limit production -e "@demo/production-update.yml" --check --diff
```

Apply that update, then refresh production. Its banner changes and its Nginx error log level becomes `error`. Development and staging retain their original values:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml --limit production -e "@demo/production-update.yml"
```

Repeat the **same command with the same override** to show `changed=0` for production:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml --limit production -e "@demo/production-update.yml"
```

To restore the baseline, run the playbook without the override. To stop and remove this lab's containers, run `down`; the lab's SSH key volumes remain:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
docker compose down
```

For a fresh first-deployment demonstration, run `docker compose down` and then start the three target services again. Their generated server files are recreated by the next playbook run. The project source, report, and evidence stay in this folder. This lets you show the initial deployment making changes, followed by the unchanged rerun.

## Project files

| File | Purpose |
|---|---|
| `inventory/hosts.ini` | Lists the three hosts and their environment groups |
| `inventory/group_vars/all.yml` | Shared application settings |
| `inventory/group_vars/*.yml` | Settings for each environment |
| `playbooks/deploy.yml` | One shared deployment playbook |
| `templates/*.j2` | Shared HTML, JSON, and Nginx templates |
| `demo/production-update.yml` | Two deliberate production overrides for the demo |
| `ansible.cfg` | Inventory path, SSH connection, and privilege settings |
| `compose.yaml` | Creates the controller and managed nodes |
| `docker/` | Prepares SSH access and starts the lab servers |
| `docs/DEMO-GUIDE.md` | Step-by-step presenter instructions |
| `docs/VIVA-GUIDE.md` | Plain-language explanations and likely questions |
| `deliverables/` | Report and presentation when generated |
| `evidence/` | Actual validation logs and server responses when recorded |

## Scope

The managed nodes are separate containers on one laptop. They simulate development, staging, and production; there are no public cloud servers. Nginx serves a static page and real JSON configuration. The debug flag illustrates an application setting; it does not activate a framework debugger. The configured Nginx error log level does affect the server. Host ports come from Docker Compose, and the matching values in the inventory document those mappings.

SSH host checking is disabled for this disposable Docker lab. Use verified host keys and appropriately scoped credentials when adapting the design to real servers. No secrets belong in the example group variables. The project does not include GitHub Actions.

## Official references

- [Ansible installation and control node requirements](https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html)
- [Ansible inventory and group variables](https://docs.ansible.com/projects/ansible/latest/inventory_guide/intro_inventory.html)
- [Playbooks and idempotence](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html)
- [The template module](https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/template_module.html)
- [Handlers](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_handlers.html)
- [Check and diff modes](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_checkmode.html)
- [Docker Compose](https://docs.docker.com/compose/)
