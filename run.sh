#!/bin/bash

# Factory
if [ `date +%A` == "perjantai" ]; then
    FACTORY="$(curl -vs https://ravintolafactory.com/lounasravintolat/ravintolat/espoo-otaniemi/ 2>&1 | awk '/'`date +%A | sed 's/.*/\u&/'`'/{f=1} f; /Monday/{f=0}' | sed -e 's/<[^>]*>//g' | sed '$d')"
else
    FACTORY="$(curl -vs https://ravintolafactory.com/lounasravintolat/ravintolat/espoo-otaniemi/ 2>&1 | awk '/'`date +%A | sed 's/.*/\u&/'`'/{f=1} f; /'`date -d @$(($(date +%s)+84600)) +%A | sed 's/.*/\u&/'`'/{f=0}' | sed -e 's/<[^>]*>//g' | sed '$d')"
fi

# Silinteri
export PYTHONIOENCODING=utf8
SILINTERI=$(curl -s 'https://www.fazerfoodco.fi/modules/json/json/Index?costNumber=019002&language=fi' | \
                python2 -c "import sys, json; sonni=json.load(sys.stdin); ruuat=[sonni['MenusForDays'][0]['SetMenus'][i]['Name'] + ': ' + ', '.join(sonni['MenusForDays'][0]['SetMenus'][i]['Components']) for i in range(len(sonni['MenusForDays'][0]['SetMenus']))]; print '\n'.join(ruuat)")

# Maukas
MAUKAS=$(curl -s 'https://www.mau-kas.fi/' | grep "block_level bold" | sed -e 's/<[^>]*>//g' | perl -MHTML::Entities -pe 'decode_entities($_);')

TEXT="FACTORY:\n$FACTORY\n\nSILINTERI:\n$SILINTERI\n\nMAUKAS:\n$MAUKAS"

echo $TEXT

if [[ -z "${LUNCH_SECRET}" ]]; then
	echo "Environment variable LUNCH_SECRET must be defined."
	echo "Output is sent to hooks.slack.com/services/\$LUNCH_SECRET."
	exit 1
fi

# Send to Slack
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$TEXT\"}" https://hooks.slack.com/services/$LUNCH_SECRET
