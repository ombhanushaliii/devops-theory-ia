# Presenter 2 script: repeat runs, production update and conclusion

Your part: about 5 to 6 minutes plus command execution. You start after Presenter 1 finishes the baseline demo. You demonstrate idempotence, preview a production change, apply it, verify that only production changed, repeat it and close the presentation.

You and Presenter 1 use **separate laptops**. Before class, prepare your own lab to the baseline checkpoint using `docs/DEMO-RUNNING-ORDER.md`. You do not take over Presenter 1's terminal, browser or containers. When they finish, connect your laptop to the display and continue from here.

**SAY** means read the paragraph aloud. **DO**, **RUN** and **CHECK** are instructions for you. Run one command at a time and wait for the prompt.

## Your starting point

Before connecting to the display, confirm your laptop already matches this baseline:

| Environment | Browser URL | Log level |
|---|---|---|
| Development | http://localhost:8081 | info |
| Staging | http://localhost:8082 | notice |
| Production | http://localhost:8083 | warn |

Production's banner should read **Production environment ready for users**. The baseline playbook must have finished with `failed=0` and `unreachable=0` for all three hosts.

If anything is missing, run these on your laptop before going on screen:

```text
docker compose up -d --build development staging production
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

The terminal should already be in the project folder. Only if you open a new terminal, run the appropriate directory command:

Windows:

```powershell
cd D:\ansible-theory-ia
```

macOS, assuming the project is in your home folder:

```bash
cd ~/ansible-theory-ia
```

Open PowerPoint, the editor, the three browser tabs and the terminal before Presenter 1 finishes. At handover, switch the display to your laptop and begin at section 1.

## 1. Explain idempotence

**DO:** Show PowerPoint slide **8**, **An unchanged rerun**.

**SAY:**

"We have seen the baseline deployment. I will now show idempotence. That means asking for the same desired state again does not require additional changes when the server already matches it."

"For example, if we ask Ansible to place a particular configuration file on a server and the correct file is already there, its template task leaves that file unchanged. Let us prove that by running exactly the same playbook again."

**DO:** Switch to the terminal.

**RUN:**

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

**CHECK:** Wait for the recap. All three hosts should report `changed=0`, `failed=0` and `unreachable=0`.

**SAY:**

"Each server reports changed equals zero. The files already match the requested baseline. No Nginx reload handler ran because the Nginx template did not change. This shows that repeating our deployment avoids unnecessary changes."

## 2. Introduce the production change

**DO:** Return to PowerPoint and jump to slide **9**, **Production only update**.

**SAY:**

"Now suppose we want to update production while keeping development and staging as they are. We will change production's banner and its Nginx log level from warn to error. We will first preview the changes, then apply them."

**DO:** Switch to the editor and open `demo/production-update.yml`.

The file should contain these values:

```yaml
app_banner: Production settings updated using Ansible
app_log_level: error
```

**SAY:**

"This small file contains the two values we want to override for this run. The original production settings remain in the group variables file. We will pass this override file to the same playbook and select production as the target."

## 3. Preview without applying

**DO:** Switch to the terminal.

**SAY:**

"Limit production selects the production group. Dash e loads the override values from this file. Check mode previews the supported changes, and diff shows the proposed differences in the file contents."

**RUN:**

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml --limit production -e "@demo/production-update.yml" --check --diff
```

**CHECK:** The output should target only `prod-server`. Find the proposed change from `warn` to `error` and the banner change. Some health tasks are skipped in check mode by design. A nonzero changed count here describes proposed changes.

**SAY:**

"The diff shows what Ansible proposes to change. Because we used check mode, these configuration files have not been deployed. The changed count in this preview represents predicted changes."

**DO:** Switch to the browser and refresh http://localhost:8083.

**CHECK:** Production still shows log level **warn** and banner **Production environment ready for users**.

**SAY:**

"The production page still shows warn and the original banner. That confirms the preview did not apply the update."

## 4. Apply the production update

**DO:** Switch to the terminal.

**SAY:**

"Now I will run the same production command without check and diff, so Ansible applies the changes."

**RUN:**

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml --limit production -e "@demo/production-update.yml"
```

**CHECK:** Wait for the recap. It should list only `prod-server` and show `failed=0` and `unreachable=0`. Look for **RUNNING HANDLER ... Reload Nginx** in the preceding output.

**SAY:**

"Only production appears in the recap because we limited the target group. The templates changed, and the Nginx configuration passed its validation check. The changed configuration notified the reload handler, so Nginx loaded its new settings."

If asked about the count: the tested baseline-to-update run reported four changed tasks: the page template, JSON template, Nginx template and reload handler. Two overridden values can affect several files. Read the actual recap rather than promising a fixed count.

## 5. Prove the environments differ as intended

**DO:** Switch to the browser. Refresh production first.

**CHECK:** Production at http://localhost:8083 now shows:

- Banner: **Production settings updated using Ansible**
- Log level: **error**

**SAY:**

"Production now shows the new banner and log level error."

**DO:** Click **View the deployed JSON configuration** on production. Point to the updated banner and log level, then return to the page.

**SAY:**

"The generated JSON also contains the updated values."

**DO:** Refresh development at http://localhost:8081 and staging at http://localhost:8082.

**CHECK:** Development still shows **info**, staging still shows **notice**, and both retain their baseline banners.

**SAY:**

"Development and staging retain their original settings. The production limit let us apply the update to the intended environment using the same shared playbook."

## 6. Repeat the same update

**DO:** Switch to the terminal. Include the same override file again. Running the plain baseline command here would restore the original production settings.

**SAY:**

"We will repeat this exact update once more. Now the requested state includes the new production values."

**RUN:**

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml --limit production -e "@demo/production-update.yml"
```

**CHECK:** Production should report `changed=0`, `failed=0` and `unreachable=0`. The reload handler should not run on this unchanged repeat.

**SAY:**

"Production reports changed equals zero. It already has the requested updated configuration. We have shown that the same approach works for both the original configuration and the updated configuration."

## 7. Conclusion

**DO:** Return to PowerPoint and jump to slide **12**, **Conclusion and scope**.

**SAY:**

"Our demonstration showed one Ansible playbook configuring the same application differently in development, staging and production. We checked connectivity, deployed the baseline and repeated it without unnecessary changes. We then previewed and applied a production update while leaving the other environments unchanged."

"Docker provided the local Linux machines. Ansible performed the configuration through SSH. Our application is a static website with generated configuration, which keeps the effect of each setting easy to inspect."

"This reduces repeated manual editing and makes the configuration process easier to repeat. Thank you. We are ready for questions."

**DO:** Stop speaking here. Leave your lab running for questions. You do not need to run GitHub Actions or push anything during this demonstration.

## Short answers if the examiner asks

**What did Ansible actually change?**

"It created the application directory, generated the page and JSON files, and installed a validated Nginx configuration. When that configuration changed, its handler reloaded Nginx."

**What is idempotence?**

"Repeating the same request requires no further changes once the server matches it. We demonstrated it through changed equals zero on repeated runs."

**Is check mode a complete test?**

"It previews changes for tasks that support it. In our playbook, the live HTTP verification tasks are skipped in check mode. We verify the running service after applying the configuration."

**Why is this agentless?**

"We do not install a persistent Ansible agent on each managed node. The controller connects through SSH and runs the required modules using Python."

**What happens if you run the plain playbook now?**

"It restores the baseline production values because that command does not include our override file. Ansible applies the values requested by the current invocation."

**How would this use real servers?**

"We would replace the container hostnames with the server addresses in the inventory and configure appropriate SSH access. The environment variables and shared deployment tasks follow the same structure."
