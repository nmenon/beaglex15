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

#define LOG_TAG "audio_hw_primary"
/* #define LOG_NDEBUG 0 */

#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>

#include <cutils/log.h>
#include <cutils/str_parms.h>
#include <cutils/properties.h>

#include <system/audio.h>
#include <hardware/hardware.h>
#include <hardware/audio.h>
#include <hardware/audio_effect.h>

#include <AudioHw.h>

extern "C" {

namespace android {

struct mz_audio_device {
    struct audio_hw_device device;
    AudioHwDevice *hwDev;
};

struct mz_stream_in {
    struct audio_stream_in stream;
    AudioStreamIn *streamIn;
};

struct mz_stream_out {
    struct audio_stream_out stream;
    AudioStreamOut *streamOut;
};

static inline AudioHwDevice *toAudioHwDev(struct audio_hw_device *dev)
{
    return reinterpret_cast<struct mz_audio_device *>(dev)->hwDev;
}

static inline const AudioHwDevice *tocAudioHwDev(const struct audio_hw_device *dev)
{
    return reinterpret_cast<const struct mz_audio_device *>(dev)->hwDev;
}

static inline AudioStreamIn *toStreamIn(struct audio_stream_in *in)
{
    return reinterpret_cast<struct mz_stream_in *>(in)->streamIn;
}

static inline const AudioStreamIn *tocStreamIn(const struct audio_stream_in *in)
{
    return reinterpret_cast<const struct mz_stream_in *>(in)->streamIn;
}

static inline AudioStreamOut *toStreamOut(struct audio_stream_out *out)
{
    return reinterpret_cast<struct mz_stream_out *>(out)->streamOut;
}

static inline const AudioStreamOut *tocStreamOut(const struct audio_stream_out *out)
{
    return reinterpret_cast<const struct mz_stream_out *>(out)->streamOut;
}

/* audio HAL functions */

/* audio_stream_out implementation */

static uint32_t out_get_sample_rate(const struct audio_stream *stream)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->getSampleRate();
}

static int out_set_sample_rate(struct audio_stream *stream, uint32_t rate)
{
    AudioStreamOut *out = toStreamOut((audio_stream_out *)stream);
    return out->setSampleRate(rate);
}

static size_t out_get_buffer_size(const struct audio_stream *stream)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->getBufferSize();
}

static audio_channel_mask_t out_get_channels(const struct audio_stream *stream)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->getChannels();
}

static audio_format_t out_get_format(const struct audio_stream *stream)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->getFormat();
}

static int out_set_format(struct audio_stream *stream, audio_format_t format)
{
    AudioStreamOut *out = toStreamOut((audio_stream_out *)stream);
    return out->setFormat(format);
}

static int out_standby(struct audio_stream *stream)
{
    AudioStreamOut *out = toStreamOut((audio_stream_out *)stream);
    return out->standby();
}

static int out_dump(const struct audio_stream *stream, int fd)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->dump(fd);
}

static int out_set_parameters(struct audio_stream *stream, const char *kvpairs)
{
    AudioStreamOut *out = toStreamOut((audio_stream_out *)stream);
    return out->setParameters(kvpairs);
}

static char* out_get_parameters(const struct audio_stream *stream, const char *keys)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->getParameters(keys);
}

static uint32_t out_get_latency(const struct audio_stream_out *stream)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->getLatency();
}

static int out_set_volume(struct audio_stream_out *stream, float left,
                          float right)
{
    AudioStreamOut *out = toStreamOut((audio_stream_out *)stream);
    return out->setVolume(left, right);
}

static ssize_t out_write(struct audio_stream_out *stream, const void* buffer,
                         size_t bytes)
{
    AudioStreamOut *out = toStreamOut((audio_stream_out *)stream);
    return out->write(buffer, bytes);
}

static int out_get_render_position(const struct audio_stream_out *stream,
                                   uint32_t *dsp_frames)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->getRenderPosition(dsp_frames);
}

static int out_add_audio_effect(const struct audio_stream *stream, effect_handle_t effect)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->addAudioEffect(effect);
}

static int out_remove_audio_effect(const struct audio_stream *stream, effect_handle_t effect)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->removeAudioEffect(effect);
}

static int out_get_next_write_timestamp(const struct audio_stream_out *stream,
                                        int64_t *timestamp)
{
    const AudioStreamOut *out = tocStreamOut((audio_stream_out *)stream);
    return out->getNextWriteTimestamp(timestamp);
}

/* audio_stream_in implementation */

static uint32_t in_get_sample_rate(const struct audio_stream *stream)
{
    const AudioStreamIn *in = tocStreamIn((audio_stream_in *)stream);
    return in->getSampleRate();
}

static int in_set_sample_rate(struct audio_stream *stream, uint32_t rate)
{
    AudioStreamIn *in = toStreamIn((audio_stream_in *)stream);
    return in->setSampleRate(rate);
}

static size_t in_get_buffer_size(const struct audio_stream *stream)
{
    const AudioStreamIn *in = tocStreamIn((audio_stream_in *)stream);
    return in->getBufferSize();
}

static audio_channel_mask_t in_get_channels(const struct audio_stream *stream)
{
    const AudioStreamIn *in = tocStreamIn((audio_stream_in *)stream);
    return in->getChannels();
}

static audio_format_t in_get_format(const struct audio_stream *stream)
{
    const AudioStreamIn *in = tocStreamIn((audio_stream_in *)stream);
    return in->getFormat();
}

static int in_set_format(struct audio_stream *stream, audio_format_t format)
{
    AudioStreamIn *in = toStreamIn((audio_stream_in *)stream);
    return in->setFormat(format);
}

static int in_standby(struct audio_stream *stream)
{
    AudioStreamIn *in = toStreamIn((audio_stream_in *)stream);
    return in->standby();
}

static int in_dump(const struct audio_stream *stream, int fd)
{
    const AudioStreamIn *in = tocStreamIn((audio_stream_in *)stream);
    return in->dump(fd);
}

static int in_set_parameters(struct audio_stream *stream, const char *kvpairs)
{
    AudioStreamIn *in = toStreamIn((audio_stream_in *)stream);
    return in->setParameters(kvpairs);
}

static char * in_get_parameters(const struct audio_stream *stream,
                                const char *keys)
{
    const AudioStreamIn *in = tocStreamIn((audio_stream_in *)stream);
    return in->getParameters(keys);
}

static int in_set_gain(struct audio_stream_in *stream, float gain)
{
    AudioStreamIn *in = toStreamIn(stream);
    return in->setGain(gain);
}

static ssize_t in_read(struct audio_stream_in *stream, void* buffer, size_t bytes)
{
    AudioStreamIn *in = toStreamIn(stream);
    return in->read(buffer, bytes);
}

static uint32_t in_get_input_frames_lost(struct audio_stream_in *stream)
{
    AudioStreamIn *in = toStreamIn(stream);
    return in->getInputFramesLost();
}

static int in_add_audio_effect(const struct audio_stream *stream, effect_handle_t effect)
{
    const AudioStreamIn *in = tocStreamIn((audio_stream_in *)stream);
    return in->addAudioEffect(effect);
}

static int in_remove_audio_effect(const struct audio_stream *stream, effect_handle_t effect)
{
    const AudioStreamIn *in = tocStreamIn((audio_stream_in *)stream);
    return in->removeAudioEffect(effect);
}

/* audio_hw_device implementation */

static int adev_open_output_stream(struct audio_hw_device *dev,
                                   audio_io_handle_t handle,
                                   audio_devices_t devices,
                                   audio_output_flags_t flags,
                                   struct audio_config *config,
                                   struct audio_stream_out **stream_out)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    struct mz_stream_out *out;

    out = (struct mz_stream_out *)malloc(sizeof(*out));
    if (!out)
        return -ENOMEM;

    ALOGV("adev_open_output_stream() stream %p, %u Hz, %u channels, "
          "%u bits/sample, flags 0x%08x",
          out, config->sample_rate, popcount(config->channel_mask),
          audio_bytes_per_sample(config->format) * 8, flags);

    out->stream.common.get_sample_rate = out_get_sample_rate;
    out->stream.common.set_sample_rate = out_set_sample_rate;
    out->stream.common.get_buffer_size = out_get_buffer_size;
    out->stream.common.get_channels = out_get_channels;
    out->stream.common.get_format = out_get_format;
    out->stream.common.set_format = out_set_format;
    out->stream.common.standby = out_standby;
    out->stream.common.dump = out_dump;
    out->stream.common.set_parameters = out_set_parameters;
    out->stream.common.get_parameters = out_get_parameters;
    out->stream.common.add_audio_effect = out_add_audio_effect;
    out->stream.common.remove_audio_effect = out_remove_audio_effect;
    out->stream.get_latency = out_get_latency;
    out->stream.set_volume = out_set_volume;
    out->stream.write = out_write;
    out->stream.get_render_position = out_get_render_position;
    out->stream.get_next_write_timestamp = out_get_next_write_timestamp;

    out->streamOut = hwDev->openOutputStream(handle, devices, flags, config);
    if (!out->streamOut) {
        ALOGE("adev_open_output_stream() failed to open stream");
        free(out);
        return -ENODEV;
    }

    *stream_out = &out->stream;

    return 0;
}

static void adev_close_output_stream(struct audio_hw_device *dev,
                                     struct audio_stream_out *stream)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    AudioStreamOut *out = toStreamOut(stream);

    ALOGV("adev_close_output_stream() stream %p", stream);

    out_standby(&stream->common);

    /* closeOutputStream() also deletes the out object */
    hwDev->closeOutputStream(out);

    free(stream);
}

static int adev_set_parameters(struct audio_hw_device *dev, const char *kvpairs)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    return hwDev->setParameters(kvpairs);
}

static char *adev_get_parameters(const struct audio_hw_device *dev,
                                 const char *keys)
{
    const AudioHwDevice *hwDev = tocAudioHwDev(dev);
    return hwDev->getParameters(keys);
}

static int adev_init_check(const struct audio_hw_device *dev)
{
    const AudioHwDevice *hwDev = tocAudioHwDev(dev);
    return hwDev->initCheck();
}

static int adev_set_voice_volume(struct audio_hw_device *dev, float volume)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    return hwDev->setVoiceVolume(volume);
}

static int adev_set_master_volume(struct audio_hw_device *dev, float volume)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    return hwDev->setMasterVolume(volume);
}

static int adev_set_master_mute(struct audio_hw_device *dev, bool muted)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    return hwDev->setMasterMute(muted);
}

static int adev_set_mode(struct audio_hw_device *dev, audio_mode_t mode)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    return hwDev->setMode(mode);
}

static int adev_set_mic_mute(struct audio_hw_device *dev, bool state)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    return hwDev->setMicMute(state);
}

static int adev_get_mic_mute(const struct audio_hw_device *dev, bool *state)
{
    const AudioHwDevice *hwDev = tocAudioHwDev(dev);
    return hwDev->getMicMute(state);
}

static size_t adev_get_input_buffer_size(const struct audio_hw_device *dev,
                                         const struct audio_config *config)
{
    const AudioHwDevice *hwDev = tocAudioHwDev(dev);
    return hwDev->getInputBufferSize(config);
}

static int adev_open_input_stream(struct audio_hw_device *dev,
                                  audio_io_handle_t handle,
                                  audio_devices_t devices,
                                  struct audio_config *config,
                                  struct audio_stream_in **stream_in)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    struct mz_stream_in *in;
    int ret;

    in = (struct mz_stream_in *)malloc(sizeof(*in));
    if (!in)
        return -ENOMEM;

    ALOGV("adev_open_input_stream() stream %p, %u Hz, %u channels, "
          "%u bits/sample",
          in, config->sample_rate, popcount(config->channel_mask),
          audio_bytes_per_sample(config->format) * 8);

    in->stream.common.get_sample_rate = in_get_sample_rate;
    in->stream.common.set_sample_rate = in_set_sample_rate;
    in->stream.common.get_buffer_size = in_get_buffer_size;
    in->stream.common.get_channels = in_get_channels;
    in->stream.common.get_format = in_get_format;
    in->stream.common.set_format = in_set_format;
    in->stream.common.standby = in_standby;
    in->stream.common.dump = in_dump;
    in->stream.common.set_parameters = in_set_parameters;
    in->stream.common.get_parameters = in_get_parameters;
    in->stream.common.add_audio_effect = in_add_audio_effect;
    in->stream.common.remove_audio_effect = in_remove_audio_effect;
    in->stream.set_gain = in_set_gain;
    in->stream.read = in_read;
    in->stream.get_input_frames_lost = in_get_input_frames_lost;

    in->streamIn = hwDev->openInputStream(handle, devices, config);
    if (!in->streamIn) {
        ALOGE("adev_open_input_stream() failed to open stream");
        free(in);
        return -ENODEV;
    }

    *stream_in = &in->stream;

    return 0;
}

static void adev_close_input_stream(struct audio_hw_device *dev,
                                    struct audio_stream_in *stream)
{
    AudioHwDevice *hwDev = toAudioHwDev(dev);
    AudioStreamIn *in = toStreamIn(stream);

    ALOGV("adev_close_input_stream() stream %p", stream);

    in_standby(&stream->common);

    /* closeInputStream() also deletes the in object */
    hwDev->closeInputStream(in);

    free(stream);
}

static int adev_dump(const audio_hw_device_t *device, int fd)
{
    return 0;
}

static uint32_t adev_get_supported_devices(const struct audio_hw_device *dev)
{
    const AudioHwDevice *hwDev = tocAudioHwDev(dev);
    return hwDev->getSupportedDevices();
}

static int adev_close(hw_device_t *device)
{
    ALOGI("adev_close()");

    free(device);

    return 0;
}

static int adev_open(const hw_module_t* module, const char* name, hw_device_t** device)
{
    struct mz_audio_device *adev;

    ALOGI("adev_open() %s", name);

    if (strcmp(name, AUDIO_HARDWARE_INTERFACE) != 0)
        return -EINVAL;

    adev = (struct mz_audio_device*)calloc(1, sizeof(*adev));
    if (!adev)
        return -ENOMEM;

    adev->device.common.tag = HARDWARE_DEVICE_TAG;
    adev->device.common.version = AUDIO_DEVICE_API_VERSION_2_0;
    adev->device.common.module = (struct hw_module_t *) module;
    adev->device.common.close = adev_close;

    adev->device.get_supported_devices = adev_get_supported_devices;
    adev->device.init_check = adev_init_check;
    adev->device.set_voice_volume = adev_set_voice_volume;
    adev->device.set_master_volume = adev_set_master_volume;
    adev->device.set_master_mute = adev_set_master_mute;
    adev->device.set_mode = adev_set_mode;
    adev->device.set_mic_mute = adev_set_mic_mute;
    adev->device.get_mic_mute = adev_get_mic_mute;
    adev->device.set_parameters = adev_set_parameters;
    adev->device.get_parameters = adev_get_parameters;
    adev->device.get_input_buffer_size = adev_get_input_buffer_size;
    adev->device.open_output_stream = adev_open_output_stream;
    adev->device.close_output_stream = adev_close_output_stream;
    adev->device.open_input_stream = adev_open_input_stream;
    adev->device.close_input_stream = adev_close_input_stream;
    adev->device.dump = adev_dump;

    adev->hwDev = new AudioHwDevice(0);

    *device = &adev->device.common;

    return 0;
}

static struct hw_module_methods_t hal_module_methods = {
    /* open */      adev_open,
};

struct audio_module HAL_MODULE_INFO_SYM = {
    /* common */ {
    /* tag*/                HARDWARE_MODULE_TAG,
    /* module_api_version */AUDIO_MODULE_API_VERSION_0_1,
    /* hal_api_version */   HARDWARE_HAL_API_VERSION,
    /* id */                AUDIO_HARDWARE_MODULE_ID,
    /* name */              "Jacinto6 Multizone Audio HAL",
    /* author */            "Texas Instruments Inc.",
    /* methods */           &hal_module_methods,
    /* dso */               NULL,
    /* reserved */          {0},
    },
};

} /* namespace android */

} /* extern "C" */
