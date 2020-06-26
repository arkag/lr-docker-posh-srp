# LogRhythm Docker Remediation SRP

Welcome to the Docker Remediation SRP repo!

Have questions, concerns, or would like to request a feature? Toss these into an Issue so I can track it.

# Requirements

- LogRhythm Install
- Docker Events service on your Docker host (to be added to this repo)
- cronjob created to rotate logs (to be added to this repo)
- Docker Events MPE rules and sub-rules inside of LogRhythm (to be added to this repo)
- Posh-SSH PowerShell module
- SSH key access from a Windows LR SMA (whatever host this is to be run on) to your Docker Node(s)
- The will of fire

# Current Limitations (to be fixed)

- [ ] Hosts are not prepended to the events logs, making it difficult to support more than one Docker host at this time

I'm sure there are more, so open an issue and we can add more above!

# Roadmap

- [ ] Pivot to utilizing LR Tools after 1.0 is released.
- [ ] Add aditional features to improve usability past just stopping and removing an image
- [ ] Add Docker Events service to repo
- [ ] Add recommended cronjob to repo
- [ ] Add Docker Events MPE rules to repo