step=10
model=base.en
threads=4

#
arecord -f S16_LE -r 44100 -D sysdefault:CARD=Microphones -c 2 | ffmpeg -loglevel quiet -i - -y -probesize 32 -y -ar 16000 -ac 1 -acodec pcm_s16le /home/user/Music/tmp/whisper-live0.wav &

if [ $? -ne 0 ]; then
    printf "error: ffmpeg failed\n"
    exit 1
fi

echo "Buffering stream... (this should take $step seconds)"
sleep $(($step))

set +e

echo "Starting..."

i=0
SECONDS=0
while true
do
    err=1
    while [ $err -ne 0 ]; do
        if [ $i -gt 0 ]; then
            ffmpeg -loglevel quiet -v error -noaccurate_seek -i /home/user/Music/tmp/whisper-live0.wav -y -ss $(($i*$step-1)).5 -t $step -c copy /home/user/Music/tmp/whisper-live.wav 2> /home/user/Music/tmp/whisper-live.err
        else
            ffmpeg -loglevel quiet -v error -noaccurate_seek -i /home/user/Music/tmp/whisper-live0.wav -y -ss $(($i*$step)) -t $step -c copy /home/user/Music/tmp/whisper-live.wav 2> /home/user/Music/tmp/whisper-live.err
        fi
        err=$(cat /home/user/Music/tmp/whisper-live.err | wc -l)
    done

    # Print output to console
    ./main -t $threads -m ./models/ggml-$model.bin -f /home/user/Music/tmp/whisper-live.wav --no-timestamps -otxt 2> /home/user/Music/tmp/whispererr

    while [ $SECONDS -lt $((($i+1)*$step)) ]; do
        sleep 1
    done
    ((i=i+1))
done
