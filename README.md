# MPD-Jesse-Lite
Installation of MPD onto Stretch Lite

This is a CARPI focused build.

The setup is based around a 10inch LCD screen (1920x1080), Raspberry Pi3 and an IQAudio DAC+

From power to playing music is about 15 seconds with a Pi2, although I will be looking at a Pi3 shortly.
The gui is a little slower, around 30 seconds from poweron to displaying.

I have been playing around with Archphile. It is a good setup and stable. I wanted to take it a little further, but Arch linux was a restriction. With Jessie Lite on a Pi2, the boot time is about the same. Many thanks to Archphile for the direction and many of the solutions in the base build. For a simpler player setup, it would still be the way to go.

The full hardware is:
  Raspberry Pi2 with Sandisk Ultra 8GB mSD
  10inch LCD with touchscreen and autoswitch to reverse camera
  WIFI dongle (connection via phone hotspot)
  64GB USB3 thubmdrive (for media)
  Mausberry car power control
  Rotary encoder for volume control and several programmed button press sequences (skip, pause, etc)

Software environment:
  Player
    MPD
    MPC
    Alsaequal (equaliser)
  Web control
    YMPD
    Mongoose
  Desktop
    LXDE
    Iceweasel (browser)
  Scrobbler
    MPDScribble
