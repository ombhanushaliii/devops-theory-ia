# Presenter 1 script: introduction to baseline deployment

Your part: about 5 to 6 minutes plus command execution. You introduce the project, explain the files, check connections, deploy the baseline and show the three environments. Then your friend takes over.

Use the same laptop throughout. Start the lab using `docs/DEMO-RUNNING-ORDER.md`. Presenter 2 needs the running baseline you create.

**SAY** means read the paragraph aloud. **DO**, **RUN** and **CHECK** are instructions for you. Commands work in Windows PowerShell and macOS Terminal after entering the project directory.

## 1. Introduction

**DO:** Show slide **1**, the project title. Replace the name and roll-number blanks in your PPT with your details before using it.

**SAY:**

"Good morning. We are [your name] and [friend's name]. Our project is Environment Specific Application Configuration and Deployment Using Ansible."

"An application usually has different environments. Development is where developers work on changes. Staging is where a release is reviewed and tested. Production is the environment intended for users. In our project, we represent these environments using three separate Linux containers."

"These environments need different settings. If we edit every server manually, we can put the wrong value on a server or forget an update. We use Ansible to describe the required settings in files and apply them using one shared set of tasks."

"I will explain the setup and deploy the initial configuration. My teammate will then show what happens when we repeat the deployment and update only production."

## 2. Explain how the machines connect

**DO:** Jump to slide **4**, **Control node and managed nodes**.

**SAY:**

"Docker creates the Linux machines for our lab. One container acts as the control node, which runs Ansible. Three other containers act as the managed servers. Each server runs Nginx, which serves our web page."

"Ansible connects from the controller to these servers using SSH. SSH is the connection used to access a remote machine securely. Ansible then runs its configuration tasks on each selected server."

"The division is simple: Docker provides the machines. Ansible configures the application files and web server settings inside those machines. Everything here runs locally on this laptop."

## 3. Explain the settings

**DO:** Jump to slide **5**, **Environment settings**.

**SAY:**

"We use a small Campus Helpdesk web page to make the configuration visible. Development has the debug flag enabled and log level info. Staging has debug disabled and log level notice. Production has debug disabled and log level warn."

"A log level controls which types of messages the web server records. Info includes more detail. Warn records warnings and more serious messages. Later, we will change production to error, which records errors and more serious messages."

"The debug flag is a sample application setting displayed in our page and JSON. This is a static website, so that flag does not start a real application debugger. The Nginx log level does change the web server's actual configuration."

"The three browser ports let us visit each environment separately on one laptop. Docker Compose maps these ports to the corresponding web servers."

## 4. Show the actual source files

**DO:** Switch from PowerPoint to the editor. Open these files in order. Point at the named section while speaking. You do not need to edit anything live.

### File A: `inventory/hosts.ini`

**SAY:**

"The inventory is the list of machines Ansible manages. Here, we have a development group, a staging group and a production group. The web group contains all three. That allows us to select every environment or just one environment."

### File B: `inventory/group_vars/development.yml`, then `inventory/group_vars/production.yml`

**DO:** Point to `app_environment`, `app_debug` and `app_log_level`.

**SAY:**

"These files supply the values for each group. Notice that development uses info while production uses warn. We keep the environment values separate from the deployment tasks, so we can reuse the same tasks."

### File C: `templates/nginx.conf.j2`

**DO:** Find `error_log` and point at `{{ app_log_level }}`.

**SAY:**

"This is a shared template. A template is a file with placeholders. Ansible replaces this placeholder with the log level of the target environment. It produces a complete Nginx configuration file for each server. We also have templates for the web page and JSON configuration."

### File D: `playbooks/deploy.yml`

**DO:** Point to the task names and then the `handlers` section at the bottom.

**SAY:**

"The playbook is the task list. It validates the input values, creates the application folder and generates the required files. It checks the proposed Nginx configuration before installing it, then verifies the running environment through an HTTP health endpoint."

"If the Nginx configuration changes, it triggers a handler. A handler is a task that runs when notified by a change. Our handler reloads Nginx so it uses the new configuration."

## 5. Check the connections

**DO:** Switch to your terminal. If it is a new terminal, enter the project folder first.

Windows:

```powershell
cd D:\ansible-theory-ia
```

macOS, assuming the project is in your home folder:

```bash
cd ~/ansible-theory-ia
```

**SAY:**

"First, we will confirm that Ansible can connect to all three servers. In these commands, docker compose run starts the controller container. The actual Ansible command begins at ansible. The option dash dash rm removes the temporary controller afterward. The three web servers keep running."

**RUN:**

```text
docker compose run --rm controller ansible web -m ansible.builtin.ping
```

**CHECK:** Wait for `SUCCESS` and `pong` from `dev-server`, `staging-server` and `prod-server`. Do not continue past a connection failure.

**SAY:**

"All three hosts returned success and pong. This Ansible ping module checks that Ansible can connect and execute Python on each server."

## 6. Deploy the baseline

**SAY:**

"Now we will run the shared playbook. Baseline means the original settings defined in our environment files."

**RUN:**

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

**CHECK:** Wait for `PLAY RECAP`. Each host must show `failed=0` and `unreachable=0`.

**SAY:**

"The playbook has finished for all three servers. Failed equals zero means no tasks failed. Unreachable equals zero means Ansible could reach the hosts. Changed counts the tasks that modified the server's state. It does not count the number of servers or individual settings."

**IF changes are reported, SAY:**

"The changed tasks applied the files or configuration that differed from our requested baseline."

**IF changed is zero, SAY instead:**

"These servers already had the requested baseline configuration, so this run needed no changes. That is a valid result."

Do not promise a particular changed count. The recorded fresh installation had five changed tasks per host, but a previously configured lab can have fewer.

## 7. Show the result and hand over

**DO:** Switch to the browser. Open and refresh each tab in this order:

| URL | Point to these values |
|---|---|
| http://localhost:8081 | development, debug enabled, log level info |
| http://localhost:8082 | staging, debug disabled, log level notice |
| http://localhost:8083 | production, debug disabled, log level warn |

**SAY:**

"These are the three running environments. The same playbook and templates produced each page, while the group variables supplied the differences."

**DO:** On the production page, click **View the deployed JSON configuration**. Point to the environment, debug and log-level values, then return to the application page.

**SAY:**

"This JSON is a file Ansible generated on the production server. It shows the configuration we just deployed."

**CHECK:** Production's banner reads **Production environment ready for users** and its log level is **warn**. Leave the production tab open. Leave the terminal in the same project directory.

**SAY, EXACT HANDOVER:**

"We have now deployed the original settings to all three environments. My teammate will show how Ansible handles the same request again, then preview and apply a change to production alone."

**DO:** Hand the laptop controls to your friend. Your speaking part is complete. Let your friend deliver the conclusion too, so there is only one handover.
