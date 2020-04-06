#!/usr/bin/env sh
#============================================================================================================================
# HEADER
#============================================================================================================================
#  DESCRIPTION  AVS SDK Installation:
#               This shell script is meant to ease and automate
#               configuring, building, and installing different
#               versions of the AVS SDK on Raspbian.
#============================================================================================================================
#  HISTORY
#     2020/04/02 : @jgponce : Script creation
#
#============================================================================================================================
#  SUCCESSFULLY TESTED ON
#    OS:     Raspbian GNU/Linux 9 [Stretch] (Running on Raspberry Pi 3B w/1GB RAM)
#    SDK(s): v1.15
#    OS:     Raspbian GNU/Linux 10 [Buster] (Running on Raspberry Pi 4 w/4GB RAM)
#    SDK(s): v1.17.0 | v1.18.0
#
#============================================================================================================================
#  IMPLEMENTATION
#     version        build-avsSDK-raspbi.sh v0.1.0
#     author         Juan GONZALEZ PONCE (inspired by Behboud KALANTARY's macOS script)
#     copyright      Copyright (c) http://www.amazon.com
#     license        GNU General Public License
#     based_on       https://developer.amazon.com/en-US/docs/alexa/alexa-smart-screen-sdk/raspberry-pi.html for v1.5 &
#                    https://developer.amazon.com/en-US/docs/alexa/avs-device-sdk/raspberry-pi.html for v1.17.0 and higher
#
#============================================================================================================================
# END_OF_HEADER
#============================================================================================================================

# --- Before you install the AVS Device SDK, you must register an AVS product and create a security profile. ---
# --- Set up required variables for installation ---

# --- YOUR PRODUCT ---
clientId="YOUR_CLIENT_ID" #--- Make sure this matches the values set up in the AVS Console
productId="YOUR_PRODUCT_ID" #--- Make sure this matches the values set up in the AVS Console
DSN="DEVICE_SERIAL_NUMBER" #--- The number doesn't really matter while testing

# --- YOUR LOCAL ENVIRONMENT ---
HOME="/home/pi"
PROJECT_DIR=${HOME}"/Prototypes/ass-sdk" #--- There's no need to create these folders in advanced
CPU_CORES="-j4" #--- Set the desired # of cores. Note: A multi-threaded build on Raspberry Pi 3 could overheat or run out of memory. Set with caution or avoid altogether

# --- AVS SDK ---
BRANCH="THE_SDK_BRANCH_YOU_WANT" #--- If you're building for Medici make sure to set this up to v1.15
DEBUG_LEVEL="SAMPLE_APP_DEBUG_LEVEL" #--- Accepted values: DEBUG0 .. DEBUG9 | INFO | WARN | ERROR | CRITICAL | NONE

# --------------------------------------------------------------------------------------------------
# --- Set up your development environment ---
echo "##############################################
#                                            #
#   SETTING UP THE DEVELOPMENT ENVIRONMENT   #
#                                            #
##############################################"

# --- Create the required directories ---
mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}
mkdir sdk-build third-party sdk-install db

# --- Update your system (if needed) ---
#sudo apt-get update && sudo apt-get upgrade -y

# --- Install the SDK dependencies ---
# --- Make sure the command runs successfully, and that no errors are thrown. If the command fails, run apt-get install for each dependency individually. ---
time sudo apt-get -y install \
git gcc cmake build-essential libsqlite3-dev libcurl4-openssl-dev libfaad-dev \
libssl-dev libsoup2.4-dev libgcrypt20-dev libgstreamer-plugins-bad1.0-dev \
gstreamer1.0-plugins-good libasound2-dev doxygen || exit 1 # -- If it fails don't waste time going forward, instead exit in the least elegant way possible. ---
 
echo "##############################################
#                                            #
#       INSTALL & CONFIGURE PORTAUDIO        #
#                                            #
##############################################"

# --- Install and configure portaudio ---
cd ${PROJECT_DIR}/third-party
#sudo apt-get install wget # --- Enable this line to install wget in case you don't have it already on your system.
time wget -c http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz || exit 1
tar xf pa_stable_v190600_20161030.tgz
cd portaudio
time ./configure -without-jack && make $CPU_CORES || exit 1 

echo "##############################################
#                                            #
#            INSTALL COMMENTJSON             #
#                                            #
##############################################"

# --- Install commentjson to parse comments in the AlexaClientSDKConfig.json file. ---
time  pip install commentjson || exit 1

# --------------------------------------------------------------------------------------------------
# --- Download the AVS Device SDK and the Sensory wake word engine ---
cd ${PROJECT_DIR}

echo "##############################################
#                                            #
#            DOWNLOADING AVS SDK             #
#                                            #
##############################################"

time git clone --single-branch --branch $BRANCH git://github.com/alexa/avs-device-sdk.git || exit 1

cd ${PROJECT_DIR}/third-party

echo "##############################################
#                                            #
#         DOWNLOADING SENSORY WWE            #
#                                            #
##############################################"

time git clone git://github.com/Sensory/alexa-rpi.git || exit 1

# --- You have to run the licensing script to view the Sensory licensing agreement. ---
echo "##############################################
#                                            #
#        EXECUTING SENSORY LICENSE           #
#                                            #
##############################################"
time ${PROJECT_DIR}/third-party/alexa-rpi/bin/./sdk-license --validate ../config/license-key.txt || exit 1

# --------------------------------------------------------------------------------------------------
cd ${PROJECT_DIR}/sdk-build

 # --- Configure, Build, and Install the AVS Device SDK ---
if [ "$BRANCH" != "v1.18.0" ]; then
echo "##############################################
#                                            #
#    BUILD DEPENDENCIES FOR v1.17 & LOWER    #
#                                            #
##############################################"
    time cmake ../avs-device-sdk \
    -DSENSORY_KEY_WORD_DETECTOR=ON \
    -DSENSORY_KEY_WORD_DETECTOR_LIB_PATH=${PROJECT_DIR}/third-party/alexa-rpi/lib/libsnsr.a \
    -DSENSORY_KEY_WORD_DETECTOR_INCLUDE_DIR=${PROJECT_DIR}/third-party/alexa-rpi/include \
    -DGSTREAMER_MEDIA_PLAYER=ON \
    -DPORTAUDIO=ON \
    -DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.a \
    -DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/sdk-install || exit 1
else
echo "##############################################
#                                            #
#       BUILD DEPENDENCIES FOR v1.18         #
#                                            #
##############################################"
    time cmake ../avs-device-sdk \
    -DSENSORY_KEY_WORD_DETECTOR=ON \
    -DSENSORY_KEY_WORD_DETECTOR_LIB_PATH=${PROJECT_DIR}/third-party/alexa-rpi/lib/libsnsr.a \
    -DSENSORY_KEY_WORD_DETECTOR_INCLUDE_DIR=${PROJECT_DIR}/third-party/alexa-rpi/include \
    -DGSTREAMER_MEDIA_PLAYER=ON \
    -DPORTAUDIO=ON \
    -DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.so \
    -DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/sdk-install || exit 1
fi

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
time sudo make $CPU_CORES install || exit 1

echo "##############################################
#                                            #
#         BUILDING THE SAMPLE APP            #
#                                            #
##############################################"
time make $CPU_CORES SampleApp || exit 1

echo "##############################################
#                                            #
#           GENERATING CONFIG FILE           #
#                                            #
##############################################"

# --- Generate the AlexaClientSDKConfig.json file to be used by the sample apps for the SDKs ---
cd ${PROJECT_DIR}/avs-device-sdk/tools/Install
echo "{\"deviceInfo\": {\"clientId\": \"$clientId\",\"productId\": \"$productId\"}}" > config.json

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
    -DSDK_CONFIG_DEVICE_DESCRIPTION="ubuntu" || exit 1
fi

# if dyld error "image not found" occurs then try
#otool -l ${PROJECT_DIR}/mmsdk-build/modules/Alexa/SampleApp/src/SampleApp | grep -A2 LC_RPATH 
#install_name_tool -add_rpath ${PROJECT_DIR}/sdk-libs/lib ${PROJECT_DIR}/mmsdk-build/modules/Alexa/SampleApp/src/SampleApp
#${PROJECT_DIR}/mmsdk-build/modules/Alexa/SampleApp/src/SampleApp -C sdk-build/Integration/AlexaClientSDKConfig.json -C mmsdk-source/modules/GUI/config/SmartScreenSDKConfig.json -K third-party/snowboy/resources

# Successful completion would be confirmed with a message similar to: 
# "Completed generation of config file: /home/ubuntu/Projects/ass-sdk/sdk-build/Integration/AlexaClientSDKConfig.json"

echo "##############################################
#                                            #
#         RUNNING AVS SDK SAMPLE APP         #
#                                            #
##############################################"

# --------------------------------------------------------------------------------------------------
# --- Run the AVS Device SDK sample app ---
cd ${PROJECT_DIR}/sdk-build/SampleApp/src
PA_ALSA_PLUGHW=1 ./SampleApp ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json $DEBUG_LEVEL