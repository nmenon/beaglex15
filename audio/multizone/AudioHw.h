/*
 * Copyright (C) 2013 Texas Instruments
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

#ifndef _AUDIO_HW_H_
#define _AUDIO_HW_H_

#include <vector>

#include <system/audio.h>
#include <hardware/audio_effect.h>

#include <tiaudioutils/Pcm.h>
#include <tiaudioutils/NullPcm.h>
#include <tiaudioutils/ALSAPcm.h>
#include <tiaudioutils/ALSAMixer.h>
#include <tiaudioutils/MumStream.h>
#include <tiaudioutils/Stream.h>
#include <tiaudioutils/Base.h>

namespace android {

using namespace tiaudioutils;
using std::vector;

class AudioHwDevice;

class AudioStream {
 public:
    virtual ~AudioStream() {}
    virtual uint32_t getSampleRate() const = 0;
    virtual int setSampleRate(uint32_t rate) = 0;
    virtual size_t getBufferSize() const = 0;
    virtual audio_channel_mask_t getChannels() const = 0;
    virtual audio_format_t getFormat() const = 0;
    virtual int setFormat(audio_format_t format) = 0;
    virtual int standby() = 0;
    virtual int dump(int fd) const = 0;
    virtual audio_devices_t getDevice() const = 0;
    virtual int setDevice(audio_devices_t device) { return 0; } /* unused */
    virtual int setParameters(const char *kv_pairs) = 0;
    virtual char *getParameters(const char *keys) const = 0;
    virtual int addAudioEffect(effect_handle_t effect) const = 0;
    virtual int removeAudioEffect(effect_handle_t effect) const = 0;
};

class AudioStreamOut : public RefBase, public AudioStream {
 public:
    AudioStreamOut(AudioHwDevice *hwDev,
                   PcmWriter *writer,
                   const PcmParams &params,
                   const SlotMap &map,
                   audio_devices_t devices);
    virtual ~AudioStreamOut() {};
    int initCheck() const;

    /* From AudioStream */
    virtual uint32_t getSampleRate() const;
    virtual int setSampleRate(uint32_t rate);
    virtual size_t getBufferSize() const;
    virtual audio_channel_mask_t getChannels() const;
    virtual audio_format_t getFormat() const;
    virtual int setFormat(audio_format_t format);
    virtual int standby();
    virtual int dump(int fd) const;
    virtual audio_devices_t getDevice() const;
    virtual int setParameters(const char *kv_pairs);
    virtual char *getParameters(const char *keys) const;
    virtual int addAudioEffect(effect_handle_t effect) const;
    virtual int removeAudioEffect(effect_handle_t effect) const;

    /* AudioStreamOut specific */
    uint32_t getLatency() const;
    int setVolume(float left, float right);
    ssize_t write(const void* buffer, size_t bytes);
    int getRenderPosition(uint32_t *dsp_frames) const;
    int getNextWriteTimestamp(int64_t *timestamp) const;

    void setVoiceCall(bool on);

    friend AudioHwDevice;

 protected:
    int resume();
    void idle();

    AudioHwDevice *mHwDev;
    NullOutPort mNullPort;
    PcmWriter mNullWriter;
    PcmWriter *mWriter;
    PcmParams mParams;
    audio_devices_t mDevices;
    sp<OutStream> mStream;
    bool mStandby;
    bool mUsedForVoiceCall;
    Mutex mLock;
};

class AudioStreamIn : public RefBase, public AudioStream {
 public:
    AudioStreamIn(AudioHwDevice *hwDev,
                  PcmReader *reader,
                  const PcmParams &params,
                  const SlotMap &map,
                  audio_devices_t devices);
    virtual ~AudioStreamIn() {};
    int initCheck() const;

    /* From AudioStream */
    virtual uint32_t getSampleRate() const;
    virtual int setSampleRate(uint32_t rate);
    virtual size_t getBufferSize() const;
    virtual audio_channel_mask_t getChannels() const;
    virtual audio_format_t getFormat() const;
    virtual int setFormat(audio_format_t format);
    virtual int standby();
    virtual int dump(int fd) const;
    virtual audio_devices_t getDevice() const;
    virtual int setParameters(const char *kv_pairs);
    virtual char *getParameters(const char *keys) const;
    virtual int addAudioEffect(effect_handle_t effect) const;
    virtual int removeAudioEffect(effect_handle_t effect) const;

    /* AudioStreamIn specific */
    int setGain(float gain);
    ssize_t read(void* buffer, size_t bytes);
    uint32_t getInputFramesLost();

 protected:
    int resume();
    void idle();

    AudioHwDevice *mHwDev;
    PcmReader *mReader;
    PcmParams mParams;
    audio_devices_t mDevices;
    audio_source_t mSource;
    sp<InStream> mStream;
    bool mStandby;
    Mutex mLock;
};

class AudioHwDevice {
 public:
    AudioHwDevice(uint32_t card);
    virtual ~AudioHwDevice();

    uint32_t getSupportedDevices() const;
    int initCheck() const;
    int setVoiceVolume(float volume);
    int setMasterVolume(float volume);
    int setMode(audio_mode_t mode);
    int setMicMute(bool state);
    int getMicMute(bool *state) const;
    int setParameters(const char *kv_pairs);
    char *getParameters(const char *keys) const;
    size_t getInputBufferSize(const struct audio_config *config) const;
    int dump(int fd) const;
    int setMasterMute(bool mute);
    AudioStreamIn* openInputStream(audio_io_handle_t handle,
                                   audio_devices_t devices,
                                   struct audio_config *config);
    void closeInputStream(AudioStreamIn *in);
    AudioStreamOut* openOutputStream(audio_io_handle_t handle,
                                     audio_devices_t devices,
                                     audio_output_flags_t flags,
                                     struct audio_config *config);
    void closeOutputStream(AudioStreamOut *out);

    friend class AudioStreamIn;
    friend class AudioStreamOut;

    static const uint32_t kNumPorts = 3;
    static const uint32_t kCPUPortId = 0;
    static const uint32_t kJAMR3PortId = 1;
    static const uint32_t kBTPortId = 2;
    static const uint32_t kCPUNumChannels = 2;
    static const uint32_t kJAMR3NumChannels = 8;
    static const uint32_t kBTNumChannels = 2;

    static const uint32_t kSampleRate = 44100;
    static const uint32_t kBTSampleRate = 8000;
    static const uint32_t kSampleSize = 16;
    static const uint32_t kCaptureFrameCount = 882;
    static const uint32_t kPlaybackFrameCount = 1024;
    static const uint32_t kBTFrameCount = 160;

    static const uint32_t kADCSettleMs = 80;
    static const uint32_t kVoiceCallPipeMs = 100;

    static const float kVoiceDBMax = 0.0f;
    static const float kVoiceDBMin = -24.0f;
    static const char *kCabinVolumeHP;
    static const char *kCabinVolumeLine;
    static const char *kBTMode;

 protected:
    typedef set< sp<AudioStreamIn> > StreamInSet;
    typedef set< sp<AudioStreamOut> > StreamOutSet;
    typedef vector<ALSAInPort*> InPortVect;
    typedef vector<ALSAOutPort*> OutPortVect;
    typedef vector<PcmReader*> ReaderVect;
    typedef vector<PcmWriter*> WriterVect;

    bool usesJAMR3() const { return mMediaPortId == kJAMR3PortId; }
    const char *getModeName(audio_mode_t mode) const;
    int enterVoiceCall();
    void leaveVoiceCall();
    int enableVoiceCall();
    void disableVoiceCall();

    uint32_t mCardId;
    ALSAMixer mMixer;
    InPortVect mInPorts;
    OutPortVect mOutPorts;
    ReaderVect mReaders;
    WriterVect mWriters;
    StreamInSet mInStreams;
    StreamOutSet mOutStreams;
    bool mMicMute;
    audio_mode_t mMode;
    uint32_t mMediaPortId;
    wp<AudioStreamOut> mPrimaryStreamOut;
    tiaudioutils::MonoPipe *mULPipe;
    tiaudioutils::MonoPipe *mDLPipe;
    PipeWriter *mULPipeWriter;
    PipeWriter *mDLPipeWriter;
    PipeReader *mULPipeReader;
    PipeReader *mDLPipeReader;
    sp<InStream> mVoiceULInStream;
    sp<InStream> mVoiceDLInStream;
    sp<OutStream> mVoiceULOutStream;
    sp<OutStream> mVoiceDLOutStream;
    mutable Mutex mLock;
};

}; // namespace android

#endif /* _AUDIO_HW_H_ */
