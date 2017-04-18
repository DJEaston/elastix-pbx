#!/bin/bash

YEAR=$1
MONTH=$2
DAY=$3
CALLFILENAME=$4
MIXMON_FORMAT=$5
MIXMON_DIR=$6

if [ -z "${MIXMON_DIR}" ]; then
SPOOLDIR="/var/spool/asterisk/monitor/"
else
SPOOLDIR=${MIXMON_DIR}
fi

FFILENAME=${SPOOLDIR}${YEAR}/${MONTH}/${DAY}/${CALLFILENAME}.${MIXMON_FORMAT}

/usr/bin/test ! -e ${FFILENAME} && exit 21

WAVFILE=${FFILENAME}
MP3FILE=`echo ${WAVFILE} | /bin/sed 's/.wav/.mp3/g'`

SUDO="/usr/bin/sudo"
LOWNICE="/bin/nice -n 19 /usr/bin/ionice -c3"

${SUDO} ${LOWNICE} /usr/bin/lame --quiet --preset phone -h -v ${WAVFILE} ${MP3FILE}

${SUDO} /bin/chown --reference=${WAVFILE} ${MP3FILE}
/bin/chmod --reference=${WAVFILE} ${MP3FILE}
/bin/touch --reference=${WAVFILE} ${MP3FILE}

/usr/bin/test -e ${MP3FILE} && /bin/rm -f ${WAVFILE}

${SUDO} ${LOWNICE} /usr/bin/ffmpeg -loglevel quiet -y -i ${MP3FILE} -f wav -acodec copy ${WAVFILE} >/dev/null 2>&1

${SUDO} /bin/chown --reference=${MP3FILE} ${WAVFILE}
/bin/chmod --reference=${MP3FILE} ${WAVFILE}
/bin/touch --reference=${MP3FILE} ${WAVFILE}

/usr/bin/test -e ${WAVFILE} && /bin/rm -f ${MP3FILE}
