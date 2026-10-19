# Two-person presentation and live demo

Project: **Environment Specific Application Configuration and Deployment Using Ansible**

Use one laptop for the entire demonstration. Presenter 1 operates it until the handover. Presenter 2 then uses the same terminal, browser tabs and running lab. Aim for about 12 minutes, allowing extra time for commands to finish.

## What to send each person

- Presenter 1: `docs/PRESENTER-1-SCRIPT.md`. This covers the introduction through the baseline deployment.
- Presenter 2: `docs/PRESENTER-2-SCRIPT.md`. This starts at the handover and covers unchanged reruns, the production update and the conclusion.

Read only the paragraphs marked **SAY** aloud. Follow **DO**, **RUN** and **CHECK** as instructions. Run commands individually and wait for the prompt before continuing.

## PPT order

This script matches the existing 12-slide file: `deliverables/Ansible-Theory-IA-Presentation.pptx`. Show only the six slides below. The remaining slides can answer questions afterward.

| Order | Existing slide | Speaker | Screen/action |
|---|---|---|---|
| 1 | 1: project title | Presenter 1 | Introduce the problem and project |
| 2 | 4: Control node and managed nodes | Presenter 1 | Explain Docker, Ansible and SSH |
| 3 | 5: Environment settings | Presenter 1 | Explain settings, then show source, deploy and compare pages |
| Handover | Leave browser open | Presenter 1 to Presenter 2 | Baseline is deployed on all three nodes |
| 4 | 8: An unchanged rerun | Presenter 2 | Explain idempotence and prove it in the terminal |
| 5 | 9: Production only update | Presenter 2 | Preview, apply, compare and repeat the update |
| 6 | 12: Conclusion and scope | Presenter 2 | Recap the observed result and finish |

In PowerPoint Slide Show, type the slide number followed by Enter to jump directly to it. Use Alt+Tab on Windows or Command+Tab on macOS to switch to the terminal, browser or editor. On returning to PowerPoint, jump to the next slide in this table. Keep the numbered slide sequence unchanged.

The speaker scripts replace the older presenter allocation in the PPT notes for this demonstration. The PPT itself has not been edited.

## Start the lab

Open Docker Desktop and wait for its Linux engine. Open a terminal in the project folder.

Windows PowerShell:

```powershell
cd D:\ansible-theory-ia
```

macOS Terminal, with the project copied to your home folder:

```bash
cd ~/ansible-theory-ia
```

Run on either system:

```text
docker compose up -d --build development staging production
```

Wait until it finishes successfully. The first build downloads packages and can take several minutes. This command creates the lab machines. Presenter 1 will run Ansible to configure them during the demonstration.

Open the PPT in PowerPoint and the project folder in your editor. Open three browser tabs:

- Development: http://localhost:8081
- Staging: http://localhost:8082
- Production: http://localhost:8083

If the lab is fresh, the initial pages may still be the default Nginx page. Presenter 1's baseline deployment creates the application pages. If the lab already contains the application, use it as it is. A correct existing setup can produce `changed=0` even on the first command of this presentation.

## Handover checkpoint

Presenter 1 must finish with all of these true:

- SSH check returned `SUCCESS` and `pong` for all three hosts.
- Baseline playbook completed with `failed=0` and `unreachable=0` for all hosts.
- Development shows log level `info`, staging `notice`, and production `warn`.
- Production banner reads `Production environment ready for users`.

Presenter 2 starts here. On the same laptop, do not rebuild, reset or stop the lab at the handover. On a second laptop, the same checkpoint must already be established there because `localhost` refers to that laptop.

## If something unexpected happens

**The baseline reports zero changes:** say, "These servers already have the requested baseline settings. We will now repeat the command to show that they remain unchanged." Continue normally.

**A command reports failed or unreachable:** pause at that command. Say, "The tool is reporting a connection or task error. We will inspect that before continuing." Run:

```text
docker compose ps
docker compose logs --tail 30 development staging production
```

Check Docker Desktop is running. Correct the reported problem, then rerun the failed command. Do not describe an unsuccessful command as successful. If the live environment cannot be recovered in the available time, clearly label any screenshots or logs shown from `evidence/` as a previous recorded run.

**A browser still shows the old page:** verify the URL and refresh. After the check-mode preview, the old production page is the expected result. The page should change only after applying the update.

## After the presentation

Restore baseline configuration if you want the original values back:

```text
docker compose run --rm controller ansible-playbook playbooks/deploy.yml
```

Stop the lab when finished:

```text
docker compose down
```

Keep both commands outside the spoken demonstration unless the examiner asks to see them.
