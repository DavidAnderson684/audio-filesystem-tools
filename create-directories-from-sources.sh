#!/bin/bash

# Ensure English-language-based sort order
LANG=C

RESOURCES_DIRECTORY="languages"
RESOURCES=""
DESTINATION_DIRECTORY="destination-`date +%s`"
DRY_RUN=0
INCLUDE_NON_MP3_FILES=0

function show_usage() {
	local BASENAME=`basename $0`
	echo "This script is for creating a directory containing the required files for the indicated resources. This is the main script for creating the required directory layout on your destination device (usually the SD card that you are going to insert into the audio player).
	
	Resources are those available in the directory $RESOURCES_DIRECTORY, unless over-ridden on the command-line. Each resource specified must exist as a sub-directory within that directory, and the order which you wish the files within each resource to be played must be reflected in the English sort-order of the file and directory names (and the order of the resources themselves will be as you specify them in the command-line parameters). In the example given further below, the implied layout is:
	
	path/to/resources/English/Audio-Bible
	path/to/resources/English/Teachings
	path/to/resources/Français/Bible-Sonore 
	path/to/resources/Français/Enseignements
	
	The files within each indicated resource should have lexically sorted filenames; they will be copied in the sorted order. When a resource does not contain precisely 1000 files, blank filler files will be automatically created before starting the next resource.
	
	A dry run will print out what would have been done, and also a count of the total data that would be copied (useful for forewards planning).
	
	If your audio file are not .mp3 files, then you must specify --include-non-mp3-files (and make sure your resource directories do not include files you do not want copied).
	
Usage: $BASENAME [--dry-run] [--languages-directory=/path/to/directory] [--languages=language1,language2,...] [--destination-directory=/path/to/directory] [--include-non-mp3-files]

Example (you can first test out your parameters with --dry-run before doing a live run): $BASENAME --resources-directory=path/to/resources --resources=English/Audio-Bible,English/Teachings,Français/Bible-Sonore,Français/Enseignements --destination-directory=/path/to/destination/USB/card
	"
}

if [[ -z $1 ]]; then
	show_usage
	exit
fi

for i in "$@"; do
	if [[ $i = "--help" || $i = "-?" ]]; then show_usage; exit;
	elif [[ $i = "--dry-run" ]]; then DRY_RUN=1
	elif [[ $i = "--include-non-mp3-files" ]]; then INCLUDE_NON_MP3_FILES=1
	elif [[ $i =~ ^--resources-directory=(.*)$ ]]; then RESOURCES_DIRECTORY=${BASH_REMATCH[1]}
	elif [[ $i =~ ^--resources=(.*)$ ]]; then RESOURCES=${BASH_REMATCH[1]}
	elif [[ $i =~ ^--destination-directory=(.*)$ ]]; then DESTINATION_DIRECTORY=${BASH_REMATCH[1]}
	else echo "Unknown parameter: $i"; show_usage; exit 2;
	fi
done

# if [[ $DRY_RUN -eq 0 ]]; then
# 	echo "Only dry-run mode is currently supported" >/dev/stderr
# 	exit 9
# fi

if [[ ! -d $RESOURCES_DIRECTORY ]]; then
	echo "Languages directory ($RESOURCES_DIRECTORY) does not exist" >/dev/stderr
	exit 3
fi

if [[ -z $RESOURCES ]]; then
	echo "No languages specified (--languages=...)" >/dev/stderr
	exit 4
fi

# if [[ -e $DESTINATION_DIRECTORY ]]; then
# 	echo "Destination directory ($DESTINATION_DIRECTORY) must not already exist" >/dev/stderr
# 	exit 7
# fi

# Die on errors, mostly (http://mywiki.wooledge.org/BashFAQ/105)
# set -e

readarray -d , -t RESOURCES_ARRAY <<<"$RESOURCES"

# Check existence of resource directories
for (( n=0; n < ${#RESOURCES_ARRAY[*]}; n++ )); do
	# Remove trailing spaces
	RESOURCE=${RESOURCES_ARRAY[n]%%[[:space:]]}
	if [[ ! -d "$RESOURCES_DIRECTORY/$RESOURCE" ]]; then
		echo "Resource directory ($RESOURCES_DIRECTORY/$RESOURCE) does not exist" >/dev/stderr
		exit 5
	fi
done

OLD_IFS="$IFS"
IFS="\n"

if [[ ! -d "$DESTINATION_DIRECTORY" ]]; then
	echo "Make destination directory: $DESTINATION_DIRECTORY"
	if [[ $DRY_RUN -eq 0 ]]; then
		mkdir -p "$DESTINATION_DIRECTORY"
	fi
else
	echo "Destination directory already exists ($DESTINATION_DIRECTORY)"
fi

# Writes out a blank MP3 file to the indicated path
# If changing this, then also change the total added to the file size count during a dry-run.
#
# @param String filename
function write_blank_mp3_file() {
echo $1;
	echo "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
1OK4aJgLRSRFrPgQQXUoAJRgADNCPz/yffn+ynL/r/9fl3aMuea6vQQoT4IduqoDqCMnEgLSUkHE
ATwEO4oCNTjiaoMJurIxGysZH8zYsy5mzL8vTWGLYtxVA9G7Xmna2JPO1eLhUXlVRVcZD0MysP/7
UsTsgEwltQWgjT7BebagtBGn2B8AhPeQlpdUQRiYBjZtaMmf59Rc5Q9/DRfz//8yZ//KGvs+TD/f
kaEaFiNCMJMLDFyYhhE5kImH/FCTNHKGKHWmmv2mmn/iaZYHipSHEocTTOHwOh4C4HRMLOSyTEFN
RTMuOTkuM6qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq//tSxOqASxG1CaCFN8F3tqC0EafY
qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
qqqqqqqqqqqqqqqqqqqqqqr/+1LE7QBNdbT/II2ewUg2XfAQoviqqqqqqqqqqqqqqqqqqqqqqqqq
qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqg==" | base64 -d >"$1"

}

TOTAL_COUNT=0
SIZE_COUNT=0

for (( RES_INDEX=0; RES_INDEX < ${#RESOURCES_ARRAY[*]}; RES_INDEX++ )); do
	# Remove trailing spaces
	RESOURCE=${RESOURCES_ARRAY[RES_INDEX]%%[[:space:]]}
	RESOURCE_FORMATTED=$(printf '%03d' $RES_INDEX)_`basename "$RESOURCE"`
	COUNT=0
	pushd "$RESOURCES_DIRECTORY/$RESOURCE" >/dev/null
	echo "Make directory: $DESTINATION_DIRECTORY/$RESOURCE_FORMATTED"
	if [[ $DRY_RUN -eq 0 ]]; then
		mkdir -p "$DESTINATION_DIRECTORY/$RESOURCE_FORMATTED"
	fi
	while read FILENAME; do
	
		# 'find' appends the current directory prefix
		if [[ ${FILENAME:0:2} = "./" ]]; then
			FILENAME=${FILENAME:2}
		fi
		
		# Filename suffixes that exist in some of our sources; skip them automatically
		if [[ $INCLUDE_NON_MP3_FILES -eq 0 && $FILENAME =~ \.(html|m3u|db|jpg)$ ]]; then
			continue;
		fi
	
		if [[ $INCLUDE_NON_MP3_FILES -eq 0 && ! $FILENAME =~ \.mp3$ ]]; then
			echo "Unexpected file suffix found: $FILENAME" >/dev/stderr
			exit 10
		fi
	
		COUNT=$((COUNT+1))
		TOTAL_COUNT=$((TOTAL_COUNT+1))
		if [[ $COUNT -gt 1000 ]]; then
			# Will probably never be needed. But if it ever is, just a bit of modulo 1000 arithmetic will be required.
			echo "ABORT: This script does not yet support > 1000 files within a single resource" >/dev/stderr
		fi
		
		COUNT_FORMATTED=$(printf '%04d' $COUNT)
		SIZE_COUNT=$((SIZE_COUNT + `stat -c %s "$FILENAME"`))
		
		FILE_DESTINATION=$(dirname "$FILENAME")/$COUNT_FORMATTED-$(basename "$FILENAME")
		
		if [[ $DRY_RUN -eq 1 ]]; then
			echo "Copy '$FILENAME' to '$DESTINATION_DIRECTORY/$RESOURCE_FORMATTED/$FILE_DESTINATION'"
		else
			DEST_SUB_DIR=`dirname "$DESTINATION_DIRECTORY/$RESOURCE_FORMATTED/$FILE_DESTINATION"`
			if [[ ! -d "$DEST_SUB_DIR" ]]; then
				mkdir "$DEST_SUB_DIR"
			fi
			cp -v "$FILENAME" "$DESTINATION_DIRECTORY/$RESOURCE_FORMATTED/$FILE_DESTINATION"
			if [[ $? -ne 0 ]]; then
				echo "Copying error occurred; aborting" >/dev/stderr
				exit 12
			fi
		fi
	done < <(find . -type f | sort)
	
	# Return to starting directory so that the blank file is in the expected place
	popd >/dev/null
	FILENAME="blank.mp3"
	MEGA_COUNT=$((SIZE_COUNT/1048576))
	echo "$RESOURCE (before adding blank files): $COUNT files; cumulative total size $MEGA_COUNT MB"
	
	# Put it at the end of the lexical sorting
	BLANK_DIRECTORY="$DESTINATION_DIRECTORY/$RESOURCE_FORMATTED/ZZZZ-Blank"
	
	if [[ $COUNT -lt 1000 ]]; then
		echo "Create directory $BLANK_DIRECTORY"
		if [[ $DRY_RUN -eq 0 ]]; then
			mkdir -p "$BLANK_DIRECTORY"
		fi
	fi
	
	while [[ $COUNT -lt 1000 ]]; do
		COUNT=$((COUNT+1))
		TOTAL_COUNT=$((TOTAL_COUNT+1))
		COUNT_FORMATTED=$(printf '%04d' $COUNT)
		
		echo "Copy blank MP3 file to '$BLANK_DIRECTORY/$COUNT_FORMATTED-$FILENAME'"
		if [[ $DRY_RUN -eq 1 ]]; then
			# This is the size of the file output by write_blank_mp3_file()
			SIZE_COUNT=$((SIZE_COUNT + 4387))
		else
			write_blank_mp3_file "$BLANK_DIRECTORY/$COUNT_FORMATTED-$FILENAME"
			SIZE_COUNT=$((SIZE_COUNT + `stat -c %s "$BLANK_DIRECTORY/$COUNT_FORMATTED-$FILENAME"`))
		fi
	done
	MEGA_COUNT=$((SIZE_COUNT/1048576))
	echo "$RESOURCE (after adding blank files): $COUNT files; cumulative total size $MEGA_COUNT MB"
done

IFS="$OLD_IFS"

MEGA_COUNT=$((SIZE_COUNT/1048576))
echo "Total size of $TOTAL_COUNT copied files: $MEGA_COUNT MB"
echo "Destination directory: $DESTINATION_DIRECTORY"
