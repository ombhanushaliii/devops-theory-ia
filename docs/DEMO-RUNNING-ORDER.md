# Two-person presentation and live demo

Project: **Environment Specific Application Configuration and Deployment Using Ansible**

You present on **two separate laptops**. Each person runs the Docker lab on their own machine. Presenter 1 shows introduction through baseline deployment. Presenter 2 then continues from that checkpoint on their own laptop. Aim for about 12 minutes, allowing extra time for commands to finish.

`localhost` always means the laptop that is currently connected to the projector or screen share. Presenter 2 cannot use Presenter 1's running containers.

## What to send each person

- Presenter 1: `docs/PRESENTER-1-SCRIPT.md`. This covers the introduction through the baseline deployment.
- Presenter 2: `docs/PRESENTER-2-SCRIPT.md`. This starts after the handover and covers unchanged reruns, the production update and the conclusion.

Read only the paragraphs marked **SAY** aloud. Follow **DO**, **RUN** and **CHECK** as instructions. Run commands individually and wait for the prompt before continuing.

## PPT order

This script matches the existing 12-slide file: `deliverables/Ansible-Theory-IA-Presentation.pptx`. Show only the six slides below. The remaining slides can answer questions afterward.

| Order | Existing slide | Speaker | Screen/action |
|---|---|---|---|
| 1 | 1: project title | Presenter 1 | Introduce the problem and project |
| 2 | 4: Control node and managed nodes | Presenter 1 | Explain Docker, Ansible and SSH |
| 3 | 5: Environment settings | Presenter 1 | Explain settings, then show source, deploy and compare pages |
| Handover | Switch display to Presenter 2's laptop | Presenter 1 to Presenter 2 | Presenter 2 already matches the baseline checkpoint |
| 4 | 8: An unchanged rerun | Presenter 2 | Explain idempotence and prove it in the terminal |
| 5 | 9: Production only update | Presenter 2 | Preview, apply, compare and repeat the update |
| 6 | 12: Conclusion and scope | Presenter 2 | Recap the observed result and finish |

In PowerPoint Slide Show, type the slide number followed by Enter to jump directly to it. Use Alt+Tab on Windows or Command+Tab on macOS to switch to the terminal, browser or editor. On returning to PowerPoint, jump to the next slide in this table. Keep the numbered slide sequence unchanged.

The speaker scripts replace the older presenter allocation in the PPT notes for this demonstration. The PPT itself has not been edited.

## Before class: both laptops

Each presenter needs a full project copy, Docker Desktop with its Linux engine, and PowerPoint or the shared PPT open.

### Presenter 1 prep

Open a terminal in the project folder.

Windows PowerShell:

```powershell
cd D:\ansible-theory-ia
```

macOS Terminal, with the project copied to your home folder:

```bash
cd ~/ansible-theory-ia
```

Start the managed nodes:

```text
docker compose up -d --build development staging production
```

Wait until it finishes successfully. The first build downloads packages and can take several minutes. Leave the nodes running. Presenter 1 will run Ansible during the demonstration.

Open three browser tabs, but do not require the application pages yet:

- Development: http://localhost:8081
- Staging: http://localhost:8082
- Production: http://localhost:8083

If the lab is fresh, the initial pages may still be the default Nginx page. Presenter 1's baseline deployment creates the application pages.

### Presenter 2 prep

Presenter 2 must reach the **same checkpoint** on their own laptop before the presentation starts, because they will not inherit Presenter 1's containers.

In the project folder on Presenter 2's laptop:

```text
docker compose up -d --build development staging production
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

Confirm all of these on Presenter 2's machine:

- Baseline playbook completed with `failed=0` and `unreachable=0` for all hosts.
- Development at http://localhost:8081 shows log level `info`.
- Staging at http://localhost:8082 shows log level `notice`.
- Production at http://localhost:8083 shows log level `warn` and banner `Production environment ready for users`.

Leave Docker running. Open the PPT, editor, terminal in the project folder, and the three browser tabs. Do not run the production update until your spoken part begins.

## Handover

When Presenter 1 finishes speaking:

1. Presenter 1 stops sharing or disconnects their laptop from the display.
2. Presenter 2 connects their laptop and shows their already-prepared baseline.
3. Presenter 2 starts at slide **8** and continues from `docs/PRESENTER-2-SCRIPT.md`.

Do not rebuild, reset or stop Presenter 2's lab at the handover. Presenter 1's lab can stay running unused, or Presenter 1 can stop it after class.

## If something unexpected happens

**The baseline reports zero changes:** say, "These servers already have the requested baseline settings. We will now repeat the command to show that they remain unchanged." Continue normally.

**A command reports failed or unreachable:** pause at that command. Say, "The tool is reporting a connection or task error. We will inspect that before continuing." Run:

```text
docker compose ps
docker compose logs --tail 30 development staging production
```

Check Docker Desktop is running. Correct the reported problem, then rerun the failed command. Do not describe an unsuccessful command as successful. If the live environment cannot be recovered in the available time, clearly label any screenshots or logs shown from `evidence/` as a previous recorded run.

**A browser still shows the old page:** verify the URL and refresh. After the check-mode preview, the old production page is the expected result. The page should change only after applying the update.

**Presenter 2's laptop is not at the baseline checkpoint:** before going on screen, rerun the baseline playbook on that laptop and confirm the three browser pages match the handover table in `docs/PRESENTER-2-SCRIPT.md`.

## After the presentation

On whichever laptop still has the lab running, restore baseline configuration if you want the original values back:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

Stop the lab when finished:

```text
docker compose down
```

Keep both commands outside the spoken demonstration unless the examiner asks to see them.
