#!/usr/bin/env sh
# --- I'M FEELING LUCKY ---
CLIENT_ID="YOUR_CLIENT_ID"
PRODUCT_ID="YOUR_PRODUCT_ID"
DSN="DEVICE_SERIAL_NUMBER"
HOME="PATH_TO_HOME_FOLDER"
PROJECT_DIR=${HOME}"PATH_TO_PROJECT_FOLDER"
CPU_CORES="N_CORES_AVAILABLE"
BRANCH="THE_SDK_BRANCH"
DEBUG_LEVEL="SAMPLE_APP_DEBUG_LEVEL"

mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}
mkdir sdk-build third-party sdk-install db

sudo apt-get -y install \
git gcc cmake build-essential libsqlite3-dev libcurl4-openssl-dev libfaad-dev \
libssl-dev libsoup2.4-dev libgcrypt20-dev libgstreamer-plugins-bad1.0-dev \
gstreamer1.0-plugins-good libasound2-dev doxygen || exit 1

cd ${PROJECT_DIR}/third-party
wget -c http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz || exit 1
tar xf pa_stable_v190600_20161030.tgz
cd portaudio
./configure -without-jack && make $CPU_CORES || exit 1 

pip install commentjson || exit 1

cd ${PROJECT_DIR}

git clone --single-branch --branch $BRANCH git://github.com/alexa/avs-device-sdk.git || exit 1

cd ${PROJECT_DIR}/third-party

git clone git://github.com/Sensory/alexa-rpi.git || exit 1

${PROJECT_DIR}/third-party/alexa-rpi/bin/./sdk-license --validate ../config/license-key.txt || exit 1

cd ${PROJECT_DIR}/sdk-build

if [ "$BRANCH" != "v1.18.0" ]; then
    cmake ../avs-device-sdk \
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
    cmake ../avs-device-sdk \
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

make $CPU_CORES || exit 1

sudo make $CPU_CORES install || exit 1

make $CPU_CORES SampleApp || exit 1

cd ${PROJECT_DIR}/avs-device-sdk/tools/Install
echo "{\"deviceInfo\": {\"clientId\": \"$CLIENT_ID\",\"productId\": \"$PRODUCT_ID\"}}" > config.json

if [ "$BRANCH" == "v1.15" ]; then
    bash genConfig.sh config.json \
    $DSN \
    ${PROJECT_DIR}/db \
    ${PROJECT_DIR}/avs-device-sdk \
    ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json || exit 1
else
    bash genConfig.sh config.json \
    $DSN \
    ${PROJECT_DIR}/db \
    ${PROJECT_DIR}/avs-device-sdk \
    ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json \
    -DSDK_CONFIG_MANUFACTURER_NAME="AE" \
    -DSDK_CONFIG_DEVICE_DESCRIPTION="ubuntu" || exit 1
fi

cd ${PROJECT_DIR}/sdk-build/SampleApp/src
PA_ALSA_PLUGHW=1 ./SampleApp ${PROJECT_DIR}/sdk-build/Integration/AlexaClientSDKConfig.json $DEBUG_LEVEL