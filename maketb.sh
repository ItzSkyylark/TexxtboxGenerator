#!/bin/bash
# usage: maketb.sh text speaker0.png speaker1.png boxart.png functionname startval

# if working directory is not .minecraft, complain
if [ ! "${PWD##*/}" = ".minecraft" ]; then
clear
echo -e "You do not seem to be running this script from inside the .minecraft folder.\nThe script will most likely not work at all unless it is inside the .minecraft folder.\nIf you are SURE this is okay then type 'y' to continue."
echo -n "Continue anyway? [y/n]: "
read -r ok
if [ ! "$ok" = "y" ]; then
echo ""
exit
fi
fi

clear
echo "Jambl3r's textbox generator for vanilla Minecraft: Java Edition"
echo -e "---------------------------------------------------------------\n"

echo -e "This script needs to know which world to send its data pack to.\nPlease look at the following list of your worlds.\nIf the list is empty, create a world in-game first and come back later.\nChoose which world you want your textbox to appear in by typing its number and pressing enter."
worlds=(saves/*)
for i in $( seq 0 ${#worlds[@]} ); do
echo -n "[$i] "
echo ${worlds[i]}
done
echo -n "Choose: [0-${#worlds[@]}]"
read -r ans
world=${worlds[ans]}
echo -e "\nEnter the text you want to input into the textbox.\nYou can use 3 lines for text.\nTo end a line and start the next, enter a backslash (\\) followed by a space."
echo -n "Text: "
read -r text
IFS='\\' read -ra ln <<< "$text"
for i in $( seq 0 ${#ln[@]} ); do
if [ "${#ln[@]}" -gt 3 ]; then
        echo "Too many lines. (The max is 3, got ${#ln[@]})"
	echo "Aborted. Restart the script to try again."
        exit
elif [ "${#ln[i]}" -gt 31 ]; then
        echo "WARNING: One or more of your lines might be too long. (The maximum safe length is 31, got ${#ln[i]})"
fi
done
echo -e "\nYour text will be displayed as:\n"
echo -n " "
for i in $( seq 0 ${#ln[@]} ); do
echo "${ln[i]}"
done
echo -e "\nIs this okay?"
echo -n "Answer [y/n]: "
read -r ok
if [ ! "$ok" = "y" ]; then
echo "Aborted. Restart the script to try again."
exit
fi
echo -e "\nGive the full path to the image file containing your speaker with their mouth closed."
echo -n "Path: "
read -r speaker0
echo -e "\nGive the full path to the image file containing your speaker with their mouth open."
echo -n "Path: "
read -r speaker1
echo -e "\nGive the full path to the image file containing your textbox graphic."
echo -n "Path: "
read -r boxart
echo -e "\nDo you want your textbox to have a sweep up transition to appear on screen, or appear instantly?"
echo -n "Answer [sweep/instant]: "
read -r trin
echo -e "\nDo you want your textbox to have a sweep down transition to close, or disappear instantly?"
echo -n "Answer [sweep/instant]: "
read -r trout
echo -e "\nEnter the number of ticks you want the textbox to wait for after this transition before\nthe textbox begins to close. The maximum is 40. (or enter '0' to start instantly)."
echo -n "Ticks [0-40]: "
read -r hout
echo -e "\nWhat unicode start offset should the textbox start at? (If this is your first textbox, try 'e000')"
echo -n "Offset: "
read -r startval
echo -e "\nName this specific textbox. This will influence the function name. Do not use any spaces."
echo -n "Name: "
read -r functionname
echo -e "\nChoose a namespace for this textbox to use.\nA namespace is a way to group your textboxes to keep them seperate\nfrom other things within your project. If you don't know or care, try 'minecraft'\nDo not use any spaces"
echo -n "Namespace: "
read -r namespace
echo -e "\nChoose a name for your data pack and resource pack.\nThis can be more general and if you can use an existing name if you like.\nThe script will write inside whatever pack you name here."
echo -n "Pack name: "
read -r packname
# set counters to defaults and if unset
nl=0
ns=0
: ${speaker0:=speaker0.png}
: ${speaker1:=speaker1.png}
: ${boxart:=boxart.png}
: ${trin:=instant}
: ${trout:=instant}
: ${startval:=e000}
: ${functionname:=mytextbox}
: ${namespace:=minecraft}
: ${hout:=0}
: ${packname:=mytextbox_pack}
u0=0x$startval

echo -e "\n\nAre you happy with these settings:\n---------------------------------"
echo -e "\nI will make a textbox at $namespace:$functionname from character $startval into pack $packname.\n\nSpeaker images:\n$speaker0\nand\n$speaker1\n\nTextbox graphic:\n$boxart\n\nTransitions: $trin in and $trout out ($hout).\n"
echo -n "Answer [y/n]: "
read -r ok
if [ ! "$ok" = "y" ]; then
echo "Aborted. Restart the script to try again."
exit
fi


# making folders
rm -r .maketb-tmp &> /dev/null
mkdir .maketb-tmp &> /dev/null
mkdir -p "$world/datapacks/$packname/data/$namespace/functions/"
mkdir -p "resourcepacks/$packname/assets/$namespace/font/"
mkdir -p "resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/"

touch "$world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"
echo -e "# Output from Jambl3r's textbox generator\nscoreboard players set @p hold 0\n" > "$world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"

# process speaker image:
# make sure speaker is 98x98 so it fits in the box
convert $speaker0 -resize 82x82 .maketb-tmp/s0-82.png
convert $speaker1 -resize 82x82 .maketb-tmp/s1-82.png

# put speaker in box
convert -composite $boxart .maketb-tmp/s0-82.png -geometry +16+16 .maketb-tmp/ws0.png
convert -composite $boxart .maketb-tmp/s1-82.png -geometry +16+16 .maketb-tmp/ws1.png

# start default.json
echo "{\"providers\": [{\"type\":\"bitmap\",\"file\":\"$namespace:textbox/uffff.png\",\"ascent\":-32768,\"height\":-3,\"chars\":[\"\uffff\"]}," > "resourcepacks/$packname/assets/$namespace/font/textbox.json"

# make magic negative spacer

echo -n 'iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAABF0lEQVR42u3BIQEAAAACIC/4/6zVEUACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMDpAAFNABKWce51AAAAAElFTkSuQmCC' | base64 --decode > "resourcepacks/$packname/assets/$namespace/textures/textbox/uffff.png"

if [ "$trin" = "sweep" ]; then
# make the screen fade in, closed mouth, no text
for j in $( seq 1 6 ); do
convert -background transparent .maketb-tmp/ws0.png -layers flatten -page +0+$((18*(7-$j))) -crop 256x114 -resize 256x114 -gravity south -extent 256x114 PNG00:.maketb-tmp/out.png

# assign the letters 2 unicode characters
ui1=$( printf '%x' $((2*$j-2+$u0)) )
ui2=$( printf '%x' $((2*$j-1+$u0)) )

# name images appropriately
mv .maketb-tmp/out-0.png "resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/u$ui1.png"
mv .maketb-tmp/out-1.png "resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/u$ui2.png"

# add characters to default.json
echo  "{\"type\":\"bitmap\",\"file\":\"$namespace:textbox/$functionname/u$ui1.png\",\"ascent\":32,\"height\":57,\"chars\":[\"\\u$ui1\"]}," >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"
echo  "{\"type\":\"bitmap\",\"file\":\"$namespace:textbox/$functionname/u$ui2.png\",\"ascent\":32,\"height\":57,\"chars\":[\"\\u$ui2\"]}," >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"

# write commands for showing the fade in
echo "execute if score @p textstep = @p tsstore run title @p actionbar {\"text\":\"\\u$ui1\\uffff\\u$ui2\",\"font\":\"$namespace:textbox\"}
execute if score @p textstep = @p tsstore run scoreboard players remove @p tsstore 1
execute unless score @p tsstore <= @p textstep run scoreboard players add @p textstep 1
" >> "$world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"
done
fi

	# begin reading input text and start loop.
	# for each i of the letters from 1 to i of the input string:
	for i in $( seq 1 ${#text} )
	do

	# set variable arg to the first input string
	arg="$text"

	# tstep is the whole input string from the first letter to i
	tstep=${arg:0:i}

	# lnstep is what it is
	IFS='\\' read -ra lnstep <<< "$tstep"

	# current is the current letter only
	current=${tstep: -1}

		# do normal mouth movement
		if [ "${chistory: -2}" = "11" ] || [ "${chistory: -2}" = "10" ]; then
		closed=0
		elif [ "${chistory: -2}" = "00" ] || [ "${chistory: -2}" = "01" ]; then
		closed=1
		elif [[ "${chistory: -1}" != "1" ]] || [[ "${chistory: -1}" != "0" ]]; then
		closed=0
		elif [[ "${chistory: -2}" != "11" ]] || [[ "${chistory: -2}" != "01" ]] || [[ "${chistory: -2}" != "10" ]] || [[ "${chistory: -2}" != "00" ]]; then
		closed=0
		fi

		# check if the current letter is a backslash. if so, do not print the letter
		if [ "$current" = "\\" ]; then
		nl=$(($nl-1))
		print=0

		# check if the current letter is a backtick. if so, do not print the letter
		elif [ "$current" = "\`" ]; then
		ns=$(($ns-1))
		print=0

		# now that we know the letter is to be printed, we need to know its properties for expression
		# check if the current letter is a space
		elif [ "$current" = " " ]; then
		tone=0
		pause=0
		print=1
		ec="none"

		# check if the current letter is an exclamation
		elif [ "$current" = "!" ]; then
		tone=3
		closed=1
		pause=1
		print=1
		ec="exclamation"

		# check if the current letter is uppercase
		elif [[ "$current" =~ [A-Z] ]]; then
		tone=3
		pause=0
		print=1
		ec="${current,,}"

		# check if the current letter is a question
		elif [ "$current" = "?" ]; then
		tone=4
		closed=1
		pause=1
		print=1
		ec="question"

		# check if the current letter is a full stop
		elif [ "$current" = "." ]; then
		tone=2
		closed=1
		pause=1
		print=1
		ec="none"

		# check if the current letter is a comma
		elif [ "$current" = "," ]; then
		tone=2
		closed=1
		pause=1
		print=1
		ec="none"

		# check if the current letter is an apostrophe
                elif [ "$current" = "'" ]; then
                tone=1
                closed=1
                pause=0
                print=1
                ec="none"

		else
		tone=1
		pause=0
		print=1
		ec="$current"

		fi

		# assign the letters 2 unicode characters
		if [ "$trin" = "sweep" ]; then
		uc1=$( printf '%x' $((2*$i-2+$u0+12)) )
		uc2=$( printf '%x' $((2*$i-1+$u0+12)) )
		elif [ "$trin" = "instant" ]; then
		uc1=$( printf '%x' $((2*$i-2+$u0)) )
                uc2=$( printf '%x' $((2*$i-1+$u0)) )
		fi

		# make note of previous mouth movement
		chistory="$chistory$closed"

		# create the characters and name them after what character they are
		if [ "$closed" = "1" ]; then
		convert .maketb-tmp/ws0.png -font .fonts/mc.otf -pointsize 20 \
		-fill "#292929" -annotate +124+40 "${lnstep[0]}" -annotate +124+64 "${lnstep[1]}" -annotate +124+88 "${lnstep[2]}" \
		-fill white     -annotate +122+38 "${lnstep[0]}" -annotate +122+62 "${lnstep[1]}" -annotate +122+86 "${lnstep[2]}" \
		-crop 256x114 PNG00:.maketb-tmp/out.png

		mv .maketb-tmp/out-0.png "resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/u$uc1.png"
		mv .maketb-tmp/out-1.png "resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/u$uc2.png"
		else
		convert .maketb-tmp/ws1.png -font .fonts/mc.otf -pointsize 20 \
                -fill "#292929" -annotate +124+40 "${lnstep[0]}" -annotate +124+64 "${lnstep[1]}" -annotate +124+88 "${lnstep[2]}" \
                -fill white     -annotate +122+38 "${lnstep[0]}" -annotate +122+62 "${lnstep[1]}" -annotate +122+86 "${lnstep[2]}" \
                -crop 256x114 PNG00:.maketb-tmp/out.png

                mv .maketb-tmp/out-0.png "resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/u$uc1.png"
                mv .maketb-tmp/out-1.png "resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/u$uc2.png"
		fi

		# add characters to default.json
		echo  "{\"type\":\"bitmap\",\"file\":\"$namespace:textbox/$functionname/u$uc1.png\",\"ascent\":32,\"height\":57,\"chars\":[\"\\u$uc1\"]}," >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"
		if [ "$i" -lt ${#text} ] && [ "$print" = "1" ] ; then
		echo  "{\"type\":\"bitmap\",\"file\":\"$namespace:textbox/$functionname/u$uc2.png\",\"ascent\":32,\"height\":57,\"chars\":[\"\\u$uc2\"]}," >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"
		elif [ "$print" = "1" ]; then
		echo  "{\"type\":\"bitmap\",\"file\":\"$namespace:textbox/$functionname/u$uc2.png\",\"ascent\":32,\"height\":57,\"chars\":[\"\\u$uc2\"]}" >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"
		fi

# start printing next command group
if [ "$print" = "1" ]; then
echo "execute if score @p textstep = @p tsstore run title @p actionbar {\"text\":\"\\u$uc1\\uffff\\u$uc2\",\"font\":\"$namespace:textbox\"}
execute at @p if score @p textstep = @p tsstore run stopsound @p voice
execute at @p if score @p textstep = @p tsstore run playsound minecraft:testkit.high.synth_$ec voice @p ~ ~ ~ 1" >> "$world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"
	# if holding before the exit transition is expected, set the hold flag
	if [ ! "$hout" = "0" ] && [ "$i" = ${#text} ]; then
	echo "execute if score @p textstep = @p tsstore run scoreboard players set @p hold 1" >> "$world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"
	fi
echo "execute if score @p textstep = @p tsstore run scoreboard players set @p pause $pause
execute if score @p textstep = @p tsstore run scoreboard players remove @p tsstore 1
execute unless score @p tsstore <= @p textstep run scoreboard players add @p textstep 1
" >> "$world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"
fi
done
echo "SAVED graphics to resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/"

# make sure pause is off now that the speech has finished
echo "execute if score @p textstep = @p tsstore run scoreboard players set @p pause 0" >> "$world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"

if [ "$trout" = "sweep" ]; then
	# fade out, closed mouth, full text
	echo -n "," >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"
	for k in $( seq 1 6 ); do
	convert -background transparent .maketb-tmp/ws0.png -font .fonts/mc.otf -pointsize 20 -fill white \
	-annotate +122+38 "${lnstep[0]}" -annotate +122+62 "${lnstep[1]}" -annotate +123+86 "${lnstep[2]}" \
	-layers flatten -page +0+$((18*$k)) -crop 256x114 -resize 256x114 -gravity south -extent 256x114 \
	PNG00:.maketb-tmp/out.png

	# assign the letters 2 unicode characters
	uo1=$( printf '%x' $((2*$k+0x$uc1)) )
	uo2=$( printf '%x' $((2*$k+0x$uc2)) )

	# name images appropriately
	mv .maketb-tmp/out-0.png "resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/u$uo1.png"
	mv .maketb-tmp/out-1.png "resourcepacks/$packname/assets/$namespace/textures/textbox/$functionname/u$uo2.png"

	# add characters to default.json and close file
	echo  "{\"type\":\"bitmap\",\"file\":\"$namespace:textbox/$functionname/u$uo1.png\",\"ascent\":32,\"height\":57,\"chars\":[\"\\u$uo1\"]}," >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"
	if [ "$k" -lt "6" ]; then
	echo  "{\"type\":\"bitmap\",\"file\":\"$namespace:textbox/$functionname/u$uo2.png\",\"ascent\":32,\"height\":57,\"chars\":[\"\\u$uo2\"]}," >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"
	else
	echo "{\"type\":\"bitmap\",\"file\":\"$namespace:textbox/$functionname/u$uo2.png\",\"ascent\":32,\"height\":57,\"chars\":[\"\\u$uo2\"]}" >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"
	fi

	# write commands for showing the fade out
	echo "execute if score @p textstep = @p tsstore run title @p actionbar {\"text\":\"\\u$uo1\\uffff\\u$uo2\",\"font\":\"$namespace:textbox\"}
execute if score @p textstep = @p tsstore run scoreboard players remove @p tsstore 1
execute unless score @p tsstore <= @p textstep run scoreboard players add @p textstep 1
" >> "$world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"
	done
fi
	echo -n "]}" >> "resourcepacks/$packname/assets/$namespace/font/textbox.json"
	echo "SAVED font providers to resourcepacks/$packname/assets/$namespace/font/textbox.json"

# find total number of command groups
limit=$((${#text}+$nl+1))
if [ "$trin" = "sweep" ]; then
limit=$(($limit+6))
fi
if [ "$trout" = "sweep" ]; then
limit=$(($limit+6))
fi
if [ "$trout" = "instant" ]; then
uo2=$uc2
fi
# start printing function ending
echo "scoreboard players set @p textstep 1
scoreboard players add @p tsstore 2
execute unless score @p tsstore matches $limit if score @p hold matches 1 run schedule function $namespace:$functionname $hout
execute unless score @p tsstore matches $limit if score @p pause matches 0 if score @p hold matches 0 run schedule function $namespace:$functionname 1
execute unless score @p tsstore matches $limit if score @p pause matches 1 if score @p hold matches 0 run schedule function $namespace:$functionname 6
execute if score @p tsstore matches $limit run title @p actionbar \"\"
execute if score @p tsstore matches $limit run scoreboard players set @p tsstore 1" >> "$world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"

# make mcmeta files
touch "resourcepacks/$packname/pack.mcmeta"
echo "{\"pack\":{\"pack_format\":9,\"description\":\"Generated using Jambl3r's textbox generator. Last updated $(  date +%F\ %H:%M:%S )\"}}" >> "resourcepacks/$packname/pack.mcmeta"
touch "$world/datapacks/$packname/pack.mcmeta"
echo "{\"pack\":{\"pack_format\":9,\"description\":\"Generated using Jambl3r's textbox generator. Last updated $(  date +%F\ %H:%M:%S )\"}}" >> "$world/datapacks/$packname/pack.mcmeta"

# make load.mcfunction
touch "$world/datapacks/$packname/data/$namespace/functions/load_$functionname.mcfunction"
echo "scoreboard objectives add pause dummy
scoreboard objectives add textstep dummy
scoreboard objectives add tsstore dummy
scoreboard objectives add hold dummy
scoreboard players set @p pause 0
scoreboard players set @p textstep 1
scoreboard players set @p tsstore 1
scoreboard players set @p hold 0" >> "$world/datapacks/$packname/data/$namespace/functions/load_$functionname.mcfunction"

# tag load in minecraft/tags
mkdir -p "$world/datapacks/$packname/data/minecraft/tags/functions"
mv "$world/datapacks/$packname/data/minecraft/tags/functions/load.json" "$world/datapacks/$packname/data/minecraft/tags/functions/load.json.old" &> /dev/null
touch "$world/datapacks/$packname/data/minecraft/tags/functions/load.json"
echo "{\"replace\":\"false\",\"values\":[\"$namespace:load_$functionname\"]}" > "$world/datapacks/$packname/data/minecraft/tags/functions/load.json"

# all done!
echo "Total character range is $u0 to 0x$uo2"
echo "SAVED function to $world/datapacks/$packname/data/$namespace/functions/$functionname.mcfunction"
rm -r .maketb-tmp
