from __future__ import annotations

import asyncio
import contextlib
import logging
import math
import os
import signal
from array import array
from datetime import timedelta
from typing import Any

from dotenv import load_dotenv
from livekit import api, rtc

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
LOGGER = logging.getLogger("phase1.python_participant")

LIVEKIT_URL = os.environ.get("LIVEKIT_PUBLIC_URL", "").strip()
API_KEY = os.environ.get("LIVEKIT_API_KEY", "").strip()
API_SECRET = os.environ.get("LIVEKIT_API_SECRET", "").strip()
ROOM_NAME = os.environ.get("ROOM_NAME", "phase1-room").strip()
IDENTITY = os.environ.get(
    "PYTHON_PARTICIPANT_ID",
    "python-test-participant",
).strip()

SAMPLE_RATE = 48_000
CHANNELS = 1
FRAME_MS = 10
SAMPLES_PER_FRAME = SAMPLE_RATE * FRAME_MS // 1000
VIDEO_WIDTH = 640
VIDEO_HEIGHT = 360
VIDEO_FPS = 10


def require_environment() -> None:
    missing = [
        name
        for name, value in {
            "LIVEKIT_PUBLIC_URL": LIVEKIT_URL,
            "LIVEKIT_API_KEY": API_KEY,
            "LIVEKIT_API_SECRET": API_SECRET,
        }.items()
        if not value
    ]
    if missing:
        raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")


def create_participant_token() -> str:
    return (
        api.AccessToken(API_KEY, API_SECRET)
        .with_identity(IDENTITY)
        .with_name("Python Test Participant")
        .with_grants(
            api.VideoGrants(
                room_join=True,
                room=ROOM_NAME,
                can_publish=True,
                can_subscribe=True,
            )
        )
        .with_ttl(timedelta(hours=1))
        .to_jwt()
    )


async def consume_audio(track: rtc.Track, participant_identity: str) -> None:
    frame_count = 0
    stream = rtc.AudioStream(track)
    try:
        async for event in stream:
            frame = getattr(event, "frame", event)
            frame_count += 1
            if frame_count % 100 == 0:
                LOGGER.info(
                    "Received user audio identity=%s frames=%s sample_rate=%s channels=%s",
                    participant_identity,
                    frame_count,
                    getattr(frame, "sample_rate", "unknown"),
                    getattr(frame, "num_channels", "unknown"),
                )
    except asyncio.CancelledError:
        raise
    except Exception:
        LOGGER.exception("Audio subscription failed identity=%s", participant_identity)
    finally:
        with contextlib.suppress(Exception):
            await stream.aclose()
        LOGGER.info(
            "Stopped audio consumer identity=%s total_frames=%s",
            participant_identity,
            frame_count,
        )


async def publish_test_audio(source: rtc.AudioSource, stop_event: asyncio.Event) -> None:
    phase = 0.0
    phase_step = 2.0 * math.pi * 440.0 / SAMPLE_RATE
    frame_duration = FRAME_MS / 1000.0
    loop = asyncio.get_running_loop()
    next_tone_at = loop.time()

    while not stop_event.is_set():
        now = loop.time()
        play_tone = next_tone_at <= now < next_tone_at + 1.0

        samples = array("h")
        for _ in range(SAMPLES_PER_FRAME):
            value = int(8_000 * math.sin(phase)) if play_tone else 0
            samples.append(value)
            phase += phase_step
            if phase >= 2.0 * math.pi:
                phase -= 2.0 * math.pi

        frame = rtc.AudioFrame(
            samples.tobytes(),
            SAMPLE_RATE,
            CHANNELS,
            SAMPLES_PER_FRAME,
        )
        await source.capture_frame(frame)

        if now >= next_tone_at + 1.0:
            next_tone_at = now + 4.0

        await asyncio.sleep(frame_duration)


async def publish_test_video(source: rtc.VideoSource, stop_event: asyncio.Event) -> None:
    frame_index = 0
    frame_interval = 1.0 / VIDEO_FPS
    pixel_count = VIDEO_WIDTH * VIDEO_HEIGHT

    while not stop_event.is_set():
        red = (40 + frame_index * 3) % 255
        green = (90 + frame_index * 2) % 255
        blue = (180 + frame_index * 5) % 255
        buffer = bytearray(bytes((red, green, blue, 255)) * pixel_count)

        frame = rtc.VideoFrame(
            VIDEO_WIDTH,
            VIDEO_HEIGHT,
            rtc.VideoBufferType.RGBA,
            buffer,
        )
        source.capture_frame(frame)
        frame_index += 1
        await asyncio.sleep(frame_interval)


async def main() -> None:
    require_environment()
    room = rtc.Room()
    stop_event = asyncio.Event()
    background_tasks: set[asyncio.Task[Any]] = set()

    def track_task(task: asyncio.Task[Any]) -> None:
        background_tasks.add(task)
        task.add_done_callback(background_tasks.discard)

    @room.on("participant_connected")
    def on_participant_connected(participant: rtc.RemoteParticipant) -> None:
        LOGGER.info(
            "Participant connected identity=%s sid=%s",
            participant.identity,
            participant.sid,
        )

    @room.on("participant_disconnected")
    def on_participant_disconnected(participant: rtc.RemoteParticipant) -> None:
        LOGGER.info(
            "Participant disconnected identity=%s sid=%s",
            participant.identity,
            participant.sid,
        )

    @room.on("track_subscribed")
    def on_track_subscribed(
        track: rtc.Track,
        publication: rtc.RemoteTrackPublication,
        participant: rtc.RemoteParticipant,
    ) -> None:
        LOGGER.info(
            "Track subscribed identity=%s sid=%s kind=%s",
            participant.identity,
            publication.sid,
            track.kind,
        )
        if track.kind == rtc.TrackKind.KIND_AUDIO:
            track_task(
                asyncio.create_task(
                    consume_audio(track, participant.identity),
                    name=f"audio-consumer-{participant.identity}",
                )
            )

    @room.on("reconnecting")
    def on_reconnecting() -> None:
        LOGGER.warning("LiveKit room reconnecting")

    @room.on("reconnected")
    def on_reconnected() -> None:
        LOGGER.info("LiveKit room reconnected")

    @room.on("disconnected")
    def on_disconnected(*_: object) -> None:
        LOGGER.info("LiveKit room disconnected")
        stop_event.set()

    LOGGER.info("Connecting url=%s room=%s identity=%s", LIVEKIT_URL, ROOM_NAME, IDENTITY)
    await room.connect(LIVEKIT_URL, create_participant_token())
    LOGGER.info("Connected room=%s", room.name)

    audio_source = rtc.AudioSource(SAMPLE_RATE, CHANNELS)
    audio_track = rtc.LocalAudioTrack.create_audio_track("phase1-test-tone", audio_source)
    audio_options = rtc.TrackPublishOptions()
    audio_options.source = rtc.TrackSource.SOURCE_MICROPHONE
    await room.local_participant.publish_track(audio_track, audio_options)
    LOGGER.info("Published generated test audio")

    video_source = rtc.VideoSource(VIDEO_WIDTH, VIDEO_HEIGHT)
    video_track = rtc.LocalVideoTrack.create_video_track("phase1-test-video", video_source)
    video_options = rtc.TrackPublishOptions()
    video_options.source = rtc.TrackSource.SOURCE_CAMERA
    await room.local_participant.publish_track(video_track, video_options)
    LOGGER.info("Published generated test video")

    track_task(asyncio.create_task(publish_test_audio(audio_source, stop_event)))
    track_task(asyncio.create_task(publish_test_video(video_source, stop_event)))

    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        with contextlib.suppress(NotImplementedError):
            loop.add_signal_handler(sig, stop_event.set)

    try:
        await stop_event.wait()
    finally:
        stop_event.set()
        for task in list(background_tasks):
            task.cancel()
        if background_tasks:
            await asyncio.gather(*background_tasks, return_exceptions=True)

        with contextlib.suppress(Exception):
            await audio_source.aclose()
        with contextlib.suppress(Exception):
            await room.disconnect()
        LOGGER.info("Python participant clean shutdown complete")


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        LOGGER.info("Interrupted by user")
