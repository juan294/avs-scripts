#!/usr/bin/env sh
#===========================================================================================================
# HEADER
#===========================================================================================================
#  DESCRIPTION  AVS SDK Installation:
#               This shell script is meant to ease and automate
#               configuring, building, and installing different
#               versions of the ASS SDK on Raspbian.
#===========================================================================================================
#  HISTORY
#     2020/04/03 : @jgponce : Script creation
#
#===========================================================================================================
#  SUCCESSFULLY TESTED ON
#    OS:       Raspbian GNU/Linux 9 [Stretch] (Running on Raspberry Pi 3B+ w/1GB RAM)
#    SDK(s):   v1.15
#    APL CORE: v1.2
#
#===========================================================================================================
#  IMPLEMENTATION
#     version        build-assSDK-raspi.sh v0.1.1
#     author         Juan GONZALEZ PONCE (inspired by Behboud KALANTARY's macOS script)
#     copyright      Copyright (c) http://www.amazon.com
#     license        GNU General Public License
#     based_on       https://developer.amazon.com/en-US/docs/alexa/alexa-smart-screen-sdk/raspberry-pi.html
#
#===========================================================================================================
# END_OF_HEADER
#===========================================================================================================

# --- Create an AVS device on the developer portal, including a security profile ---
# --- The following instructions assume you have a working AVS SDK installation located in PROJECT_DIR ---
# --- Set up required variables for instalation ---

#--- YOUR LOCAL ENVIRONMENT ---
HOME="PATH_TO_HOME_FOLDER"
PROJECT_DIR=${HOME}"PATH_TO_PROJECT_FOLDER" #--- There's no need to create these folders in advanced.
CPU_CORES="N_CORES_AVAILABLE" #--- Set the desired # of cores with -jn format. Note: A multi-threaded build on Raspberry Pi 3 could overheat or run out of memory. Set with caution or avoid altogether.

#--- ASS SDK ---
APL_CORE_BRANCH="THE_LIB_BRANCH" #--- If you're building for Medici make sure to set this up to v1.2.
DEBUG_LEVEL="SAMPLE_APP_DEBUG_LEVEL" #--- Accepted values: DEBUG0 .. DEBUG9 | INFO | WARN | ERROR | CRITICAL | NONE

# ------------------------------------------------------------------------------------------------------
# --- Download the APL Core Library and Alexa Smart Screen SDK ---
cd ${PROJECT_DIR}
echo "##############################################    
#                                            #
#         DOWNLOADING APL CORE LIB           #
#                                            #
##############################################"
time git clone --single-branch --branch $APL_CORE_BRANCH git://github.com/alexa/apl-core-library.git

echo "##############################################
#                                            #
#            DOWNLOADING ASS SDK             #
#                                            #
##############################################"
time git clone git://github.com/alexa/alexa-smart-screen-sdk.git

# --- Configure and Build the APL Core Library ---
echo "##############################################
#                                            #
#          CONFIGURING APL CORE LIB          #
#                                            #
##############################################"
cd ${PROJECT_DIR}/apl-core-library
mkdir build
cd build
time cmake ..

echo "##############################################
#                                            #
#            BUILDING APL CORE LIB           #
#                                            #
##############################################"
time make $CPU_CORES

echo "##############################################
#                                            #
#             BUILDING ASS SDK               #
#                                            #
##############################################"

# --- Install Node.js ---
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
sudo apt-get install -y nodejs

# --- Download and install websocketpp ---
cd ${PROJECT_DIR}/third-party
time wget https://github.com/zaphoyd/websocketpp/archive/0.8.1.tar.gz -O websocketpp-0.8.1.tar.gz
tar -xvzf websocketpp-0.8.1.tar.gz

# --- Download and install ASIO ---
sudo apt-get -y install libasio-dev

cd ${PROJECT_DIR}
mkdir ss-build
cd ss-build

echo "##############################################
#                                            #
#           CONFIGURING ASS SDK              #
#                                            #
##############################################"

time cmake -DCMAKE_PREFIX_PATH=${PROJECT_DIR}/sdk-install \
-DWEBSOCKETPP_INCLUDE_DIR=${PROJECT_DIR}/third-party/websocketpp-0.8.1 \
-DDISABLE_WEBSOCKET_SSL=ON \
-DGSTREAMER_MEDIA_PLAYER=ON \
-DCMAKE_BUILD_TYPE=DEBUG \
-DPORTAUDIO=ON -DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.a \
-DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include/ \
-DAPL_CORE=ON \
-DAPLCORE_INCLUDE_DIR=${PROJECT_DIR}/apl-core-library/aplcore/include \
-DAPLCORE_LIB_DIR=${PROJECT_DIR}/apl-core-library/build/aplcore \
-DYOGA_INCLUDE_DIR=${PROJECT_DIR}/apl-core-library/build/yoga-prefix/src/yoga \
-DYOGA_LIB_DIR=${PROJECT_DIR}/apl-core-library/build/lib \
../alexa-smart-screen-sdk

echo "##############################################
#                                            #
#              BUILDING ASS SDK              #
#                                            #
##############################################"
time make $CPU_CORES

echo "##############################################
#                                            #
#        RUNNING ASS SDK SAMPLE APP          #
#                                            #
##############################################"

# --- Run the sample app ---
cd ${PROJECT_DIR}/ss-build
./modules/Alexa/SampleApp/src/SampleApp \
-C ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json \
-C ${PROJECT_DIR}/alexa-smart-screen-sdk/modules/GUI/config/guiConfigSamples/GuiConfigSample_SmartScreenLargeLandscape.json \
-L $DEBUG_LEVEL