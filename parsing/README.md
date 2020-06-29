# Parsing Set Up

In order to get this configured on your system, you'll need to set up:

- Custom Log Processing Policy
- Custom MPE Rules and Sub-rules
- Docker events log source

## Custom Log Processing Policy

From the LogRhythm Console: 

- Tools > Knowledge > Log Source Type Manager 
- Right-click > New
- Log Source Type Properties
    - Name: Flat File - Docker Events
    - Abbreviation: Docker Events
    - Log Format: Text File
    - Brief Description: Docker Events turned into a systemd service and ingested as a flat file by an SMA.
- Deployment Manager > Log Processing Policies
- Right-click > New
- Custom > Search for Docker > Double Click on Flat File - Docker Events
- Name: Flat File - Docker Events > OK

## Custom MPE Rules and Sub-rules

- Tools > Knowledge > MPE Rule Builder
    - Rule Name: Flat File - Docker Events - Docker Compose
    - Common Event: General Information
    - Rule Status: Production
    - Log Message Source Type Associations: Flat File - Docker Events
    - Base-rule Regular Expression: ^.*?\s(?<action>.*?\s.*?)\s(?<object>.*?)\s\(com.docker.compose.config-hash=(?<hash>.*?),\s(com.docker.compose.container-number=(?<processid>.*?)),\s(?<status>com.docker.compose.oneoff=.*?),\s(?<reason>com.docker.compose.project=.*?),\s(?<parentprocessid>com.docker.compose.project.config_files=.*?),\s(?<parentprocesspath>com.docker.compose.project.working_dir=.*?),\s(com.docker.compose.service=(?<process>.*?)),\s(?<version>com.docker.compose.version=.*?),\simage=(?<objecttype>.*?),\sname=(?<objectname>.*?)\)
    - Sub-Rules:
        -   
            - Rule Name: Container Kill
            - Common Event: Process/Service Stopping
            - action Equal To (=) container kill
        -   
            - Rule Name: Container Destroy
            - Common Event: Process/Service Stopped
            - action Equal To (=) container destroy
        -   
            - Rule Name: Container Delete
            - Common Event: Process/Service Stopped
            - action Equal To (=) container delete
        -   
            - Rule Name: Container Die
            - Common Event: Process/Service Stopped
            - action Equal To (=) container die
        -   
            - Rule Name: Container Create
            - Common Event: Process/Service Starting
            - action Equal To (=) container create
        -   
            - Rule Name: Container Start
            - Common Event: Process/Service Started
            - action Equal To (=) container start
    - Right-click in Sub-Rules section > Synchronize with Base-rule > Rule Status
    - Top left corner below file > hit save icon
- Top left corner next to save icon > hit plus icon
    - Rule Name: Flat File - Docker Events
    - Common Event: General Information
    - Rule Status: Production
    - Log Message Source Type Associations: Flat File - Docker Events
    - Base-rule Regular Expression: ^.*?\s(?<action>.*?\s.*?)\s(?<object>.*?)\s\(((container=(?<hash>.*?),\s)?(exitCode=(?<responsecode>\d+),\s)?(image=(?<objecttype>.*?),\s)?(maintainer=(?<login>.*?),\s)?(name=(?<objectname>.*?))?(,\stype=(?<objecttype>.*?))?)\)
    - Sub-Rules:
        -   
            - Rule Name: Container Attach
            - Common Event: Attach Event
            - action Equal To (=) container attach
        -   
            - Rule Name: Container Create
            - Common Event: Process/Service Starting
            - action Equal To (=) container create
        -   
            - Rule Name: Container Destroy
            - Common Event: Process/Service Stopped
            - action Equal To (=) container destroy
        -   
            - Rule Name: Container Die
            - Common Event: Process/Service Stopped
            - action Equal To (=) container die
        -   
            - Rule Name: Container Kill
            - Common Event: Process/Service Stopping
            - action Equal To (=) container kill
        -   
            - Rule Name: Container Start
            - Common Event: Process/Service Started
            - action Equal To (=) container start
        -   
            - Rule Name: Container Stop
            - Common Event: Process/Service Stopping
            - action Equal To (=) container stop
        -   
            - Rule Name: Image Delete
            - Common Event: Resource Terminated
            - action Equal To (=) image delete
        -   
            - Rule Name: Image Pull
            - Common Event: Saving New System Software Image To Flash
            - action Equal To (=) image pull
        -   
            - Rule Name: Image Tag
            - Common Event: General Operations
            - action Equal To (=) image tag
        -   
            - Rule Name: Image Untag
            - Common Event: General Operations
            - action Equal To (=) image untag
        -   
            - Rule Name: Network Connect
            - Common Event: Network Connection Established
            - action Equal To (=) network connect
        -   
            - Rule Name: Network Disconnect
            - Common Event: Client Disconnected
            - action Equal To (=) network disconnect
    - Right-click in Sub-Rules section > Synchronize with Base-rule > Rule Status
    - Top left corner below file > hit save icon
- Top left corner next to save icon > hit plus icon
    - Rule Name: Flat File - Docker Events - Catchall
    - Common Event: General Information
    - Rule Status: Production
    - Log Message Source Type Associations: Flat File - Docker Events
    - Base-rule Regular Expression: ^.*?\s(?<action>.*?\s.*?)\s<object>\s\((?<vendorinfo>.*?)\)
    - Sub-Rules: N/A
    - Top left corner below file > hit save icon
- Deployment Manager > Log Processing Policies > Double-click on Flat File - Docker Events
- Right-click in Rules section > Check all > Right-click in Rules section > Properties
- MPE Policy Rule Editor
    - [x] Enabled
    - Log Processing Settings: [x] Disable Automatic Host Contextualization
    - Event Management Settings: [x] Log should be forwarded as event
    - Risk Rating: 5 - Medium-Medium
- Hit OK

## Docker Event Log Source

This assumes you've already onboarded the Docker host's SMA as per standard LR procedure.

From LogRhythm Console:

- Deployment Manager > System Monitors
- Right-click on Docker host > Properties
- Right-click in Log Source section > New 
- Basic Configuration tab
    - Log Message Source Type: Flat File - Docker Events
    - Log message Prcoessing Engine (MPE) Policy: Flat File - Docker Events
- Flat File Settings tab
    - File Path: `/var/log/docker/events.log`
    - Date Parsing Format: `HMC (<YY>-<M>-<d>T<h>:<m>:<s><utcoffset>)`
- Hit OK > Hit OK

You should now have Docker events flowing into LogRhythm! 

## Testing

From Docker host:

- `docker run --name hello_lr docker/whalesay cowsay Hello, LogRhythm!`
- `docker ps -a | grep -i hello_lr`
- `docker rm hello_lr`

This will run a whalesay command, confirm the container is now stopped in docker, and remove the container. If you've never used whalesay before, it will also pull the image down, which should be parsed by LR given the MPE rules we've set up.

From the LogRhythm Web Console run a Search for `Log Source Type` IS `Flat File - Docker Events`. You should get some data returned and this will confirm the parsing is working properly!

## Parsing issues

For any and all parsing issues or requests, please submit an issue here. 
