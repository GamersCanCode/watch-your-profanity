#!/bin/bash
#
# This script is captures live microphone input, pipes it to a .wav file,
# and then runs whisper.cpp to provide a live transcription.
#
# It is currently kind of working, although the accuracy of transcription is very poor.

step=10
model=base.en
threads=4

# Use arecord to capture input from microphone and then pipe to ffmpeg to convert to .wav file.
# The output .wav file will increase in size continuously!
arecord -f S16_LE -r 44100 -D sysdefault:CARD=Microphones -c 2 | ffmpeg -i - -f wav -acodec pcm_s16le /home/user/Music/tmp/whisper-live0.wav &

if [ $? -ne 0 ]; then
    printf "error: ffmpeg failed\n"
    exit 1
fi

set +e

echo "Starting transcription from mic input"

i=0
SECONDS=0
while true
do
    err=1
    while [ $err -ne 0 ]; do
        if [ $i -gt 0 ]; then
            ffmpeg -loglevel quiet -v error -noaccurate_seek -i /tmp/whisper-live0.wav -y -ss $(($i*$step-1)).5 -t $step -c copy /tmp/whisper-live.wav 2> /tmp/whisper-live.err
        else
            ffmpeg -loglevel quiet -v error -noaccurate_seek -i /tmp/whisper-live0.wav -y -ss $(($i*$step)) -t $step -c copy /tmp/whisper-live.wav 2> /tmp/whisper-live.err
        fi
        err=$(cat /tmp/whisper-live.err | wc -l)
    done

    ./main -t $threads -m ./models/ggml-$model.bin -f /tmp/whisper-live.wav --no-timestamps -otxt 2> /home/user/Music/tmp/whispererr | tail -n 1

    while [ $SECONDS -lt $((($i+1)*$step)) ]; do
        sleep 1
    done
    ((i=i+1))
done
