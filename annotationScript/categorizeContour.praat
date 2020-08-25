# Annotate Files 
# michael wagner. chael@mcgill.ca. August 2009/2015/2020

Text writing preferences: "UTF-8"


echo Truncate Silence from Soundfiles
printline

form Truncate Silence from Soundfiles
    comment Important:
    comment Check whether results are correctly written after annotating first file!
    comment
    sentence annotator test
    comment Set this flag if you start a new annotation and are not continuing an old one:
	boolean addcolumn 0
    comment Set these flags if you want to see condition/prior annotation:
    boolean ShowCondition 0 
    boolean ShowPriorAnnotation 0
	sentence datafile responses.txt
	sentence Extension .wav
	boolean Soundfile_in_same_directory_as_script no
	sentence sound_Directory ../data/audiowav/
	boolean makeDirectory

	boolean truncate no
    boolean make_guess no
	natural woiTier 3
	optionmenu ZoneIn: 1
			option No
		    option up to word of interest
            option as of word of interest
	integer zoneWOI 5
    positive marginSize 0.2
endform

silenceThreshhold  = 50

printline zoneIn 'zoneIn$': 'zoneWOI'

#  Read in woi file
Read Table from tab-separated file... 'datafile$'
datafile = selected("Table")

if addcolumn 
	select datafile
	Append column... 'annotator$'_contour
	Append column... 'annotator$'_prominence
	Append column... 'annotator$'_quality
	Append column... 'annotator$'_comments
endif

if makeDirectory
	system mkdir truncated
	system mkdir problematic
endif 

if soundfile_in_same_directory_as_script
    directory_sound$ = ""
else
     directory_sound$ = "'directory_sound$'/"
endif   

trials = Get number of rows

for i from 1 to trials

    select datafile
    annot$ = Get value... 'i' 'annotator$'_contour
    condition = Get value... 'i' condition

    if (annot$ = "" or annot$ ="?")
        filename$ = Get value... 'i' recordedFile
	    printline 'filename$' 'i'/'trials'
	    soundfile$ = sound_Directory$ + filename$

        displayInfo$ =  ""

        if showCondition
            condition$ = Get value... 'i' Context
            displayInfo$ = displayInfo$ + "--'condition$'--"
        endif

        if showPriorAnnotation
             prior$ = Get value... 'i' Contour
             priorProminence$ = Get value... 'i' Prominence
			 displayInfo$ = displayInfo$  +  "Contour: 'prior$'  Prom: 'priorProminence$'"
        endif


 	    if fileReadable(soundfile$)
    
          Read from file... 'soundfile$'
          soundfile = selected("Sound")
          
	      length = length(filename$)
	      length2 = length(extension$)
	      length = length - length2
  	      short$ = left$(filename$, length)

	      grid$ = sound_Directory$+short$+".TextGrid"
	      gridshort$ = short$+".TextGrid"

	      lab$ = sound_Directory$+short$+".lab"
	      labshort$ = short$ + ".lab"

	      txtgrd = 0
 
    	  if fileReadable (grid$)
          	Read from file... 'grid$'
	  	    Insert interval tier... 1 sound
            Set interval text... 1 1 'displayInfo$'
	  	    txtgrd = 1
	  	    soundgrid = selected("TextGrid")	
     	  elsif fileReadable(lab$)
	  	    txtgrd = 2
		    select soundfile
	  	    To TextGrid... label
	  	    soundgrid = selected("TextGrid")
	  	    Read Strings from raw text file... 'lab$'
	 	    labelfile = selected("Strings")
	  	    label$ = Get string... 1
	 	    Remove
	   	    select soundgrid
           	Set interval text... 1 1 'label$'
	      endif

        printline 'lab$' 'txtgrd' textgrid

        select soundfile
        totallength = Get end time

        onsettime = 0
        offsettime = totallength

# Make guess about begin and end of sondfile

if make_guess
     select soundfile
     To Intensity... 100 0
     soundintense = selected("Intensity")
     n = Get number of frames

     onsetfound = 0	
     offsetfound = 0

    for y to n
	    intensity = Get value in frame... y	
     	if intensity < silenceThreshhold and onsetfound = 1 and offsetfound = 0
		  offsettime =  Get time from frame... y
		  offsetfound = 1
		  if (offsettime+marginSize)<=totallength
		    offsettime=offsettime+marginSize
          endif
	    elsif intensity > silenceThreshhold and onsetfound = 0
		  onsettime =  Get time from frame... y
          onsetfound = 1
		  # add a little silence at beginning:
		  if (onsettime-marginSize)>0
		    onsettime=onsettime-marginSize
          endif
	    elsif intensity > silenceThreshhold
		  offsetfound = 0
	    endif
    endfor	
endif


if txtgrd <> 0 and zoneIn$ <> "No"
        select soundgrid
		nTier = Get number of tiers
        if nTier >= woiTier
			ninter = Get number of intervals... 'woiTier'
			for j to ninter
				labint$ = Get label of interval... 'woiTier' j
			
				if labint$="'zoneWOI'" or labint$="'zoneWOI' "
				    printline Zone in 'zoneIn$': 'labint$'

                   if zoneIn$="up to word of interest" 
 						printline yessir
				    	offsettime= Get end point... 'woiTier' j
						if (offsettime+marginSize)<totallength
		              		offsettime=offsettime+marginSize
                      	endif

                   else
				    	onsettime= Get start point... 'woiTier' j
		            	if (onsettime-marginSize)>0
		              		onsettime=onsettime-marginSize
                      	endif

				   endif
              endif
			endfor
		else
			printline "There is no tier 'woiTier' to zone in, there are only 'nTier' tiers"
        endif
endif



# annotate and truncate

		select soundgrid 
		Rename... soundname

		select soundfile
		Rename... soundname
		editorname$ = "Sound"

		if txtgrd <> 0
			plus soundgrid
			editorname$ = "TextGrid"
		endif

		Edit
		 editor 'editorname$' soundname
			 	Select... onsettime offsettime	
				if zoneIn$ <> "No"
					Zoom to selection
				endif
				
				beginPause: "Annotation/Truncation"
					boolean: "Problematic", 0
					boolean: "Truncate" , 'truncate'
					boolean: "SaveWavAndLabFile", 'truncate'
					comment: "'Polarity focus' =  fall/upstepped Fall with prominence on verb/subject+verb!"
					choice: "Contour", 1 
							option ("fall")
							option ("fall with upstep")
							option ("risefallrise")
							option ("contradiction")
							option ("incredulity")
							option ("yesnoRise")
							option ("presumption")
							option ("continuation")
							option ("otherContour")
							option ("unclear")
							option ("problematic")
				    choice: "Prominence", 1 
							option ("subject")
							option ("verb")
							option ("object")
							option ("subject+object")
							option ("verb+object")
							option ("subject+verb")
				    optionMenu: "Quality", 1
							option: "OK"
							option: "Not Fluent"
							option: "Problematic"
							option: "Alignment off"
							option: "WOI annotation didn't work"
					comment: "add contour name here if it wasn't in the list:"
                    sentence: "comments", ""
				clicked = endPause: "Continue", 1
				
			   if truncate = 0
				   Select... onsettime offsettime
			   else
				   onsettime = Get start of selection
				   offsettime = Get end of selection
		       endif		
			
			  Extract selected sound (time from 0)
			  nsound=selected("Sound")
		      if txtgrd<>0
				Extract selected TextGrid (time from 0)
				newsoundgrid = selected("TextGrid")
			 endif
		   endeditor

		select datafile
		Set string value... 'i' 'annotator$'_contour 'contour$'
		Set string value... 'i' 'annotator$'_prominence 'prominence$'
		Set string value... 'i' 'annotator$'_quality 'quality$'
		Set string value... 'i' 'annotator$'_comments 'comments$'
		Write to table file... 'datafile$'

	 if  saveWavAndLabFile
		if problematic=0
			select nsound
			Write to WAV file... truncated/'filename$'
			
			if txtgrd = 1
				select newsoundgrid 
				Write to text file... truncated/'gridshort$'
			elsif txtgrd = 2
				printline yes
				labshort$ = short$ + ".lab"
				select newsoundgrid 
				labtext$ = Get label of interval... 1 1
    				labtext$ = labtext$ + newline$
				labtext$ > truncated/'labshort$'

			endif

			printline  'filename$'

		else 
			select nsound
			Write to WAV file... problematic/'filename$'

			if txtgrd = 1
				select soundgrid
				Write to text file... problematic/'gridshort$'
			elsif txtgrd = 2
				select newsoundgrid 
				labtext$ = Get label of interval... 1 1
    				labtext$ = labtext$ + newline$
				labtext$ > problematic/'labshort$'
			endif

			printline  'filename$' was *not* truncated and saved!
		endif
	  endif
	
      if make_guess
		select soundintense 
		Remove
      endif

	  select soundfile
	  Remove

	  select nsound
	  Remove

	printline txtgrd 'txtgrd'

	  if txtgrd = 1
		select soundgrid 
		Remove
		select newsoundgrid 
		Remove
	  elsif txtgrd = 2
		select newsoundgrid 
		Remove
		select soundgrid 
		Remove
	 endif

endif
endif



endfor


select datafile
Remove

