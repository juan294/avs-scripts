#!/usr/bin/env sh
clientId="YOUR_CLIENT_ID"
productId="YOUR_PRODUCT_ID"
DSN="DEVICE_SERIAL_NUMBER"
HOME="/home/ubuntu"
PROJECT_DIR=${HOME}"/Projects/avs-sdk"
BRANCH="THE_SDK_BRANCH_YOU_WANT"
DEBUG_LEVEL="SAMPLE_APP_DEBUG_LEVEL"

mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}
mkdir third-party sdk-install db

sudo apt-get install -y git gcc cmake openssl clang-format libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools libssl-dev pulseaudio doxygen libsqlite3-dev curl libcurl4-openssl-dev libasound2-dev

# --- If dependencies are not installed then enable the following: ---
#cd ${PROJECT_DIR}/third-party
#sudo apt-get -y install build-essential nghttp2 libnghttp2-dev libssl-dev
#wget https://curl.haxx.se/download/curl-7.63.0.tar.gz
#tar xzf curl-7.63.0.tar.gz
  
#cd curl-7.63.0
#./configure --with-nghttp2 --prefix=/usr/local --with-ssl
    
#make && sudo make install
#sudo ldconfig

cd ${PROJECT_DIR}/third-party
wget -c http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz
tar xf pa_stable_v190600_20161030.tgz
cd portaudio &&./configure -without-jack && make -j4

cd ${PROJECT_DIR}
git clone --single-branch --branch $BRANCH git://github.com/alexa/avs-device-sdk.git

mkdir sdk-build
cd sdk-build

if [ "$BRANCH" != "v1.18.0" ]; then
     cmake ../avs-device-sdk \
    -DGSTREAMER_MEDIA_PLAYER=ON \
    -DPORTAUDIO=ON \
    -DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.a \
    -DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/sdk-install
else
     cmake ../avs-device-sdk \
    -DGSTREAMER_MEDIA_PLAYER=ON \
    -DPORTAUDIO=ON \
    -DPORTAUDIO_LIB_PATH=${PROJECT_DIR}/third-party/portaudio/lib/.libs/libportaudio.so \
    -DPORTAUDIO_INCLUDE_DIR=${PROJECT_DIR}/third-party/portaudio/include \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DCMAKE_INSTALL_PREFIX=${PROJECT_DIR}/sdk-install
fi

make && make install

cd ${PROJECT_DIR}/avs-device-sdk/tools/Install
echo "{\"deviceInfo\": {\"clientId\": \"$clientId\",\"productId\": \"$productId\"}}" > config.json

if [ "$BRANCH" == "v1.15" ]; then
    bash genConfig.sh config.json \
    $DSN \
    ${PROJECT_DIR}/db \
    ${PROJECT_DIR}/avs-device-sdk \
    ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json
elif [ "$BRANCH" == "v1.17.0" ]; then
    time bash genConfig.sh config.json \
    $DSN \
    ${PROJECT_DIR}/db \
    ${PROJECT_DIR}/avs-device-sdk \
    ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json \
    -DSDK_CONFIG_MANUFACTURER_NAME="AE" \
    -DSDK_CONFIG_DEVICE_DESCRIPTION="ubuntu"
elif [ "$BRANCH" == "v1.18.0" ]; then
    time bash genConfig.sh config.json \
    $DSN \
    ${PROJECT_DIR}/db \
    ${PROJECT_DIR}/avs-device-sdk \
    ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json \
    -DSDK_CONFIG_MANUFACTURER_NAME="AE" \
    -DSDK_CONFIG_DEVICE_DESCRIPTION="ubuntu"
fi

# if dyld error "image not found" occurs then try
#otool -l ${PROJECT_DIR}/mmsdk-build/modules/Alexa/SampleApp/src/SampleApp | grep -A2 LC_RPATH 
#install_name_tool -add_rpath ${PROJECT_DIR}/sdk-libs/lib ${PROJECT_DIR}/mmsdk-build/modules/Alexa/SampleApp/src/SampleApp
#${PROJECT_DIR}/mmsdk-build/modules/Alexa/SampleApp/src/SampleApp -C sdk-build/Integration/AlexaClientSDKConfig.json -C mmsdk-source/modules/GUI/config/SmartScreenSDKConfig.json -K third-party/snowboy/resources

# --- Run the AVS Device SDK sample app ---
cd ${PROJECT_DIR}/sdk-build/SampleApp/src
./SampleApp ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json $DEBUG_LEVEL