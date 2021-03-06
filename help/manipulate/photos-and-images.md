
Although some of the tools for working with photos also apply to films and songs, 
they are treated separately here as we assume films and songs are bought, 
whereas photos are captured, unique and irreplaceable. 

See also:
* [https://github.com/artmg/lubuild/blob/master/help/manipulate/films-and-songs.md]
    * For ripping, converting and metatagging films and songs
* [https://github.com/artmg/lubuild/blob/master/help/manipulate/PDF-files.md]
	* Portable Document Format (PDF) files originating from Adobe's specification
	* extracting images from PDF files
* [https://github.com/artmg/lubuild/blob/master/help/use/Office-documents.md]
    * Office documents (like MS Office and other combination packages)
    * Desktop Publishing (DTP) packages
* [https://github.com/artmg/lubuild/blob/master/help/use/Print-and-scan.md]
	* acquire images and documents from scanning devices
* [https://github.com/artmg/lubuild/blob/master/help/manipulate/plans-and-designs.md]
	* Computer Aided Design programs
	* 3D design, including space layout and rendering, and 2D design
* [https://github.com/artmg/lubuild/blob/master/help/manipulate/miscellaneous-files.md]
	* Other common types of document
	* including email formats


## Viewing images

### image viewer

In LXDE the "Image Viewer" application is **GPicView** which:

* is light
* has slideshow and zoom
* but Fit to Window does NOT stretch
* there is no Print option

what image viewer to add as option?

LXQt plans to use LxImage-Qt

```
# PhotoQt 
sudo apt-add-repository ppa:lumas/photoqt
# this is recommended by dev, rather than old source sudo add-apt-repository ppa:samrog131/ppa
sudo apt update
sudo apt install photoqt 
# Pros and cons:
# Seems the most recommended QT photo viewer
# Uses GraphicsMagick library to support wide range of formats
# still in active development
# quite a lot of dependencies - is it that lightweight? (37MB on my system)
```

* Other QT based image viewers to consider:
	* QIviewer
		- very simple app
		- not in repos
	* nomacs
	* QGraphicsView
+ CLI image manipulators:
	* feh
	* nitrogen
* Other viewers, but use GTK4:
	* gwenview
	* gThumb
	* viewnior

### view image metadata

* command line 
    * exiftool
	    - for more info see below
* GUI
    * ImageMagick
        * ImageInfo menu option displays metadata for currently open file
        * also installs command line    identify -format %[exif:*] myimage.jpg


### poster print over multiple pages

* PosteRazor
    * image via GUI
* pdfposter
    * source pdf via command line





## renaming images based on metadata

The most common case for this would be to rename to "YYYYmmdd_HHMMSS.ext" 
based on the date and time that the photo was taken (metadata)

Exiftool is a great way to do this

```
# show the metadata for a single file
exiftool myPhoto.jpg
# help - http://www.sno.phy.queensu.ca/~phil/exiftool/
# show the shortnames for meta tags
exiftool -s myPhoto.jpg

# rename to "YYYYmmdd_HHMMSS.ext" and move into folder "renamed"
exiftool "-FileName<DateTimeOriginal" -d "%Y%m%d_%H%M%S.%%e" -directory=renamed .
```

## Create photo collage

If you have multiple images, you may wish to crop, resize, and splice 
them together into a photo collage.
You may also be able to use these to put together multiple images 
into a photo montage, but this requirement is more for cutting and gluing. 

* Inkscape
	* import images, resize and crop
	* use layers
	* can be slow to refresh images
* Gimp
	* Open images as layers
	* crop etc
* G'MIC montage plugin for Gimp
	* gimp-gmic package in repos
	* uses c++ libgmic for functions
	* Open as Layers > choose your images
	* Filters > G'Mic / Arrays & tiles > Montage
	* good for layout but assumes you have pre-scaled and cropped layers
* fotowall
	* new fotowall 1.0 retro released after long haitus (may be final)
	* very flexible and quick to put images together as you wish
	* once you crop you can't uncrop without reloading image
	* [https://www.enricoros.com/opensource/fotowall/download/binaries/]
	* original not in repos since trusty
	* in ppa:dhor/myway
* photocollage
	* simple and lightweight
	* good for splicing and arranging but no crop or resize
	* written in Python using GTK interface and Python Imaging Library (PIL)
	* in ubuntu repos since 17.04
	* in ppa:dhor/myway before then
* shapecollage
	* algorithmic creation of specific outlined shape
* metapixel
	* cli program

Instagram has an android app called Layout, 
and there are also many web-based collage services, 
e.g. [http://www.creativebloq.com/photography/collage-maker-11135210]


## Creating videos from images

### Candidates

* OpenShot
	- this is the Ubuntu Studio default video creation app
* ffDiaporama
	- Qt-based
	- no recent development (2014)
* FFmpegYAG
	- simple graphical front end (GUI) for ffmepg
* VLMC
	- from the VideoLAN stable that created VLC
* The following are more Video Editing less video creation:
	- (sometimes referred to as Non-Linear Editing or NLE)
	- Cinelerra
	- LiVES
	- KDEnlive
	- PiTiVi
	- Shotcut
	- Blender (also includes editing features)


## converting images to drawings

### tracing

Tracing is a way to convert bitmap (raster) images to vector images, 
to manipulate the shapes themselves, rather than the way they have been rendered. You should consider using a raster graphics program, 
like GIMP, to clean up or simplify the original image, 
or to crop out parts not required.

Inkscape has some useful tracing options, 
see [https://inkscape.org/en/doc/tutorials/tracing/tutorial-tracing.en.html] 
for an introduction to these. 

However these are based on Potrace, which creates filled shapes. 
In some circumstances this may be what you want, but in the case of images 
that began as line drawings, a center-line trace may give you better results. 

You can use command line **Autotrace** with it's **-centerline** option, 
online services based on Autitrace, such as [http://online.rapidresizer.com/tracer.php], 
or use the an Inkscape plugin that wraps AutoTrace using python-Pillow:

[https://github.com/fablabnbg/inkscape-centerline-trace]

* download the latest .deb [release](https://github.com/fablabnbg/inkscape-centerline-trace/releases)
* restart Inkscape
* look under menu option:
	- Extensions -> Images -> Centerline Trace ...

NB: Although AutoTrace is rather old (2002), the docs do point to 
other comparable projects of the time [http://autotrace.sourceforge.net/] 
as well as suggestions of how to work with fonts


### posterising

Turning graduations of colour into abrupt hue changes, 
to make photos look more like paintings or cartoons

For more advanced options see online services such as:

* (add candidate websites to list)


## backing up from image services

### instagram

If you want to back up photos and their captions from Instragram 
there are various free downloads and third party services, 
or you can even save to another service with ifttt. 
However you could simply use a foss python script, that can be automated, 
like instaLooter, taken over from instaRaider. [https://github.com/althonos/instaLooter]

* requirements: 
	* python
	* PIL or Pillow as well as piexif for metadata
* installation
	* easy with pypi or pip
	* see [http://instalooter.readthedocs.io/en/latest/install.html]
* runtime options:
	* `python instaRaider.py -u myusername` 
	* `-N`, --new   just get new files not already in destination
	* `-m`, --add-metadata    add date and caption metadata
	* credit [http://instalooter.readthedocs.io/en/latest/usage.html]


## turning images into text

Document recognition is 
interpreting the textual or numerical data (words and numbers) 
stored in image files


### Optical Character Recognition (OCR)

* ocrfeeder, including the tesseract engine, is installed by [Lubuild app-installs]


### QR codes

Quick Response (QR) codes are square pixellated barcodes used to read information 
from mobile devices with a camera. 

#### interpreting

* zbar-tools
	- command line read from file or webcam
	- zbarimg to decode image files
	- zbarcam to use webcam
	- a few dependencies
* qtqr
	- Gui to decode and encode
	- uses zbar library
	- 

Note that your image may need some preprocessing to regularise:
* brightness and contrast
* rotation and skew
* image file encoding (format/type)


#### creating

To generate QR codes consider:

* qrencode
	- create a png file from text supplied on the command line
	- also creates EPS and Ascii text files
* qreator
	- similar
* qtqr
	- Gui to create, view and save QR codes
	- built on Qt and Python
	- 
* Portable QR-Code Generator
	- also supports Geo or Wifi Access protocol codes
	* written in Java (so requires JRE runtime)
* 

