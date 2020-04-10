#!/usr/bin/env sh
#=================================================================================================
# HEADER
#=================================================================================================
#  DESCRIPTION  AVS SDK Installation:
#               This shell script is meant to ease and automate
#               configuring, building, and installing different
#               versions of the AVS SDK on Ubuntu Linux.
#=================================================================================================
#  HISTORY
#     2020/03/31 : @jgponce : Script creation
# 
#=================================================================================================
#  SUCCESSFULLY TESTED ON
#    OS:     Ubuntu 18.04.4 LTS (Running on Raspberry Pi 4 w/4GB RAM)
#    SDK(s): v1.15 | v1.17.0 | v1.18.0
#    OS:     Ubuntu 19.10.1 LTS (Running on Raspberry Pi 4 w/4GB RAM)
#    SDK(s): v1.17.0 | v1.18.0
#
#=================================================================================================
#  IMPLEMENTATION
#     version        build-avsSDK-Ubuntu.sh v0.1.1
#     author         Juan GONZALEZ PONCE (inspired by Behboud KALANTARY's macOS script)
#     copyright      Copyright (c) http://www.amazon.com
#     based_on       https://developer.amazon.com/en-US/docs/alexa/avs-device-sdk/ubuntu.html
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
sudo apt-get update && sudo apt-get upgrade -y

echo "##############################################
#                                            #
#          INSTALL SDK DEPENDENCIES          #
#                                            #
##############################################"

# --- Make sure the command runs successfully, and that no errors are thrown. If the command fails, run apt-get install for each dependency individually ---
time sudo apt-get install -y git gcc \
cmake openssl clang-format libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad libgstreamer-plugins-bad1.0-dev \
gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools libssl-dev pulseaudio doxygen libsqlite3-dev curl libcurl4-openssl-dev \
libasound2-dev || exit 1 # -- If it fails don't waste time going forward, instead exit in the least elegant way possible.

# --- Verify that the openssl and nghttp2 dependencies are installed; these dependencies are used to connect to AVS by using HTTP ---
curl --version

: 'Example output:
curl 7.58.0 (x86_64-pc-linux-gnu) libcurl/7.58.0 OpenSSL/1.1.1 zlib/1.2.11 libidn2/2.0.4 libpsl/  0.19.1 (+libidn2/2.0.4) nghttp2/1.30.0 librtmp/2.3
Release-Date: 2018-01-24
Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtmp rtsp smb smbs smtp smtps telnet tftp 
Features: AsynchDNS IDN IPv6 Largefile GSS-API Kerberos SPNEGO NTLM NTLM_WB SSL libz TLS-SRP HTTP2 UnixSockets HTTPS-proxy PSL
'

# --- If dependencies are not installed then enable the following: ---
#cd ${PROJECT_DIR}/third-party
#sudo apt-get -y install build-essential nghttp2 libnghttp2-dev libssl-dev
#wget https://curl.haxx.se/download/curl-7.63.0.tar.gz
#tar xzf curl-7.63.0.tar.gz
  
#cd curl-7.63.0
#./configure --with-nghttp2 --prefix=/usr/local --with-ssl
    
#make && sudo make install
#sudo ldconfig

echo "##############################################
#                                            #
#             CURL SYSTEM INFO               #
#                                            #
##############################################"

# --- Verify that you can run curl ---
curl -I https://nghttp2.org/  || exit 1

: 'If the request succeeds, you will see a message like this:
HTTP/2 200
date: Fri, 15 Dec 2017 18:13:26 GMT
content-type: text/html
last-modified: Sat, 25 Nov 2017 14:02:51 GMT
etag: "5a19780b-19e1"
accept-ranges: bytes
content-length: 6625
x-backend-header-rtt: 0.001021
strict-transport-security: max-age=31536000
server: nghttpx
via: 2 nghttpx
x-frame-options: SAMEORIGIN
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
'
echo "##############################################
#                                            #
#       INSTALL & CONFIGURE PORTAUDIO        #
#                                            #
##############################################"

cd ${PROJECT_DIR}/third-party
#sudo apt-get install wget # --- Enable this line to install wget in case you don't have it already on your system.
time wget -c http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz || exit 1
tar xf pa_stable_v190600_20161030.tgz
cd portaudio
time ./configure -without-jack && make $CPU_CORES || exit 1

echo "##############################################
#                                            #
#            DOWNLOADING AVS SDK             #
#                                            #
##############################################"
cd ${PROJECT_DIR}
time git clone --single-branch --branch $BRANCH git://github.com/alexa/avs-device-sdk.git || exit 1

echo "##############################################
#                                            #
#   SETTING UP THE DEVELOPMENT ENVIRONMENT   #
#                                            #
##############################################"

cd ${PROJECT_DIR}/sdk-build

# --- Configure, Build, and Install the AVS Device SDK ---
# --- DPORTAUDIO_LIB_PATH changes depending on the SDK version ---
if [ "$BRANCH" != "v1.18.0" ]; then
echo "##############################################
#                                            #
#    BUILD DEPENDENCIES FOR v1.17 & LOWER    #
#                                            #
##############################################"
    time cmake ../avs-device-sdk \
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
time make $CPU_CORES install || exit 1

echo "##############################################
#                                            #
#           GENERATING CONFIG FILE           #
#                                            #
##############################################"

# --- Generate the AlexaClientSDKConfig.json file to be used by the sample apps for the SDK ---
# --- Keep in mind that genConfig.sh uses the command "python" and if you have a different default
#     in your system (e.g. Ubuntu 19.10 uses "python3") you need to update your settings manually ---
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
    -DSDK_CONFIG_DEVICE_DESCRIPTION="ubuntu" || exit 1
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