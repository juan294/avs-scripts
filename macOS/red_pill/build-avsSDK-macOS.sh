#!/usr/bin/env sh
#=================================================================================================
# HEADER
#=================================================================================================
#  DESCRIPTION  AVS SDK Installation:
#               This shell script is meant to ease and automate
#               configuring, building, and installing different
#               versions of the AVS SDK on macOS.
#=================================================================================================
#  HISTORY
#     2020/04/06 : @jgponce : Script creation
#     2021/01/20 : @jgponce : Minor improvements and new macOS version verification
# 
#=================================================================================================
#  SUCCESSFULLY TESTED ON
#    OS:     macOS Mojave v10.14.6 | macOS Catalina v10.15.7
#    SDK(s): v1.15 | v1.17.0 | v1.18.0 | v1.21.0 | v1.22.0
#
#=================================================================================================
#  IMPLEMENTATION
#     version        build-avsSDK-macOS.sh v0.1.2
#     author         Juan GONZALEZ PONCE
#     copyright      Copyright (c) http://www.amazon.com
#     based_on       https://developer.amazon.com/en-US/docs/alexa/avs-device-sdk/mac-os.html
#
#=================================================================================================
# END_OF_HEADER
#=================================================================================================

# --- Before you install the AVS Device SDK, you must register an AVS product and create a security profile ---
# --- Set up required variables for installation ---

# --- YOUR AVS RODUCT ---
CLIENT_ID="YOUR_CLIENT_ID" # --- Make sure this matches the values set up in the AVS Console.
PRODUCT_ID="YOUR_PRODUCT_ID" # --- Make sure this matches the values set up in the AVS Console.
DSN="DEVICE_SERIAL_NUMBER" # --- The number doesn't really matter while testing.

# --- YOUR LOCAL ENVIRONMENT ---
HOME="PATH_TO_HOME_FOLDER"
PROJECT_DIR=${HOME}"PATH_TO_PROJECT_FOLDER" # --- There's no need to create these folders in advanced.
CPU_CORES="N_CORES_AVAILABLE" # --- Set the desired # of cores with -jn format (e.g. -j2 for dual-core machines). Note: A multi-threaded build on Raspberry Pi 3 could overheat or run out of memory. Set with caution or avoid altogether.

# --- AVS SDK ---
BRANCH="THE_SDK_BRANCH" # --- If you're building for Medici make sure to set this up to v1.15.
DEBUG_LEVEL="SAMPLE_APP_DEBUG_LEVEL" # --- Accepted values: DEBUG0 .. DEBUG9 | INFO | WARN | ERROR | CRITICAL | NONE


# --- Set up your development environment ---

echo "##############################################
#                                            #
#   SETTING UP THE DEVELOPMENT ENVIRONMENT   #
#                                            #
##############################################"

# --- Create the required directories ---
mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}
mkdir sdk-build third-party sdk-install db sdk-source application-necessities

cd application-necessities
mkdir sound-files # --- Not sure yet where this is used

# --- Install the SDK dependencies ---
# --- Make sure you have installed:
#       1. Command Line Tools (CLT) for Xcode (developer.apple.com/downloads) or Xcode.
#       2. Python – Minimum version 2.7.x.
#       3. Homebrew – a software package management system that simplifies installation.

# --- Dependencies confirmation ---
#python -V
#brew --version
#xcode-select --version

# --- Check Homebrew Installation & update if installed ---
which -s brew
if [[ $? != 0 ]] ; then
    # --- If it's not in the system already then nstall Homebrew.
    echo "Installing Homebrew: "
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "Updating Homebrew:"
    brew update # --- Beware that this command might fail if you're behind VPN or FW.
fi

# --- Make sure python is 2.7 or later. Feel free to comment this check if you're using Python3 or know your version of 2.x ---
PYTHON_VERSION=`/usr/bin/python -c 'import sys
print (sys.version_info >= (2, 7) and "1" or "0")'`
if [ "$PYTHON_VERSION" = '0' ]; then
    echo "You should update your Python version."
    exit 1
fi

# --- Install and configure curl-openssl ---
brew install curl-openssl
echo export PATH="/usr/local/opt/curl-openssl/bin:$PATH" >> ~/.bash_profile

# --- Verify that the openssl and nghttp2 dependencies are installed; these dependencies are used to connect to AVS by using HTTP ---
curl --version

: 'Example output:
curl 7.69.1 (x86_64-apple-darwin18.7.0) libcurl/7.69.1 OpenSSL/1.1.1f zlib/1.2.11 brotli/1.0.7 c-ares/1.16.0 libssh2/1.9.0 nghttp2/1.40.0 librtmp/2.3
Release-Date: 2020-03-11
Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtmp rtsp scp sftp smb smbs smtp smtps telnet tftp 
Features: AsynchDNS brotli GSS-API HTTP2 HTTPS-proxy IPv6 Kerberos Largefile libz Metalink NTLM NTLM_WB SPNEGO SSL TLS-SRP UnixSockets
'

echo "##############################################
#                                            #
#             CURL SYSTEM INFO               #
#                                            #
##############################################"

# --- Verify that you can run curl ---
curl -I https://nghttp2.org/  || exit 1

: 'If the request succeeds, you will see a message like this:
HTTP/2 200 
date: Mon, 06 Apr 2020 08:28:25 GMT
content-type: text/html
last-modified: Fri, 15 Nov 2019 14:36:38 GMT
etag: "5dceb7f6-19d8"
accept-ranges: bytes
content-length: 6616
x-backend-header-rtt: 0.00164
strict-transport-security: max-age=31536000
server: nghttpx
via: 2 nghttpx
alt-svc: h3-23=":4433"; ma=3600
x-frame-options: SAMEORIGIN
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
'

echo "##############################################
#                                            #
#          INSTALL SDK DEPENDENCIES          #
#                                            #
##############################################"

# --- Install the SDK dependencies ---
# --- Make sure the command runs successfully, and that no errors are thrown. If the command fails, run brew install for each dependency individually ---
brew install gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-libav sqlite3 repo cmake clang-format doxygen wget git

echo "##############################################
#                                            #
#       INSTALL & CONFIGURE PORTAUDIO        #
#                                            #
##############################################"

# --- Install and configure portaudio ---
cd ${PROJECT_DIR}/third-party
#brew install wget # --- Enable this line to install wget in case you don't have it already on your system.
time wget -c http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz || exit 1
tar xf pa_stable_v190600_20161030.tgz
cd portaudio
time ./configure --disable-mac-universal && make $CPU_CORES || exit 1

# --- If you get the error: xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools),
#                                         missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun
# --- Check on the SDK Dependencies at the beginning of this file.

echo "##############################################
#                                            #
#           SET UP PKG_CONFIG_PATH           #
#                                            #
##############################################"

# --- Retrieve the correct PKG_CONFIG_PATH path and modification ---
brew info openssl

# --- Update the libffi package configuration path to the path retrieved in the previous step ---
opensslFolder=$(brew info openssl | grep /usr/local/Cellar | cut -d '(' -f1 | tr -d '[:space:]')
echo export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig:$opensslFolder/lib/pkgconfig:$PKG_CONFIG_PATH" >> ~/.bash_profile
source $HOME/.bash_profile

# --- Download the AVS Device SDK ---
cd ${PROJECT_DIR}

echo "##############################################
#                                            #
#            DOWNLOADING AVS SDK             #
#                                            #
##############################################"

time git clone --single-branch --branch $BRANCH git://github.com/alexa/avs-device-sdk.git || exit 1

echo "##############################################
#                                            #
#       GENERATING BUILD DEPENDENCIES        #
#                                            #
##############################################"

# --- Configure, Build, and Install the AVS Device SDK ---
cd ${PROJECT_DIR}/sdk-build
time cmake ../avs-device-sdk \
-DGSTREAMER_MEDIA_PLAYER=ON \
-DCURL_LIBRARY=/usr/local/opt/curl-openssl/lib/libcurl.dylib \
-DCURL_INCLUDE_DIR=/usr/local/opt/curl-openssl/include \
-DPORTAUDIO=ON \
-DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.a \
-DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include \
-DCMAKE_BUILD_TYPE=DEBUG \
-DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/sdk-install || exit 1

echo "##############################################
#                                            #
#              COMPILING THE SDK             #
#                                            #
##############################################"
time make $CPU_CORES || exit 1

echo "##############################################
#                                            #
#             INSTALLING THE SDK             #
#                                            #
##############################################"
time make $CPU_CORES install || exit 1

echo "##############################################
#                                            #
#           GENERATING CONFIG FILE           #
#                                            #
##############################################"

# --- Generate the AlexaClientSDKConfig.json file to be used by the sample apps for the SDKs ---
cd ${PROJECT_DIR}/avs-device-sdk/tools/Install
echo "{\"deviceInfo\": {\"clientId\": \"$CLIENT_ID\",\"productId\": \"$PRODUCT_ID\"}}" > config.json

if [ "$BRANCH" == "v1.15" ]; then
echo "##############################################
#                                            #
#        RUNNING genCONFIG FOR v1.15         #
#                                            #
##############################################"
    time bash genConfig.sh config.json \
    $DSN \
    ${PROJECT_DIR}/db \
    ${PROJECT_DIR}/avs-device-sdk \
    ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json || exit 1
else
echo "##############################################
#                                            #
#   RUNNING genCONFIG FOR v1.17.0 & HIGHER   #
#                                            #
##############################################"
    time bash genConfig.sh config.json \
    $DSN \
    ${PROJECT_DIR}/db \
    ${PROJECT_DIR}/avs-device-sdk \
    ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json \
    -DSDK_CONFIG_MANUFACTURER_NAME="AE" \
    -DSDK_CONFIG_DEVICE_DESCRIPTION="macos" || exit 1
fi

#if dyld error "image not found" occurs then try
#otool -l ${PROJECT_DIR}/mmsdk-build/modules/Alexa/SampleApp/src/SampleApp | grep -A2 LC_RPATH 
#install_name_tool -add_rpath ${PROJECT_DIR}/sdk-libs/lib ${PROJECT_DIR}/mmsdk-build/modules/Alexa/SampleApp/src/SampleApp
#${PROJECT_DIR}/mmsdk-build/modules/Alexa/SampleApp/src/SampleApp -C sdk-build/Integration/AlexaClientSDKConfig.json -C mmsdk-source/modules/GUI/config/SmartScreenSDKConfig.json -K third-party/snowboy/resources

#Successful completion would be confirmed with a message similar to: 
#"Completed generation of config file: /home/ubuntu/Projects/ass-sdk/sdk-build/Integration/AlexaClientSDKConfig.json"

echo "##############################################
#                                            #
#         RUNNING AVS SDK SAMPLE APP         #
#                                            #
##############################################"

# --- Run the AVS Device SDK sample app ---
cd ${PROJECT_DIR}/sdk-build/SampleApp/src
./SampleApp ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json $DEBUG_LEVEL