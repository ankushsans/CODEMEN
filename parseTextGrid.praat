form Counting Syllables in Sound Utterances
   real Silence_threshold_(dB) 
   real Minimum_dip_between_peaks_(dB) 
   real Minimum_pause_duration_(s) 
   boolean Keep_Soundfiles_and_Textgrids 
   sentence soundin  
   sentence directory 
   positive Minimum_pitch_(Hz) 
   positive Maximum_pitch_(Hz) 
   positive Time_step_(s) 
endform

# shorten variables
silencedb = 'silence_threshold'
mindip = 'minimum_dip_between_peaks'
showtext = 'keep_Soundfiles_and_Textgrids'
minpause = 'minimum_pause_duration'
 
# read files
 Read from file... 'soundin$'


# use object ID
   soundname$ = selected$("Sound")
   soundid = selected("Sound")
	      
   originaldur = Get total duration
   # allow non-zero starting time
   bt = Get starting time

   # Use intensity to get threshold
   To Intensity... 50 0 yes
   intid = selected("Intensity")
   start = Get time from frame number... 1
   nframes = Get number of frames
   end = Get time from frame number... 'nframes'

   # estimate noise floor
   minint = Get minimum... 0 0 Parabolic
   # estimate noise max
   maxint = Get maximum... 0 0 Parabolic
   #get .99 quantile to get maximum (without influence of non-speech sound bursts)
   max99int = Get quantile... 0 0 0.99

   # estimate Intensity threshold
   threshold = max99int + silencedb
   threshold2 = maxint - max99int
   threshold3 = silencedb - threshold2
   if threshold < minint
       threshold = minint
   endif

  # get pauses (silences) and speakingtime
   To TextGrid (silences)... threshold3 minpause 0.1 silent sounding
   textgridid = selected("TextGrid")
   silencetierid = Extract tier... 1
   silencetableid = Down to TableOfReal... sounding
   nsounding = Get number of rows
   npauses = 'nsounding'
   speakingtot = 0
   for ipause from 1 to npauses
      beginsound = Get value... 'ipause' 1
      endsound = Get value... 'ipause' 2
      speakingdur = 'endsound' - 'beginsound'
      speakingtot = 'speakingdur' + 'speakingtot'
   endfor

   select 'intid'
   Down to Matrix
   matid = selected("Matrix")
   # Convert intensity to sound
   To Sound (slice)... 1
   sndintid = selected("Sound")

   # use total duration, not end time, to find out duration of intdur
   # in order to allow nonzero starting times.
   intdur = Get total duration
   intmax = Get maximum... 0 0 Parabolic

   # estimate peak positions (all peaks)
   To PointProcess (extrema)... Left yes no Sinc70
   ppid = selected("PointProcess")

   numpeaks = Get number of points

   # fill array with time points
   for i from 1 to numpeaks
       t'i' = Get time from index... 'i'
   endfor 


   # fill array with intensity values
   select 'sndintid'
   peakcount = 0
   for i from 1 to numpeaks
       value = Get value at time... t'i' Cubic
       if value > threshold
             peakcount += 1
             int'peakcount' = value
             timepeaks'peakcount' = t'i'
       endif
   endfor


   # fill array with valid peaks: only intensity values if preceding 
   # dip in intensity is greater than mindip
   select 'intid'
   validpeakcount = 0
   currenttime = timepeaks1
   currentint = int1

   for p to peakcount-1
      following = p + 1
      followingtime = timepeaks'following'
      dip = Get minimum... 'currenttime' 'followingtime' None
      diffint = abs(currentint - dip)

      if diffint > mindip
         validpeakcount += 1
         validtime'validpeakcount' = timepeaks'p'
      endif
         currenttime = timepeaks'following'
         currentint = Get value at time... timepeaks'following' Cubic
   endfor


   # Look for only voiced parts
   select 'soundid' 
   To Pitch (ac)... 0.02 30 4 no 0.03 0.25 0.01 0.35 0.25 450
   # keep track of id of Pitch
   pitchid = selected("Pitch")

   voicedcount = 0
   for i from 1 to validpeakcount
      querytime = validtime'i'

      select 'textgridid'
      whichinterval = Get interval at time... 1 'querytime'
      whichlabel$ = Get label of interval... 1 'whichinterval'

      select 'pitchid'
      value = Get value at time... 'querytime' Hertz Linear

      if value <> undefined
         if whichlabel$ = "sounding"
             voicedcount = voicedcount + 1
             voicedpeak'voicedcount' = validtime'i'
             valuelist'voicedcount' = value
         endif
      endif
   endfor

   
   # calculate time correction due to shift in time for Sound object versus
   # intensity object
   timecorrection = originaldur/intdur

   # Insert voiced peaks in TextGrid
   if showtext > 0
      select 'textgridid'
      Insert point tier... 1 syllables
      
      for i from 1 to voicedcount
          position = voicedpeak'i' * timecorrection
          Insert point... 1 position 'i'
      endfor
   endif

Save as text file: "'directory$'/'soundname$'.TextGrid"

# use object ID
	Read from file... 'soundin$'
	soundname$ = selected$("Sound")
	soundid = selected("Sound")
	fileName$ = "f0points'soundname$'.txt"

# calculating f0
	To Pitch... time_step minimum_pitch maximum_pitch
	numberOfFrames = Get number of frames

# Loop through all frames in the Pitch object:
select Pitch 'soundname$'
unit$ = "Hertz"
min_Hz = Get minimum... 0 0 Hertz Parabolic
min$ = "'min_Hz'"
max_Hz = Get maximum... 0 0 Hertz Parabolic
max$ = "'max_Hz'"
mean_Hz = Get mean... 0 0 Hertz
mean$ = "'mean_Hz'"
stdev_Hz = Get standard deviation... 0 0 Hertz
stdev$ = "'stdev_Hz'"
median_Hz = Get quantile... 0 0 0.50 Hertz
median$ = "'median_Hz'"
quantile25_Hz = Get quantile... 0 0 0.25 Hertz
quantile25$ = "'quantile25_Hz'"
quantile75_Hz = Get quantile... 0 0 0.75 Hertz
quantile75$ = "'quantile75_Hz'"
# Collect and save the pitch values from the individual frames to the text file:
quantile250 = 'quantile25$'
quantile750 = 'quantile75$'
meanall = 'mean$'
sd='stdev$'
medi='median$'
mini='min$'
maxi='max$'

maxFormant = 5500
# clean up before next sound file is opened

    select 'intid'
    plus 'matid'
    plus 'sndintid'
    plus 'ppid'
    plus 'pitchid'
    plus 'silencetierid'
    plus 'silencetableid'

	Read from file... 'soundin$'
	soundname$ = selected$ ("Sound")
	To Formant (burg)... 0 5 maxFormant 0.025 50
	Read from file... 'directory$'/'soundname$'.TextGrid
	int=Get number of intervals... 2

if int<2
	warning$="A noisy background or unnatural-sounding speech detected. No result try again"
	appendInfoLine: warning$
	exitScript()
endif


# calculating f0,f1,f2

fff= 0
eee= 0
inside= 0
outside= 0
for k from 2 to 'int'
	select TextGrid 'soundname$'
	label$ = Get label of interval... 2 'k'
	if label$ <> ""

	# calculates the onset and offset
 		vowel_onset = Get starting point... 2 'k'
  		vowel_offset = Get end point... 2 'k'

		select Formant 'soundname$'
		f_one = Get mean... 1 vowel_onset vowel_offset Hertz
		f_two = Get mean... 2 vowel_onset vowel_offset Hertz
		f_three = Get mean... 3 vowel_onset vowel_offset Hertz
		
		ff = 'f_two'/'f_one'
		lnf1 = 'f_one'
		lnf2f1 = ('f_two'/'f_one')
		uplim =(-0.012*'lnf1')+13.17
		lowlim =(-0.0148*'lnf1')+8.18
	
		f1uplim =(lnf2f1-13.17)/-0.012
		f1lowlim =(lnf2f1-8.18)/-0.0148
	
	
	
	if lnf1>='f1lowlim' and lnf1<='f1uplim' 
	    inside = 'inside'+1
		else
		   outside = 'outside'+1
	endif
		fff = 'fff'+'f1uplim'
		eee = 'eee'+'f1lowlim'
ffff = 'fff'/'int'
eeee = 'eee'/'int'
pron =('inside'*100)/('inside'+'outside')
prom =('outside'*100)/('inside'+'outside')
prob1 = invBinomialP ('pron'/100, 'inside', 'inside'+'outside')
prob = 'prob1:2'
		
	endif
endfor

lnf0 = (ln(f_one)-5.65)/0.31
f00 = exp (lnf0)

    Remove
    if showtext < 1
       select 'soundid'
       plus 'textgridid'
       Remove
    endif

   speakingrate = 'voicedcount'/'originaldur'
   speakingraterp = ('voicedcount'/'originaldur')*100/3.93
   articulationrate = 'voicedcount'/'speakingtot'
   articulationraterp = ('voicedcount'/'speakingtot')*100/4.64
   npause = 'npauses'-1
   asd = 'speakingtot'/'voicedcount'
   avenumberofwords = ('voicedcount'/1.74)/'speakingtot'
   avenumberofwordsrp = (('voicedcount'/1.74)/'speakingtot')*100/2.66
   nuofwrdsinchunk = (('voicedcount'/1.74)/'speakingtot')* 'speakingtot'/'npauses'
   nuofwrdsinchunkrp = ((('voicedcount'/1.74)/'speakingtot')* 'speakingtot'/'npauses')*100/9
   avepauseduratin = ('originaldur'-'speakingtot')/('npauses'-1)
   avepauseduratinrp = (('originaldur'-'speakingtot')/('npauses'-1))*100/0.75
   balance = ('voicedcount'/'originaldur')/('voicedcount'/'speakingtot')
   balancerp = (('voicedcount'/'originaldur')/('voicedcount'/'speakingtot'))*100/0.85
   nuofwrds= ('voicedcount'/1.74)
   f1norm = -0.0118*'pron'*'pron'+0.5072*'pron'+394.34
   inpro = ('nuofwrds'*60/'originaldur')
   polish = 'originaldur'/2
   
Erase all

         appendInfoLine:'voicedcount:0'
		 appendInfoLine:'npause:0'
		 appendInfoLine:'speakingrate:0'
		 appendInfoLine:'articulationrate:0'
		 appendInfoLine:'speakingtot:1'
		 appendInfoLine:'originaldur:1'
		 appendInfoLine:'balance:1'	
		 appendInfoLine:'meanall:2'
		 appendInfoLine:'sd:2'
		 appendInfoLine:'medi:1'
		 appendInfoLine:'mini:0'
		 appendInfoLine:'maxi:0'
		 appendInfoLine:'quantile250:0'
		 appendInfoLine:'quantile750:0'