# Installation Instructions
***Note: This is for installing from source. If you would like to install
Brightify as an end user, please search for it in the default repos, ideally
it will be there.***

Brightify is NOT compatible with iPad at the moment.

1. Install Theos. *Theos installation instructions can be found at
https://github.com/theos/theos/wiki/Installation along with jailbreak
specific instructions at http://iphonedevwiki.net/index.php/Theos/Setup*

2. Setup SDKs. You need the iOS 9.3 and iOS 10.1 SDKs from
https://github.com/theos/sdks placed in your $THEOS/sdks directory.

3. Compile using debug mode. **There is currently an issue with using
Theos's FINALPACKAGE=1 or DEBUG=0 modes, which will lead to the tweak crashing.
Please compile in debug.**

## Other Information
If you want to work with the source form of the logos in misc, you'll need
Sketch. Yes I know it's not FOSS, Inkscape is difficult to work with IMO.

The source form for the images in the preference bundle Resources is located
at /misc/BrightifyStuff.sketch
