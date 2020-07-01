# Parsing Set Up

In order to get this configured on your system, you'll need to set up:

1. Custom Log Processing Policy
2. Custom MPE Rules and Sub-rules
3. Docker events log source

## Custom Log Processing Policy

From the LogRhythm Console: 

1. Tools > Knowledge > Log Source Type Manager 
2. Right-click > New
3. Log Source Type Properties
    | Name                      | Abbreviation  | Log Format    | Brief Description                                                                     |
    | :------------------------ | :------------ | :------------ | :------------------------------------------------------------------------------------ |
    | Flat File - Docker Events | Docker Events | Text File     | Docker Events turned into a systemd service and ingested as a flat file by an SMA.    |
4. Deployment Manager > Log Processing Policies
5. Right-click > New
6. Custom > Search for Docker > Double Click on Flat File - Docker Events
7. Name: Flat File - Docker Events > OK

## Custom MPE Rules and Sub-rules

Here is a Sub-Rule window, for reference:
![](screenshots/MPESubRuleExample.png?raw=true)

From the LogRhythm Console: 

1. Tools > Knowledge > MPE Rule Builder
    | Rule Name                                     | Common Event          | Rule Status   | Log Message Source Type Associations  | Base-rule Regular Expression  |
    | :-------------------------------------------- | :-------------------- | :------------ | :------------------------------------ | :---------------------------- |
    | Flat File - Docker Events - Docker Compose    | General Information   | Production    | Flat File - Docker Events             | `^.*?\s(?<tag1.action>.*?\s.*?)\s(?<object>.*?)\s\(com.docker.compose.config-hash=(?<hash>.*?),\s(com.docker.compose.container-number=(?<processid>.*?)),\s(?<status>com.docker.compose.oneoff=.*?),\s(?<reason>com.docker.compose.project=.*?),\s(?<parentprocessid>com.docker.compose.project.config_files=.*?),\s(?<parentprocesspath>com.docker.compose.project.working_dir=.*?),\s(com.docker.compose.service=(?<process>.*?)),\s(?<version>com.docker.compose.version=.*?),\simage=(?<objecttype>.*?),\sname=(?<objectname>.*?)\)` |
    * Sub-Rules:
        | Rule Name         | Common Event              | tag1 Equal To (=)     |
        | :---------------- | :------------------------ | :-------------------- |
        | Container Kill    | Process/Service Stopping  | container kill        |
        | Container Destroy | Process/Service Stopped   | container destroy     |
        | Container Delete  | Process/Service Stopped   | container delete      |
        | Container Die     | Process/Service Stopped   | container die         |
        | Container Create  | Process/Service Starting  | container create      |
        | Container Start   | Process/Service Started   | container start       |
        | Container Stop    | Process/Service Stopped   | container stop        |
    * Right-click in Sub-Rules section > Synchronize with Base-rule > Rule Status
    * Top left corner below file > hit save icon
2. Top left corner next to save icon > hit plus icon
    | Rule Name                                         | Common Event          | Rule Status   | Log Message Source Type Associations  | Base-rule Regular Expression  |
    | :------------------------------------------------ | :-------------------- | :------------ | :------------------------------------ | :---------------------------- |
    | Flat File - Docker Events                         | General Information   | Production    | Flat File - Docker Events             | `^.*?\s(?<tag1.action>.*?\s.*?)\s(?<object>.*?)\s\(((container=(?<hash>.*?),\s)?(exitCode=(?<responsecode>\d+),\s)?(image=(?<objecttype>.*?),\s)?(maintainer=(?<login>.*?),\s)?(name=(?<objectname>.*?))?(,\stype=(?<objecttype>.*?))?)\)` |
    * Sub-Rules:
        | Rule Name             | Common Event                                  | tag1 Equal To (=)     |
        | :----------------     | :------------------------                     | :-------------------- |
        | Container Attach      | Attach Event                                  | container attach      |
        | Container Create      | Process/Service Starting                      | container create      |
        | Container Destroy     | Process/Service Stopped                       | container destroy     |
        | Container Die         | Process/Service Stopped                       | container die         |
        | Container Kill        | Process/Service Stopping                      | container kill        |
        | Container Start       | Process/Service Started                       | container start       |
        | Container Stop        | Process/Service Stopping                      | container stop        |
        | Image Delete          | Resource Terminated                           | image delete          |
        | Image Pull            | Saving New System Software Image To Flash     | image pull            |
        | Image Tag             | General Operations                            | image tag             |
        | Image Untag           | General Operations                            | image untag           |
        | Network Connect       | Network Connection Established                | network connect       |
        | Network Disconnect    | Client Disconnected                           | network disconnect    |
    * Right-click in Sub-Rules section > Synchronize with Base-rule > Rule Status
    * Top left corner below file > hit save icon
3. Top left corner next to save icon > hit plus icon
    | Rule Name                             | Common Event          | Rule Status   | Log Message Source Type Associations  | Base-rule Regular Expression  |
    | :------------------------------------ | :-------------------- | :------------ | :------------------------------------ | :---------------------------- |
    | Flat File - Docker Events - Catchall  | General Information   | Production    | Flat File - Docker Events             | `^.*?\s(?<tag1.action>.*?\s.*?)\s<object>\s\((?<vendorinfo>.*?)\)` |
    * Sub-Rules: N/A
    * Top left corner below file > hit save icon
4. Deployment Manager > Log Processing Policies > Double-click on Flat File - Docker Events
5. Right-click in Rules section > Check all > Right-click in Rules section > Properties
6. MPE Policy Rule Editor
    * [x] Enabled
    * Log Processing Settings: [x] Disable Automatic Host Contextualization
    * Event Management Settings: [x] Log should be forwarded as event
    * Risk Rating: 5 - Medium-Medium
7. Hit OK

## Docker Event Log Source

This assumes you've already onboarded the Docker host's SMA as per standard LR procedure.

From LogRhythm Console:

1. Deployment Manager > System Monitors
2. Right-click on Docker host > Properties
3. Right-click in Log Source section > New 
4. Basic Configuration tab
    * Log Message Source Type: Flat File - Docker Events
    * Log message Prcoessing Engine (MPE) Policy: Flat File - Docker Events
5. Flat File Settings tab
    * File Path: `/var/log/docker/events.log`
    * Date Parsing Format: `HMC (<YY>-<M>-<d>T<h>:<m>:<s><utcoffset>)`
6. Hit OK > Hit OK

You should now have Docker events flowing into LogRhythm! 

## Testing

From Docker host:

1. `docker run --name hello_lr docker/whalesay cowsay Hello, LogRhythm!`
2. `docker ps -a | grep -i hello_lr`
3. `docker rm hello_lr`

This will run a whalesay command, confirm the container is now stopped in docker, and remove the container. If you've never used whalesay before, it will also pull the image down, which should be parsed by LR given the MPE rules we've set up.

From the LogRhythm Web Console run a Search for `Log Source Type` IS `Flat File - Docker Events`. You should get some data returned and this will confirm the parsing is working properly!

## Parsing issues

For any and all parsing issues or requests, please submit an issue here. 
