/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "AudioPolicyManager"
//#define LOG_NDEBUG 0
#include <utils/Log.h>
#include "AudioPolicyManager.h"
#include <media/mediarecorder.h>

namespace android {


// Max volume for streams when playing over bluetooth SCO device while in call: -18dB
#define IN_CALL_SCO_VOLUME_MAX  0.126
// Min music volume for 3.5mm jack in car dock: -10dB
#define CAR_DOCK_MUSIC_MINI_JACK_VOLUME_MIN 0.316

// ----------------------------------------------------------------------------
// AudioPolicyManager implementation for qsd8k platform
// Common audio policy manager code is implemented in AudioPolicyManagerBase class
// ----------------------------------------------------------------------------

// ---  class factory


extern "C" AudioPolicyInterface* createAudioPolicyManager(AudioPolicyClientInterface *clientInterface)
{
    return new AudioPolicyManager(clientInterface);
}

extern "C" void destroyAudioPolicyManager(AudioPolicyInterface *interface)
{
    delete interface;
}

// ---
#ifdef HAVE_FM_RADIO
status_t AudioPolicyManager::setDeviceConnectionState(AudioSystem::audio_devices device,
                                                  AudioSystem::device_connection_state state,
                                                  const char *device_address)
{

    LOGV("setDeviceConnectionState() device: %x, state %d, address %s", device, state, device_address);

    // connect/disconnect only 1 device at a time
    if (AudioSystem::popCount(device) != 1) return BAD_VALUE;

    if (strlen(device_address) >= MAX_DEVICE_ADDRESS_LEN) {
        LOGE("setDeviceConnectionState() invalid address: %s", device_address);
        return BAD_VALUE;
    }

    // handle output devices
    if (AudioSystem::isOutputDevice(device)) {

        switch (state)
        {
        // handle output device connection
        case AudioSystem::DEVICE_STATE_AVAILABLE:
            if (mAvailableOutputDevices & device) {
                LOGW("setDeviceConnectionState() device already connected: %x", device);
                return INVALID_OPERATION;
            }
            LOGV("setDeviceConnectionState() connecting device %x", device);

            // register new device as available
            mAvailableOutputDevices |= device;
            {
                if (AudioSystem::isBluetoothScoDevice(device)) {
                    LOGV("setDeviceConnectionState() BT SCO  device, address %s", device_address);
                    // keep track of SCO device address
                    mScoDeviceAddress = String8(device_address, MAX_DEVICE_ADDRESS_LEN);
                }
            }
            break;
        // handle output device disconnection
        case AudioSystem::DEVICE_STATE_UNAVAILABLE: {
            if (!(mAvailableOutputDevices & device)) {
                LOGW("setDeviceConnectionState() device not connected: %x", device);
                return INVALID_OPERATION;
            }


            LOGV("setDeviceConnectionState() disconnecting device %x", device);
            // remove device from available output devices
            mAvailableOutputDevices &= ~device;

            {
                if (AudioSystem::isBluetoothScoDevice(device)) {
                    mScoDeviceAddress = "";
                }
            }
            } break;

        default:
            LOGE("setDeviceConnectionState() invalid state: %x", state);
            return BAD_VALUE;
        }

        // request routing change if necessary
        uint32_t newDevice = getNewDevice(mHardwareOutput, false);

        if(device & AudioSystem::DEVICE_OUT_FM_ALL) {
            if (state == AudioSystem::DEVICE_STATE_AVAILABLE) {
                mOutputs.valueFor(mHardwareOutput)->changeRefCount(AudioSystem::FM, 1);
            }
            else {
                mOutputs.valueFor(mHardwareOutput)->changeRefCount(AudioSystem::FM, -1);
            }
            if(newDevice == 0){
                newDevice = getDeviceForStrategy(STRATEGY_MEDIA, false);
            }
        }
        updateDeviceForStrategy();
        setOutputDevice(mHardwareOutput, newDevice);

        if (device == AudioSystem::DEVICE_OUT_WIRED_HEADSET) {
            device = AudioSystem::DEVICE_IN_WIRED_HEADSET;
        } else if (device == AudioSystem::DEVICE_OUT_BLUETOOTH_SCO ||
                   device == AudioSystem::DEVICE_OUT_BLUETOOTH_SCO_HEADSET ||
                   device == AudioSystem::DEVICE_OUT_BLUETOOTH_SCO_CARKIT) {
            device = AudioSystem::DEVICE_IN_BLUETOOTH_SCO_HEADSET;
        } else {
            return NO_ERROR;
        }
    }
    // handle input devices
    if (AudioSystem::isInputDevice(device)) {

        switch (state)
        {
        // handle input device connection
        case AudioSystem::DEVICE_STATE_AVAILABLE: {
            if (mAvailableInputDevices & device) {
                LOGW("setDeviceConnectionState() device already connected: %d", device);
                return INVALID_OPERATION;
            }
            mAvailableInputDevices |= device;
            }
            break;

        // handle input device disconnection
        case AudioSystem::DEVICE_STATE_UNAVAILABLE: {
            if (!(mAvailableInputDevices & device)) {
                LOGW("setDeviceConnectionState() device not connected: %d", device);
                return INVALID_OPERATION;
            }
            mAvailableInputDevices &= ~device;
            } break;

        default:
            LOGE("setDeviceConnectionState() invalid state: %x", state);
            return BAD_VALUE;
        }

        audio_io_handle_t activeInput = getActiveInput();
        if (activeInput != 0) {
            AudioInputDescriptor *inputDesc = mInputs.valueFor(activeInput);
            uint32_t newDevice = getDeviceForInputSource(inputDesc->mInputSource);
            if (newDevice != inputDesc->mDevice) {
                LOGV("setDeviceConnectionState() changing device from %x to %x for input %d",
                        inputDesc->mDevice, newDevice, activeInput);
                inputDesc->mDevice = newDevice;
                AudioParameter param = AudioParameter();
                param.addInt(String8(AudioParameter::keyRouting), (int)newDevice);
                mpClientInterface->setParameters(activeInput, param.toString());
            }
        }

        return NO_ERROR;
    }

    LOGW("setDeviceConnectionState() invalid device: %x", device);
    return BAD_VALUE;
}
#endif

uint32_t AudioPolicyManager::getDeviceForStrategy(routing_strategy strategy, bool fromCache)
{
    uint32_t device = 0;

    if (fromCache) {
        device = mDeviceForStrategy[strategy];
        LOGV("getDeviceForStrategy() from cache strategy %d, device %x", strategy, device);
        return device;
    }

    switch (strategy) {
    case STRATEGY_DTMF:
        if (mPhoneState != AudioSystem::MODE_IN_CALL) {
            // when off call, DTMF strategy follows the same rules as MEDIA strategy
            device = getDeviceForStrategy(STRATEGY_MEDIA, false);
            break;
        }
        // when in call, DTMF and PHONE strategies follow the same rules
        // FALL THROUGH

    case STRATEGY_PHONE:
        // for phone strategy, we first consider the forced use and then the available devices by order
        // of priority
        switch (mForceUse[AudioSystem::FOR_COMMUNICATION]) {
        case AudioSystem::FORCE_BT_SCO:
            if (mPhoneState != AudioSystem::MODE_IN_CALL || strategy != STRATEGY_DTMF) {
                device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_SCO_CARKIT;
                if (device) break;
            }
            // otherwise (not docked) continue with selection
            device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_SCO_HEADSET;
            if (device) break;
            device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_SCO;
            if (device) break;
            // if SCO device is requested but no SCO device is available, fall back to default case
            // FALL THROUGH

        default:    // FORCE_NONE
            device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_WIRED_HEADPHONE;
            if (device) break;
            device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_WIRED_HEADSET;
            if (device) break;
            // when not in call:
            if (mPhoneState != AudioSystem::MODE_IN_CALL) {
                // - if we are docked to a BT CAR dock, give A2DP preference over earpiece
                // - if we are docked to a BT DESK dock, give speaker preference over earpiece
                if (mForceUse[AudioSystem::FOR_DOCK] == AudioSystem::FORCE_BT_CAR_DOCK) {
                    device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_A2DP;
                } else if (mForceUse[AudioSystem::FOR_DOCK] == AudioSystem::FORCE_BT_DESK_DOCK) {
                    device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_SPEAKER;
                }
                if (device) break;
                // - phone strategy should route STREAM_VOICE_CALL to A2DP
                device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_A2DP;
                if (device) break;
                device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_A2DP_HEADPHONES;
                if (device) break;
            }
            device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_EARPIECE;
            if (device == 0) {
                LOGE("getDeviceForStrategy() earpiece device not found");
            }
            break;

        case AudioSystem::FORCE_SPEAKER:
            if (mPhoneState != AudioSystem::MODE_IN_CALL || strategy != STRATEGY_DTMF) {
                device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_SCO_CARKIT;
                if (device) break;
            }
            // when not in call:
            if (mPhoneState != AudioSystem::MODE_IN_CALL) {
                // - if we are docked to a BT CAR dock, give A2DP preference over phone spkr
                if (mForceUse[AudioSystem::FOR_DOCK] == AudioSystem::FORCE_BT_CAR_DOCK) {
                    device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_A2DP;
                    if (device) break;
                }
                // - phone strategy should route STREAM_VOICE_CALL to A2DP speaker
                //   when forcing to speaker output
                device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_A2DP_SPEAKER;
                if (device) break;
            }
            device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_SPEAKER;
            if (device == 0) {
                LOGE("getDeviceForStrategy() speaker device not found");
            }
            break;
        }
    break;

    case STRATEGY_SONIFICATION:
    case STRATEGY_MEDIA_SONIFICATION:

        // If incall, just select the STRATEGY_PHONE device: The rest of the behavior is handled by
        // handleIncallSonification().
        if (mPhoneState == AudioSystem::MODE_IN_CALL) {
            device = getDeviceForStrategy(STRATEGY_PHONE, false);
            break;
        }
        // If not incall:
        // - if we are docked to a BT CAR dock, don't duplicate for the sonification strategy
        // - if we are docked to a BT DESK dock, use only speaker for the sonification strategy
        if (mForceUse[AudioSystem::FOR_DOCK] != AudioSystem::FORCE_BT_CAR_DOCK) {
            if (strategy == STRATEGY_SONIFICATION) {
                device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_SPEAKER;
                if (device == 0) {
                    LOGE("getDeviceForStrategy() speaker device not found");
                }
            }
            if (mForceUse[AudioSystem::FOR_DOCK] == AudioSystem::FORCE_BT_DESK_DOCK) {
                if (mAvailableOutputDevices & AudioSystem::DEVICE_OUT_WIRED_HEADPHONE) {
                    device |= AudioSystem::DEVICE_OUT_WIRED_HEADPHONE;
                } else if (mAvailableOutputDevices & AudioSystem::DEVICE_OUT_WIRED_HEADSET) {
                    device |= AudioSystem::DEVICE_OUT_WIRED_HEADSET;
                }
                break;
            }
        } else {
            device = 0;
        }
        // The second device used for sonification is the same as the device used by media strategy
        // Note that when docked, we pick the device below (no duplication)
        // FALL THROUGH

    case STRATEGY_MEDIA: {
#ifdef HAVE_FM_RADIO
        //To route FM stream to speaker when headset is connected, a new switch case is added.
        //case AudioSystem::FORCE_SPEAKER for STRATEGY_MEDIA will come only when we need to route
        //FM stream to speaker.
        uint32_t device2 = 0;
        if (mForceUse[AudioSystem::FOR_MEDIA] == AudioSystem::FORCE_SPEAKER) {
            device2 = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_SPEAKER;
        }
        if (device2 == 0) {
            device2 = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_AUX_DIGITAL;
        }
#else
        uint32_t device2 = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_AUX_DIGITAL;
#endif
#ifdef WITH_A2DP
        if (mA2dpOutput != 0) {
            if (device2 == 0) {
                // play ringtone over speaker (or speaker + headset) if in car dock
                // because A2DP is suspended in this case
                if (mForceUse[AudioSystem::FOR_DOCK] == AudioSystem::FORCE_BT_CAR_DOCK &&
                    strategy == STRATEGY_SONIFICATION &&
                    mPhoneState == AudioSystem::MODE_RINGTONE) {
                    device2 = mAvailableOutputDevices &
                              (AudioSystem::DEVICE_OUT_SPEAKER |
                               AudioSystem::DEVICE_OUT_WIRED_HEADPHONE |
                               AudioSystem::DEVICE_OUT_WIRED_HEADSET);
                }
            }
        }
#endif
        if (device2 == 0) {
            device2 = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_WIRED_HEADPHONE;
        }
        if (device2 == 0) {
            device2 = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_WIRED_HEADSET;
        }
#ifdef WITH_A2DP
        if (mA2dpOutput != 0) {
            if (device2 == 0) {
                device2 = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_A2DP;
            }
            if (device2 == 0) {
                device2 = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_A2DP_HEADPHONES;
            }
            if (device2 == 0) {
                device2 = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_BLUETOOTH_A2DP_SPEAKER;
            }
        }
#endif
        if (device2 == 0) {
            device = mAvailableOutputDevices & AudioSystem::DEVICE_OUT_SPEAKER;
        }

#ifdef HAVE_FM_RADIO
        if (mAvailableOutputDevices & AudioSystem::DEVICE_OUT_FM_ALL) {
            if (device2 & AudioSystem::DEVICE_OUT_SPEAKER)
                device |= AudioSystem::DEVICE_OUT_FM_SPEAKER;
            else
                device |= AudioSystem::DEVICE_OUT_FM;
        }
#endif

        // device is DEVICE_OUT_SPEAKER if we come from case STRATEGY_SONIFICATION, 0 otherwise
        device |= device2;
        if (device == 0) {
            LOGE("getDeviceForStrategy() speaker device not found");
        }
        // Do not play media stream if in call and the requested device would change the hardware
        // output routing
        if (mPhoneState == AudioSystem::MODE_IN_CALL &&
            !AudioSystem::isA2dpDevice((AudioSystem::audio_devices)device) &&
            device != getDeviceForStrategy(STRATEGY_PHONE, false)) {
            device = 0;
            LOGV("getDeviceForStrategy() incompatible media and phone devices");
        }
        } break;

    default:
        LOGW("getDeviceForStrategy() unknown strategy: %d", strategy);
        break;
    }

    LOGV("getDeviceForStrategy() strategy %d, device %x", strategy, device);
    return device;
}

float AudioPolicyManager::computeVolume(int stream, int index, audio_io_handle_t output, uint32_t device)
{
    // if requested volume index is the minimum possible value, we must honor this value as this
    // means the stream is muted. This overrides condition-specific modifications to the volume
    // computed in the generic APM
    if (index == mStreams[stream].mIndexMin) {
        return AudioPolicyManagerBase::computeVolume(stream, index, output, device);
    }
    // force volume on A2DP output to maximum if playing through car dock speakers
    // as volume is applied on the car dock and controlled via car dock keys.
#ifdef WITH_A2DP
    if (output == mA2dpOutput &&
        mForceUse[AudioSystem::FOR_DOCK] == AudioSystem::FORCE_BT_CAR_DOCK) {
        return 1.0;
    }
#endif

    float volume = AudioPolicyManagerBase::computeVolume(stream, index, output, device);

    // limit stream volume when in call and playing over bluetooth SCO device to
    // avoid saturation
    if (mPhoneState == AudioSystem::MODE_IN_CALL && AudioSystem::isBluetoothScoDevice((AudioSystem::audio_devices)device)) {
        if (volume > IN_CALL_SCO_VOLUME_MAX) {
            LOGV("computeVolume limiting SYSTEM volume %f to %f",volume, IN_CALL_SCO_VOLUME_MAX);
            volume = IN_CALL_SCO_VOLUME_MAX;
        }
    }

    // in car dock: when using the 3.5mm jack to play media, set a fixed volume as access to the
    // physical volume keys is blocked by the car dock frame.
    if ((mForceUse[AudioSystem::FOR_DOCK] == AudioSystem::FORCE_BT_CAR_DOCK) &&
    (volume < CAR_DOCK_MUSIC_MINI_JACK_VOLUME_MIN) &&
            (stream == AudioSystem::MUSIC) &&
            (device & (AudioSystem::DEVICE_OUT_WIRED_HEADPHONE |
                AudioSystem::DEVICE_OUT_WIRED_HEADSET))) {
        volume = CAR_DOCK_MUSIC_MINI_JACK_VOLUME_MIN;
    }

    return volume;
}

#ifdef HAVE_FM_RADIO
void AudioPolicyManager::setOutputDevice(audio_io_handle_t output, uint32_t device, bool force, int delayMs)
{
    LOGV("setOutputDevice() output %d device %x delayMs %d", output, device, delayMs);
    AudioOutputDescriptor *outputDesc = mOutputs.valueFor(output);


    if (outputDesc->isDuplicated()) {
        setOutputDevice(outputDesc->mOutput1->mId, device, force, delayMs);
        setOutputDevice(outputDesc->mOutput2->mId, device, force, delayMs);
        return;
    }

    uint32_t prevDevice = (uint32_t)outputDesc->device();
    // Do not change the routing if:
    //  - the requestede device is 0
    //  - the requested device is the same as current device and force is not specified.
    // Doing this check here allows the caller to call setOutputDevice() without conditions
    if ((device == 0 || device == prevDevice) && !force) {
        LOGV("setOutputDevice() setting same device %x or null device for output %d", device, output);
        return;
    }

    outputDesc->mDevice = device;
    // mute media streams if both speaker and headset are selected
    if ((device & ~AudioSystem::DEVICE_OUT_FM_ALL) == (AudioSystem::DEVICE_OUT_SPEAKER | AudioSystem::DEVICE_OUT_WIRED_HEADSET) ||
        (device & ~AudioSystem::DEVICE_OUT_FM_ALL) == (AudioSystem::DEVICE_OUT_SPEAKER | AudioSystem::DEVICE_OUT_WIRED_HEADPHONE)){
        setStrategyMute(STRATEGY_MEDIA, true, output);
        // wait for the PCM output buffers to empty before proceeding with the rest of the command
        usleep(outputDesc->mLatency*2*1000);
    }

    // do the routing
    AudioParameter param = AudioParameter();
    param.addInt(String8(AudioParameter::keyRouting), (int)device);
    mpClientInterface->setParameters(mHardwareOutput, param.toString(), delayMs);
    // update stream volumes according to new device
    applyStreamVolumes(output, device, delayMs);


    // if changing from a combined headset + speaker route, unmute media streams
    if ((prevDevice & ~AudioSystem::DEVICE_OUT_FM_ALL) == (AudioSystem::DEVICE_OUT_SPEAKER | AudioSystem::DEVICE_OUT_WIRED_HEADSET) ||
        (prevDevice & ~AudioSystem::DEVICE_OUT_FM_ALL) == (AudioSystem::DEVICE_OUT_SPEAKER | AudioSystem::DEVICE_OUT_WIRED_HEADPHONE)){
        setStrategyMute(STRATEGY_MEDIA, false, output, delayMs);
    }
}
#endif

}; // namespace android
