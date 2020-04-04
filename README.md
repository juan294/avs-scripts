# AVS Scripts

The AVS Scripts are meant to ease and automate configuring, building, and installing different versions of the AVS SDKs on the most common testing platforms (e.g. Raspbian, Ubuntu, and so on.) If you want a verbose, documented, and more readable version of the script refer to the Red Pill folder. If you just want to get the job done with the least amount of noise possible (and you know what you're doing), then feel free to go to the Blue Pill version.

Each script (Red Pill version only) will let you know in which platform and SDK version it has been successfully tested. I include specific information about the SoC, amount of memory, and OS version in which they have run successfully. 

If you find and issue or see any opportunity for improvement, well.. we're in GitHub. You know what to do :)

### To Keep in Mind

You still need to be familiar with the general instructions posted on the official developer documents. This is in no way a replacement of those resources. You can find important links and general information below.

### What is the Alexa Voice Service (AVS)?

The Alexa Voice Service (AVS) enables developers to integrate Alexa directly into their products, bringing the convenience of voice control to any connected device. AVS provides developers with access to a suite of resources to build Alexa-enabled products, including APIs, hardware development kits, software development kits, and documentation.

[Learn more »](https://developer.amazon.com/alexa-voice-service)

### What is the AVS Device SDK

The Alexa Voice Service (AVS) Device SDK provides you with a set of C ++ libraries to build an Alexa Built-in product, meaning your device has direct access to cloud-based Alexa capabilities to receive voice responses instantly. Your device can be almost anything – a smartwatch, a speaker, headphones – the choice is yours.

[Learn more »](https://developer.amazon.com/docs/alexa/avs-device-sdk/overview.html)

### SDK Architecture

The SDK is modular and abstract. It provides [separate components](https://developer.amazon.com/docs/alexa/avs-device-sdk/overview.html#sdk-architecture) to handle necessary Alexa functionality including processing audio, maintaining persistent connections, and managing Alexa interactions. Each component exposes [Alexa APIs](https://developer.amazon.com/docs/alexa/alexa-voice-service/api-overview.html) to customize your device integrations as needed. The SDK also includes a Sample App, so you can  test interactions before integration.

[Learn more »](https://developer.amazon.com/docs/alexa/avs-device-sdk/overview.html#sdk-architecture)

### API References

View the [C++ API References](https://alexa.github.io/avs-device-sdk/) for detailed information about implementation.

### Alexa Smart Screen SDK

The [Alexa Smart Screen SDK](https://developer.amazon.com/alexa-voice-service/alexa-smart-screen-sdk) extends the [AVS Device SDK](https://developer.amazon.com/alexa-voice-service/sdk) to support development for screen-based Alexa Built-in products. This SDK enables device makers to build screen-based products that complement Alexa voice responses with rich visual experiences. 

The Alexa Smart Screen SDK package in this GitHub repo includes:
* The Alexa Smart Screen SDK
* A sample app that demonstrates end-to-end Alexa Smart Screen SDK functionality
* A GUI web app that handles presentation of Alexa visual responses

The Alexa Smart Screen SDK depends on the following additional GitHub repos:
* [AVS Device SDK](https://github.com/alexa/avs-device-sdk/wiki)
* [APL Core Library](https://github.com/alexa/apl-core-library)

### Security Best Practices and Important Considerations

All Alexa products should adopt the [Security Best Practices for Alexa](https://developer.amazon.com/docs/alexa/alexa-voice-service/security-best-practices.html).

When building Alexa with the SDK, you should also adhere to the [following security principles](https://developer.amazon.com/docs/alexa/avs-device-sdk/overview.html#security-best-practices).

