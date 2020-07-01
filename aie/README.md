# AIE Set Up

Set up for AIE is considerably more simple than the parsing set up. In order to get AIE configured for this use case, all you need to do is:

1. Import all 4 (or however many you want) of the AIE rules (.airx files) into your LR install
2. Confirm configuration for log sources is correct
3. Customize the rules to match your system 
4. Set up the Docker Remediation SRP to auto-run or auto-run with approval

## Import AIE rules

You can follow standard LR documentation for completing this step.

## Confirm configuration

This is done by viewing the AIE rule in the LogRhythm console.

Here are the pictures from my LR install:

### Docker Service Shutdown
![](screenshots/CriticalDockerServiceShutdown.png?raw=true)

### Docker Container Failure
![](screenshots/DockerContainerFailure.png?raw=true)

### Docker Cryptominer Activity Detected
![](screenshots/DockerCryptominerActivityDetected.png?raw=true)

### Docker Cryptominer Image Detected
![](screenshots/DockerCryptominerImageDetected.png?raw=true)

Hint: Pay attention to the `Log Sources` section and confirm it's using your shiny new log source from Docker!

## Customize rules

This is going to be dependent on your environment. You'll need to determine what containers you want to alarm off of.

For example: 

* You want to trigger off of more cryptominer images
* You have a different naming scheme for important docker services

## Docker SRP Auto-run

In order to enable this feature, you'll need to go into the AIE rule and configure a new "action". Below is a screenshot of my current set up, with explanations for how it's configured. You'd want to do this for both of the Cryptominer alarms, but they'll be very similar.

### Docker Cryptominer Activity Dectected SRP configuration
![](screenshots/DockerCryptominerActivityDetectedSRPConfig.png?raw=true)

* New Action
* Set Action
    - Docker Container and Image Remediation: Docker Container Stop
* Target Host
    - This should be your Docker host's IP or, if you have DNS resolution, your Docker host's IP
* Target User
    - This should be your Docker host's docker user, in this case we're using the _not_ recommended root option
* Private Key Path
    - This should be your Docker host's SSH key, stored on the SMA host running the SRP, in our case we stored it at C:\Tools\ssh\HOSTNAME
* Object
    - This should be set to the alarm field Object, as this is how Docker names images and containers to make them unique
* Save Action

When finished, ensure you save your action. You can choose to have this require approval or have it run automatically.

Hit okay when the action has been saved.
