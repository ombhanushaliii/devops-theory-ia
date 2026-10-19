# Ansible theory IA live demo guide

Project title: **Environment Specific Application Configuration and Deployment Using Ansible**.

The demonstration uses one controller and three managed nodes in Docker. The commands below work in Windows PowerShell and macOS Terminal. Docker Desktop must be running with its Linux engine. You do not need to install Ansible directly on Windows or macOS.

## Start the lab

Windows:

```powershell
cd D:\ansible-theory-ia
```

macOS, assuming you copied the project into your home directory:

```bash
cd ~/ansible-theory-ia
```

Build and start the lab on either system:

```text
docker compose up -d --build development staging production
```

## Presenter 1 opening

Say: “Our application needs different configuration in development, staging, and production. Editing every server manually can cause mistakes. We use one Ansible playbook with different environment variables to apply the correct settings consistently.”

Show these source files in your editor:

1. `inventory/hosts.ini`: the three hosts grouped by environment.
2. `inventory/group_vars/development.yml` and `production.yml`: different settings.
3. `templates/config.json.j2`: one template with variable placeholders.
4. `playbooks/deploy.yml`: the shared tasks.

Say: “The inventory tells Ansible which hosts to manage. Variables supply the values. The template is the reusable file design. The playbook tells Ansible what to do.”

## Step 1 check the connections

```text
docker compose run --rm controller ansible web -m ansible.builtin.ping
```

Look for `SUCCESS` and `pong` for all three hosts. This is an Ansible module check over SSH, not an ICMP network ping. It confirms that Ansible can connect and run Python on the managed nodes.

The prefix `docker compose run --rm controller` starts the Linux control-node container and removes that temporary controller instance afterward. The actual tool command begins at `ansible` or `ansible-playbook`. The web-server containers keep running.

## Step 2 deploy the baseline

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

Show the tasks as they run. On fresh nodes, file and template tasks report changes. On configured nodes, matching files report `ok`. Every node should finish with `failed=0` and `unreachable=0`.

Open these pages side by side:

- http://localhost:8081 — development, debug enabled, log level `info`.
- http://localhost:8082 — staging, debug disabled, log level `notice`.
- http://localhost:8083 — production, debug disabled, log level `warn`.

Say: “The page template and playbook are shared. The inventory group supplies each environment's settings. Ansible wrote different configuration files on the three servers.”

Click **View the deployed JSON configuration** on a page. Explain that the displayed configuration comes from files Ansible actually generated. The debug flag is illustrative; the static site does not run a framework debugger.

## Step 3 demonstrate idempotence

Run exactly the same command again:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

Point to `changed=0` for each host in `PLAY RECAP`.

Say: “Idempotence means we can ask for the same state repeatedly. When the files already match, Ansible does not rewrite them. This is why rerunning our configuration is safe in this lab.”

The file and template modules compare state. The Nginx reload command only runs as a handler after its configuration changes.

## Presenter 2 handover

Say: “We will now update only production and leave the other environments at their baseline settings.”

Open `demo/production-update.yml`. It changes the banner and Nginx log level from `warn` to `error`.

## Step 4 preview the production update

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml --limit production -e "@demo/production-update.yml" --check --diff
```

Explain the options:

- `--limit production` selects the production inventory group.
- `-e "@demo/production-update.yml"` supplies the prepared override values. Extra variables override the baseline group variables for this invocation.
- `--check` predicts supported changes without writing the files.
- `--diff` shows before-and-after text.

Refresh production. Its banner should still be the baseline one, because the preview did not apply the update. The HTTP health tasks are intentionally skipped in check mode.

## Step 5 apply the same update

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml --limit production -e "@demo/production-update.yml"
```

Refresh http://localhost:8083. The banner should now say **Production settings updated using Ansible**, and the log level should be `error`. Development and staging retain their original settings. The run should list only `prod-server` in the recap.

Say: “Ansible used the same deployment tasks. We limited the target group and supplied new values. The Nginx configuration changed, so its handler reloaded Nginx after validation.”

## Step 6 show that the updated state is repeatable

Run the same command with the same override again:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml --limit production -e "@demo/production-update.yml"
```

Expected: production reports `changed=0`. The Nginx handler should not run.

Say: “The updated settings are now the requested state, so a repeat run makes no changes.”

## Finish

Say: “We demonstrated environment-specific configuration, a scoped production update, a preview before applying changes, and repeat runs without unnecessary changes.”

To restore the baseline values:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

To stop the lab afterward:

```text
docker compose down
```

This stops this project's containers and retains its SSH key volumes.

## Troubleshooting

- **Cannot connect to Docker:** open Docker Desktop and wait for the Linux engine.
- **Port 8081, 8082, or 8083 occupied:** close the conflicting app or change the relevant host-side mapping in `compose.yaml`; update the matching `app_public_port` in group variables and use the new browser URL.
- **UNREACHABLE:** make sure the target containers are healthy with `docker compose ps`. Check their logs with `docker compose logs development staging production`.
- **A task is FAILED:** read that task's message. `nginx -t` validates the configuration before installation. Keep the source error visible while fixing it.
- **The preview says changed but the browser is unchanged:** this is expected in `--check` mode. Apply the command without `--check --diff`.
- **The baseline command resets production:** expected. The baseline group variables remain in the repository; the update override only applies to commands that include `-e "@demo/production-update.yml"`.
