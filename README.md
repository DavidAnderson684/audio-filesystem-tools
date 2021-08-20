# Purpose

These tools are to assist with creating and correctly laying out the filesystem when creating filesystem images containing audio files for use on audio players which allow you to select the track by number.

For example, a micro SD card on which you wish to place audio Bibles and/or teaching resources in multiple languages, with each Bible chapter being in its own file (e.g. MP3 file), and each new resource starting on a multiple of 1000.

e.g.

0001 - tracks starting here are the gospel of Matthew (0001 = Matthew 1, 0002 = Matthew 2, etc.) in the first language\
0029 - tracks starting here are the gospel of Mark (0029 = Mark 1, 0030 = Mark 2, etc.) in the first language\
...\
1001 - tracks starting here are some other teaching resource in the first language\
...\
2001 - tracks starting here are the gospel of Matthew (2001 = Matthew 1, 2002 = Matthew 2, etc.) in the second language\
2029 - tracks starting here are the gospel of Mark (2029 = Mark 1, 2030 = Mark 2, etc.) in the second language\
...\
3001 - tracks starting here are some other teaching resource in the second language\

etc.

The tools achieve this by:

* Copying files in the correct order (since such devices may play them in the order that they were copied), and renaming them so that the lexical alphabetic order is also the desired playing order.
* Laying out separate resources in their own folders, for simplicity.
* Omitting non-audio files (so, you can keep non-audio files in these folders without them polluting the final image)
* Checking that the expected files exist before beginning the copy operation.
* Adding empty "blank" tracks up to the desired number (i.e. the alignment boundaries).

# Further features and relevant information:

* The tools have been developed on a Linux system, and expect a POSIX-like environment. They may be usable on a Cygwin (Windows) environment, but will need some editing to detect that environment and then running relevant commands instead of Linux-specific ones (e.g. `umount` and use of the `/dev` filesystem in the script which copies an image file to a raw device).

# Help

To know what any particular script does, and to receive help on using it, run it with the `--help` parameter, e.g. `./create-directories-from-sources.sh --help`.

# Contributing

Patches and improvements of all kinds are welcome! Please open an issue in Github, and link a pull request to it.
