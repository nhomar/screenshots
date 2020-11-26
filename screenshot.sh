#!/bin/bash
#----------
# Akkarin's Simple S3 Screenshot Script
#
# Finished instalable and documented by Nhomar.
#  - Sudo apt get dependencies.
#  - Configure first awscli: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
# Requirements:
#  - shutter
#  - awscli
#  - notify-osd
#  - libnotify-bin
#  - xclip
# Note: The directory defined in $SCREENSHOT_PATH needs to exist!
#

#################
# Configuration #
#################
AWS_S3_BUCKET="screenshots.vauxoo.com"
AWS_S3_PATH="nhomar" # THIS WILL BE USERNAME ON VAUXOO
# Permissions can be set to private, public-read, public-read-write, authenticated-read, bucket-owner-read, bucket-owner-full-control and log-delivery-write
AWS_S3_PERMISSIONS="public-read"
AWS_REGION="us-west-1"

SCREENSHOT_PATH="/home/$AWS_S3_PATH/Pictures/pantallazos/"
SCREENSHOT_URL="http://${AWS_S3_BUCKET}/${AWS_S3_PATH}%s"

########################
# END OF CONFIGURATION #
########################
echo "Uploading to ${AWS_S3_BUCKET}/${AWS_S3_PATH}"

# Generate a filename
DATE=$(date +%H%M%S%j%y)
RNDNAME=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w 10 | head -n 1)
FILENAME="${DATE}-${RNDNAME}.png"
FILE_PATH=${1}

if [ -f "${FILE_PATH}" ]; then
    echo "Creating screenshot"
else
    FILE_PATH=$SCREENSHOT_PATH/$FILENAME
    shutter -n -c -s --delay=3 --output=${FILE_PATH} --clear_cache --exit_after_capture
fi
# Log
# Upload
if [ -f "${FILE_PATH}" ]; then
	echo "Uploading ..."
	aws s3 cp --region ${AWS_REGION} --acl "${AWS_S3_PERMISSIONS}" "${FILE_PATH}" s3://${AWS_S3_BUCKET}/${AWS_S3_PATH}/${FILENAME}

	# Add to clipboard
	printf "${SCREENSHOT_URL}" "/${FILENAME}" | xclip -sel clip

	# Notify user
	notify-send "Upload finished successfully! File name created at: ${FILE_PATH} You have the path in your clipboard" --app-name="S3 Paster" --icon=face-angel
else
	echo "Upload aborted! No file written!"
fi
