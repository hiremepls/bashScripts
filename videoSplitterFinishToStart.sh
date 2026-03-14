#!/bin/bash

# This script will split the video from the finish to start into p parts of i minute intervals
# 35 minute video with parameters 10 2 will output 2 videos, last 10 miuntes, and last 20 minutes
# Usage: ./script.sh input.mp4 i p
# i = interval length in minutes
# p = number of parts
# Example: ./script.sh video.mp4 5 3

input="$1"
i="$2"
p="$3"
filename="${input%.*}"  # Remove extension

duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")
duration_sec=$(echo "$duration" | awk '{print int($1)}')

start_time=$(date +%s)
output_files=()

for (( n=1; n<=$p; n++ )); do
    length=$((i * n * 60))
    if [ $length -gt $duration_sec ]; then
        length=$duration_sec
    fi
    output="${filename}_output_${i}min_${n}of${p}.mp4"
    ffmpeg -i "$input" -ss $(($duration_sec - $length)) -c copy "$output"
    output_files+=("$output")
    echo "Created $output (last $((length/60)) minutes)"
done

end_time=$(date +%s)
runtime=$((end_time - start_time))

echo -e "\nOutput files:"
printf '%s\n' "${output_files[@]}"
echo -e "\nScript completed in $runtime seconds."
