# AVS Scripts

The AVS Scripts are meant to ease and automate configuring, building, and installing different versions of the AVS SDKs on the most common testing platforms (e.g. Raspbian, Ubuntu, and so on.) If you want to work with a verbose, documented, and more comprehensive version of the script refer to the Red Pill folder. If you just want to get the job done with the least amount of noise possible (and you know what you're doing), then feel free to go to the Blue Pill version.

Each script (in those Red Pill folders) will let you know in which platform and SDK version it has been successfully tested. I include specific information about the SoC, amount of memory, and OS version in which they have run successfully. 

If you find and issue or see any opportunity for improvement, well.. we're in GitHub. You know what to do :)

### To Keep in Mind

You still need to be familiar with the general instructions posted on the official developer documents. This is in no way a replacement of those resources and all scripts should be executed only after making sure all pre-requisites are met.

### A Note on the Alexa Smart Screen SDK
In order to install the Alexa Smart Screen SDK (ASS SDK) in your system using these scripts, you would need to have a working AVS SDK installation first (including Sample App authorization). The best way to get the ASS SDK quickly set up and running is to: 
1. Run the **build-avsSDK-_preferred_platform_.sh** script (and authorize the app in amazon.com/code)
2. Run the **build-assSDK-_preferred_platform_.sh** (making sure you specified the same $PROJECT_DIR)

Piece of cake!

### Tested Platforms and SDKs

These babies have been tested in the following platforms:

| Operative System / SDKs    | [AVS v1.15](https://github.com/alexa/avs-device-sdk/tree/v1.15) | [AVS v1.17.0](https://github.com/alexa/avs-device-sdk/tree/v1.17.0) | [AVS v1.18.0](https://github.com/alexa/avs-device-sdk/tree/v1.18.0) |  [ASS v2.0.1](https://github.com/alexa/alexa-smart-screen-sdk/tree/v2.0.1)  |
|----------------------------|-----------|-------------|-------------|------------|
| Ubuntu 18.04.4 LTS         | ✓         | ✓           | ✓           | ✓          |
| Ubuntu 19.10.1 LTS         | x         | ✓           | ✓           | x          |
| Raspbian 9 (Stretch)       | ✓         | ✓           | ✓           | x          |
| Raspbian 10 (Buster)       | x         | ✓           | ✓           | x          |
| macOS Mojave v10.14        | ✓         | ✓           | ✓           | ✓          |

**Legend**:
* ✓: Tested and ran without issues.
* x: Tested but couldn't make it work or it's not officially supported.

**Note**: More details about the exact versions of software and hardware can be found in the header section of each (Red Pill) script.

### Upcoming Features

* Unit tests option as a parameter: https://developer.amazon.com/en-US/docs/alexa/avs-device-sdk/linux.html#run-integration-and-unit-tests.
* Build with Bluetooth: https://developer.amazon.com/en-US/docs/alexa/avs-device-sdk/linux.html#build-with-bluetooth.
* Override/clean directories instead of exiting because they exist already.
* Better system for checking already-installed software (to avoid trying to re-install every time).
* Add WWE option to all scripts (right now only Raspbian scripts have this option by default).

### Security Best Practices and Important Considerations

All Alexa products should adopt the [Security Best Practices for Alexa](https://developer.amazon.com/docs/alexa/alexa-voice-service/security-best-practices.html).

When building Alexa with the SDK, you should also adhere to the [following security principles](https://developer.amazon.com/docs/alexa/avs-device-sdk/overview.html#security-best-practices).