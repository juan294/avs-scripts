# AVS Scripts

The AVS Scripts are meant to ease and automate configuring, building, and installing different versions of the AVS SDKs on the most common testing platforms (e.g. Raspbian, Ubuntu, and so on.) If you want a verbose, documented, and more readable version of the script refer to the Red Pill folder. If you just want to get the job done with the least amount of noise possible (or you know what you're doing), then feel free to go to the Blue Pill version.

Each script (Red Pill version only) will let you know in which platform and SDK version it has been successfully tested. I include specific information about the SoC, amount of memory, and OS version in which they have run successfully. 

If you find and issue or see any opportunity for improvement, well.. we're in GitHub. You know what to do :)

### To Keep in Mind

You still need to be familiar with the general instructions posted on the official developer documents. This is in no way a replacement of those resources and all scripts should be executed only after making sure all pre-requisites are met.

### A Note on the Alexa Smart Screen SDK
In order to install the ASS SDK in your system using these scripts, you would need to have a working AVS SDK installation first (including Sample App authorization). The best way to get the ASS SDK set up and running is: 
1. Run the build-avsSDK-preferred_platform.sh (and authorize the app in amazon.com/code)
2. Run the build-assSDK-preferred_platform.sh (making sure you specified the same $PROJECT_DIR)

Piece of cake!

### Tested Platforms and SDKs

These babies have been tested in the following platforms:

                             |         AVS SDK           | ASS SDK |
|----------------------------|---------------------------|---------|
| Operative System / SDKs    | v1.15 | v1.17.0 | v1.18.0 |   v1.2  |
|----------------------------|-------|---------|---------|---------|
| Ubuntu 18.04.4 LTS         | ✓     | ✓       | ✓       | ✓       |
| Ubuntu 19.10.1 LTS         | x     | ✓       | ✓       | x       |
| Raspbian 9 (Stretch)       | ✓     | ✓       | ✓       | x       |
| Raspbian 10 (Buster)       | x     | ✓       | ✓       | x       |
| macOS Mojave v10.14        | ✓     | ✓       | ✓       | ✓       |
| macOS Catalina v10.15      | ✓     | ✓       | ✓       | x       |

Legend:
* ✓: Tested and ran without issues
* x: Tested but couldn't make it work or it's not officially supported.

Note: More details about the exact versions of software and hardware can be found in the header of each script.

### Upcoming Features

* Unit tests option as a parameter: https://developer.amazon.com/en-US/docs/alexa/avs-device-sdk/linux.html#run-integration-and-unit-tests.
* Build with Bluetooth: https://developer.amazon.com/en-US/docs/alexa/avs-device-sdk/linux.html#build-with-bluetooth.
* Override/clean directories instead of exiting because they exist already.
* Better system for checking already-installed software (to avoid trying to re-install every time).
* Add WWE option to all scripts (right now only Raspbian scripts have this option by default).

### Security Best Practices and Important Considerations

All Alexa products should adopt the [Security Best Practices for Alexa](https://developer.amazon.com/docs/alexa/alexa-voice-service/security-best-practices.html).

When building Alexa with the SDK, you should also adhere to the [following security principles](https://developer.amazon.com/docs/alexa/avs-device-sdk/overview.html#security-best-practices).