# Parsing Set Up

In order to get this configured on your system, you'll need to set up:

- Custom Log Processing Policy
- Custom MPE Rules and Sub-rules
- Docker events log source

## Custom Log Processing Policy

From the LogRhythm Console: 

1. Tools > Knowledge > Log Source Type Manager 
2. Right-click > New
3. Log Source Type Properties
    a. Name: Flat File - Docker Events
    b. Abbreviation: Docker Events
    c. Log Format: Text File
    d. Brief Description: Docker Events turned into a systemd service and ingested as a flat file by an SMA.
4. Deployment Manager > Log Processing Policies
5. Right-click > New
6. Custom > Search for Docker > Double Click on Flat File - Docker Events
7. Name: Flat File - Docker Events > OK

## Custom MPE Rules and Sub-rules

1. Tools > Knowledge > MPE Rule Builder
    a. Rule Name: Flat File - Docker Events - Docker Compose
    b. Common Event: General Information
    c. Rule Status: Production
    d. Log Message Source Type Associations: Flat File - Docker Events
    e. Base-rule Regular Expression: ^.*?\s(?<action>.*?\s.*?)\s(?<object>.*?)\s\(com.docker.compose.config-hash=(?<hash>.*?),\s(com.docker.compose.container-number=(?<processid>.*?)),\s(?<status>com.docker.compose.oneoff=.*?),\s(?<reason>com.docker.compose.project=.*?),\s(?<parentprocessid>com.docker.compose.project.config_files=.*?),\s(?<parentprocesspath>com.docker.compose.project.working_dir=.*?),\s(com.docker.compose.service=(?<process>.*?)),\s(?<version>com.docker.compose.version=.*?),\simage=(?<objecttype>.*?),\sname=(?<objectname>.*?)\)
    f. Sub-Rules:
        i.      Rule Name: Container Kill
                Common Event: Process/Service Stopping
                action Equal To (=) container kill
        ii.     Rule Name: Container Destroy
                Common Event: Process/Service Stopped
                action Equal To (=) container destroy
        iii.    Rule Name: Container Delete
                Common Event: Process/Service Stopped
                action Equal To (=) container delete
        iv.     Rule Name: Container Die
                Common Event: Process/Service Stopped
                action Equal To (=) container die
        v.      Rule Name: Container Create
                Common Event: Process/Service Starting
                action Equal To (=) container create
        vi.     Rule Name: Container Start
                Common Event: Process/Service Started
                action Equal To (=) container start
    g. Right-click in Sub-Rules section > Synchronize with Base-rule > Rule Status
    h. Top left corner below file > hit save icon
2. Top left corner next to save icon > hit plus icon
    a. Rule Name: Flat File - Docker Events
    b. Common Event: General Information
    c. Rule Status: Production
    d. Log Message Source Type Associations: Flat File - Docker Events
    e. Base-rule Regular Expression: ^.*?\s(?<action>.*?\s.*?)\s(?<object>.*?)\s\(((container=(?<hash>.*?),\s)?(exitCode=(?<responsecode>\d+),\s)?(image=(?<objecttype>.*?),\s)?(maintainer=(?<login>.*?),\s)?(name=(?<objectname>.*?))?(,\stype=(?<objecttype>.*?))?)\)
    f. Sub-Rules:
        i.      Rule Name: Container Attach
                Common Event: Attach Event
                action Equal To (=) container attach
        ii.     Rule Name: Container Create
                Common Event: Process/Service Starting
                action Equal To (=) container create
        iii.    Rule Name: Container Destroy
                Common Event: Process/Service Stopped
                action Equal To (=) container destroy
        iv.     Rule Name: Container Die
                Common Event: Process/Service Stopped
                action Equal To (=) container die
        v.      Rule Name: Container Kill
                Common Event: Process/Service Stopping
                action Equal To (=) container kill
        vi.     Rule Name: Container Start
                Common Event: Process/Service Started
                action Equal To (=) container start
        vii.    Rule Name: Container Stop
                Common Event: Process/Service Stopping
                action Equal To (=) container stop
        viii.   Rule Name: Image Delete
                Common Event: Resource Terminated
                action Equal To (=) image delete
        ix.     Rule Name: Image Pull
                Common Event: Saving New System Software Image To Flash
                action Equal To (=) image pull
        x.      Rule Name: Image Tag
                Common Event: General Operations
                action Equal To (=) image tag
        xi.     Rule Name: Image Untag
                Common Event: General Operations
                action Equal To (=) image untag
        xii.    Rule Name: Network Connect
                Common Event: Network Connection Established
                action Equal To (=) network connect
        xiii.   Rule Name: Network Disconnect
                Common Event: Client Disconnected
                action Equal To (=) network disconnect
    g. Right-click in Sub-Rules section > Synchronize with Base-rule > Rule Status
    h. Top left corner below file > hit save icon
3. Top left corner next to save icon > hit plus icon
    a. Rule Name: Flat File - Docker Events - Catchall
    b. Common Event: General Information
    c. Rule Status: Production
    d. Log Message Source Type Associations: Flat File - Docker Events
    e. Base-rule Regular Expression: ^.*?\s(?<action>.*?\s.*?)\s<object>\s\((?<vendorinfo>.*?)\)
    f. Sub-Rules: N/A
    g. Top left corner below file > hit save icon
4. Deployment Manager > Log Processing Policies > Double-click on Flat File - Docker Events
5. Right-click in Rules section > Check all > Right-click in Rules section > Properties
6. MPE Policy Rule Editor
    a. [x] Enabled
    b. Log Processing Settings: [x] Disable Automatic Host Contextualization
    c. Event Management Settings: [x] Log should be forwarded as event
    d. Risk Rating: 5 - Medium-Medium
7. Hit OK

## Docker Event Log Source

This assumes you've already onboarded the Docker host's SMA as per standard LR procedure.

From LogRhythm Console:

1. Deployment Manager > System Monitors
2. Right-click on Docker host > Properties
3. Right-click in Log Source section > New 
4. Basic Configuration tab
    a. Log Message Source Type: Flat File - Docker Events
    b. Log message Prcoessing Engine (MPE) Policy: Flat File - Docker Events
5. Flat File Settings tab
    a. File Path: `/var/log/docker/events.log`
    b. Date Parsing Format: `HMC (<YY>-<M>-<d>T<h>:<m>:<s><utcoffset>)`
6. Hit OK > Hit OK

You should now have Docker events flowing into LogRhythm! 

## Testing

From Docker host:

1. `docker run --name hello_lr docker/whalesay cowsay Hello, LogRhythm!`
2. `docker ps -a | grep -i hello_lr`
2. `docker rm hello_lr`

This will run a whalesay command, confirm the container is now stopped in docker, and remove the container. If you've never used whalesay before, it will also pull the image down, which should be parsed by LR given the MPE rules we've set up.

From the LogRhythm Web Console run a Search for `Log Source Type` IS `Flat File - Docker Events`. You should get some data returned and this will confirm the parsing is working properly!

## Parsing issues

For any and all parsing issues or requests, please submit an issue here. 
