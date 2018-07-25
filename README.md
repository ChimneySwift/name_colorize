# Automatic Name Colorization

Automatically generates colors based off names and colorizes them in chat.

## Idea

I know what you're thinking, "Jeeze, really, _another_ color chat CSM? Seriously man? If all I wanted to do was dick around with chat I'd select from the numerous other options, what's so different about this?". I'm glad you asked, some people might prefer manually setting colors, but I always forgot, name_colorize generates colors based off the user's name and colorizes their name through out all chat automatically.

Features:
- Colors stay the same for people with the same name (no matter what server)
- Colorizes regular messages, status messages, /me and join and leave messages
- Colorizes names mentioned in chat

Limitations:
- Will completely block all regular chat messages from making their way to other CSM

## The Algorithm

The color generation algorithm is subject to change (it's not particularly efficient), but does work for our purposes.

It's loosely based off the [please.js JavaScript library](https://github.com/ibarrajo/PleaseJS), basically it generates a hash of the name, then a hue from the hash and then combines preset saturation and value parameters to construct and HSV. It then converts the HSV to RGB based on [this gist](https://gist.github.com/raingloom/3cb614b4e02e9ad52c383dcaa326a25a), and then finally to hexadecimal based off the function used in [the colour_chat CSM](https://github.com/red-001/colour_chat/blob/master/init.lua).

This method doesn't create a wide enough range of colors for my liking, but does a good enough job for release, if you have any suggestions please submit a PR.