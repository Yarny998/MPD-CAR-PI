#!/bin/bash
ConfigFile='/etc/mpd.conf'
DefaultArtPath='/var/lib/mpd/art/default'
PausedArtPath='/var/lib/mpd/art/functional/pause_1920x1200.jpg'
TitleArtPathOrig='/var/lib/mpd/art/functional/title_orig.jpg'
TitleArtPath='/var/lib/mpd/art/functional/title.jpg'
TitleCmd="feh -x -R 2 $TitleArtPath"
MusicDir=$(cat $ConfigFile|grep 'music_directory'|awk -F'"' '{ print $2 }')
MPDHost='localhost'
MPDPort=$(cat $ConfigFile|grep 'port'|awk -F'"' '{ print $2 }')
CoverFile='folder.jpg'
MPDStatusOld='first'
TrackPathOld='first'
MinHeight=200
ScreenHeight=900
i=0
TitlePid=0

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
        Artist_Album='None'
        Title='None'
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
            Artist_Album=$(mpc -f "%artist% - %album%" | head -1)
            Title=$(mpc -f "%title%" | head -1)
 
        # Is a track paused
        elif [ "$MPDStatusNew" = "[paused]" ]
        then
            Artist_Album=$(mpc -f "%artist% - %album%" | head -1)
            Title=$(mpc -f "%title%" | head -1)
		    Artist_Album="(Paused) "$Artist_Album
            NewArt=$PausedArtPath
            Mode='crop'
        fi

        # Change the wallpaper
        pcmanfm --wallpaper-mode=$Mode -w "$NewArt"

        if [ "$Artist_Album" != "None" ]
        then
            convert $TitleArtPathOrig -font URW-Gothic-L-Demi -pointsize 70 -gravity northwest -fill cyan -annotate +30+15 "$Artist_Album" -annotate +30+95 "$Title" $TitleArtPath
            
			#Setup Title area if not already running
			if [ $TitlePid -eq "0" ]
			then
			    ${TitleCmd} &
				TitlePid=$!
			fi
        else
            # Not playing or paused so remove the title area
			if [ $TitlePid -gt "0" ]
			then
			    kill $TitlePid
				TitlePid=0
			fi
        fi

        # Reset the counter
        i=0
    fi

    let i=i+1
    MPDStatusOld=$MPDStatusNew
    TrackPathOld=$TrackPathNew
    sleep 1 
done
