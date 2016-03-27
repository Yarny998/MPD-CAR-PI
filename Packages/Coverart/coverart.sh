#!/bin/bash
ConfigFile='/etc/mpd.conf'
DefaultArtPath='/var/lib/mpd/art/default'
PausedArtPath='/var/lib/mpd/art/functional/pause_1920x1200.jpg'
MusicDir=$(cat $ConfigFile|grep 'music_directory'|awk -F'"' '{ print $2 }')
MPDHost='localhost'
MPDPort=$(cat $ConfigFile|grep 'port'|awk -F'"' '{ print $2 }')
CoverFile='folder.jpg'
MPDStatusOld='first'
TrackPathOld='first'
MinHeight=200
ScreenHeight=900
i=0

# Setup the Display to not turn off or turn on screensaver
xset s off         # don't activate screensaver
xset -dpms         # disable DPMS (Energy Star) features.
xset s noblank     # don't blank the video device

if [ ! -f "$ConfigFile" ]
then
    echo "No MPD config file to read - $ConfigFile"
    exit 1
fi

NumDefaultArt=$(ls $DefaultArtPath/*.jpg | wc -l)
if [ "$NumDefaultArt" -eq "0" ]
then
    echo "No default art in $DefaultArtPath"
    exit 1
fi

while true
do

    # Get current status, Playing, Paused or other
    MPDStatusNew=$(mpc status | head -2 | tail -1 |awk -F' ' '{ print $1 }')
    # Get the track info and make up the path to the track folder
    TrackPathNew="$(mpc -f "%file%" | head -1)"

    # If the status changes, or every 30 seconds
    if [ "$MPDStatusNew" != "$MPDStatusOld" ] || [ "$TrackPathNew" != "$TrackPathOld" ] || [ "$i" -eq 30 ]
    then
        # Set a default image , message and mode
        NewArt=$(ls $DefaultArtPath/*.jpg|sort -R |tail -1)
        Message='No Message'
        Mode='crop'

        # Is a track playing
        if [ "$MPDStatusNew" == "[playing]" ]
        then
            # Get the track info and make up the path to the track folder
            Dir=${TrackPathNew%/*}
            FullDir=$MusicDir/$Dir'/'

            # Make up the full image path
            CoverPath=$FullDir$CoverFile

            # Find the width of the image
            Height=$(identify -format '%h' "$CoverPath") #Height
    
            # If the image exists and is large enough to display properly, set the artwork and mode
            if [ -f "$CoverPath" ] && [ "$Height" -ge "$MinHeight" ];
            then
                #notify-send "$Message" -t 3000
                NewArt=$CoverPath

                # Scale down a copy of the image if too big for the screen
                if [ "$Height" -gt "$ScreenHeight" ]
                then
                    mv "$CoverPath" "$CoverPath.old" 
                    convert "$CoverPath.old" -resize x$ScreenHeight "$CoverPath"
                fi

                # Depending on size of artwork, pick a mode
                if [ "$Height" -ge "600" ]
                then
                    Mode='center'
                else
                    Mode='tile'
                fi
            fi

            # Set a message
            Message=" Playing - "$(mpc -f "%artist% - %album% - %title%" | head -1)
 
        # Is a track paused
        elif [ "$MPDStatusNew" = "[paused]" ]
        then
            Message=" Paused - "$(mpc -f "%artist% - %album% - %title%" | head -1)
            NewArt=$PausedArtPath
            Mode='crop'
        fi

        # Change the wallpaper
        pcmanfm --wallpaper-mode=$Mode -w "$NewArt"

        if [ "$Message" != "No Message" ]
        then
            gmessage -borderless -fn "URW Gothic L Book Oblique 30" -timeout 3 -wrap -fg blue -bg lightblue -buttons "" -geometry 1800x150 -nearmouse "$Message"
        fi

        # Reset the counter
        i=0
    fi

    let i=i+1
    MPDStatusOld=$MPDStatusNew
    TrackPathOld=$TrackPathNew
    sleep 1	
done
