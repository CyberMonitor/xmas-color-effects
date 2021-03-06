{{
        http://www.deepdarc.com/ybox2
        http://www.deepdarc.com/2010/11/27/hacking-christmas-lights/
}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
CON
  ON_ALARM_HOUR         = "A"+("H"<<8)
  ON_ALARM_MIN          = "A"+("M"<<8)
  OFF_ALARM_HOUR         = "a"+("H"<<8)
  OFF_ALARM_MIN          = "a"+("M"<<8)
  SOLID_COLOR_KEY           = "S"+("C"<<8)
  CURRENT_PROGRAM_KEY           = "C"+("P"<<8)

  ON_PIN		= 24

OBJ
  settings      : "settings"
  xmas          : "xmas"
  subsys        : "subsys"

VAR
    long prog_step
    long current_program
    long active
    long stack[100]
    long cog
PUB start
    stop
    xmas.start(12)
    xmas.set_standard_enum
    active := TRUE
    current_program := 1

    if not settings.findKey(SOLID_COLOR_KEY)
        settings.setLong(SOLID_COLOR_KEY,xmas.make_color_rgb(14,7,1))

    if not settings.findKey(CURRENT_PROGRAM_KEY)
        settings.setByte(CURRENT_PROGRAM_KEY,1)

    solid_color := settings.getLong(SOLID_COLOR_KEY)
    current_program := settings.getByte(CURRENT_PROGRAM_KEY)
    cog := cognew(program_loop, @stack) + 1

PUB stop
    if cog
        cogstop(cog~ - 1)
        xmas.set_standard_enum  

PUB refresh_alarm_settings
    if cog
        cogstop(cog~ - 1)
    cog := cognew(program_loop, @stack) + 1
PRI delay_ms(Duration)
    waitcnt(((clkfreq / 1_000 * Duration - 3932)) + cnt)

PRI delay_s(Duration)
	repeat Duration
		waitcnt(1000)

PRI program_loop : next_event_time
    repeat
		dira[ON_PIN] := 1
        if active == TRUE
            next_event_time := get_next_off_alarm_time
			outa[ON_PIN] := 1
			delay_ms(250)
            xmas.set_standard_enum
            repeat while active == TRUE
                case current_program
                    1: program_1_step                
                    2: program_2_step
                    3: program_3_step
                    4: program_4_step
                    5: program_5_step
                    6: program_6_step
                    7: program_7_step
                    8: program_8_step
                    9: program_9_step
                    10: program_10_step
                    11: program_11_step
                    12: program_12_step
                'delay_ms(1)
                if subsys.RTC>next_event_time
                    active~
            xmas.set_standard_enum
        else
			outa[ON_PIN] := 0
            next_event_time := get_next_on_alarm_time
            xmas.set_standard_enum
            repeat until active
                if subsys.RTC>next_event_time
                    active~~

PRI program_1_step | j
    ' This code makes an animated rainbow.
    repeat j from 0 to xmas#MAX_BULB
        xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,xmas.make_color_hue((prog_step+j)//constant(xmas#MAX_HUE+1)))
    prog_step++


PRI program_2_step | j
    ' Solid, changing colors
    repeat j from 0 to xmas#MAX_BULB
        xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,xmas.make_color_hue(prog_step//constant(xmas#MAX_HUE+1)))
    prog_step++

PRI program_3_step | i2,j,j2,count,intensity,next_off_time
    count:=14

    prog_step *= 37
    prog_step += 13
    prog_step //= 64

    repeat j from xmas#MAX_INTENSITY/count to 0
        i2 := prog_step
        repeat j2 from 0 to count-1
            i2 *= 37
            i2 += 13
            i2 //= 64
            if i2 <> xmas#BROADCAST_BULB
                intensity := j+(xmas#MAX_INTENSITY/count)*j2
                xmas.set_bulb(i2,intensity*intensity/255,solid_color)
     

PRI program_4_step | j
    ' red/green stripes
    repeat j from 0 to xmas#MAX_BULB
        if ((j+prog_step)/5)&1
            xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,xmas#COLOR_RED)
        else
            xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,xmas#COLOR_GREEN)
    prog_step++
    delay_ms(10)

{
    ' other stripes
    msec := clkfreq/5
    repeat
        repeat j from 0 to xmas#MAX_BULB
            if ((cnt+msec*(j*j/xmas#MAX_BULB))/clkfreq)&1
                xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,xmas#COLOR_RED)
            else
                xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,xmas#COLOR_GREEN)
}
     

PRI program_5_step | i2,j,j2,count,intensity
    ' Trail
    count:=6
    prog_step++
    prog_step //= 50
    repeat j from xmas#MAX_INTENSITY/count to 0
        i2 := prog_step
        repeat j2 from 0 to count-1
            i2 ++
            i2 //= 50
            if i2 <> xmas#BROADCAST_BULB
                intensity := j+(xmas#MAX_INTENSITY/count)*j2
                xmas.set_bulb(i2,intensity*intensity/255,solid_color)


PRI program_6_step | i,j,fading_intensity
    ' simple chaser
	repeat i from 0 to xmas#DEFAULT_INTENSITY step 16
		fading_intensity := xmas#DEFAULT_INTENSITY-i
		fading_intensity *= fading_intensity
		fading_intensity /= xmas#DEFAULT_INTENSITY
		repeat j from 0 to 49
			if j&1
				xmas.set_bulb(j,(i*3)<#xmas#DEFAULT_INTENSITY,solid_color)
			else
				xmas.set_bulb(j,fading_intensity,solid_color)
	repeat j from 0 to 49
		if j&1
			xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,solid_color)
		else
			xmas.set_bulb(j,0,solid_color)
	delay_ms(250)
	repeat i from 0 to xmas#DEFAULT_INTENSITY step 16
		fading_intensity := xmas#DEFAULT_INTENSITY-i
		fading_intensity *= fading_intensity
		fading_intensity /= xmas#DEFAULT_INTENSITY
		repeat j from 0 to 49
			ifnot j&1
				xmas.set_bulb(j,(i*3)<#xmas#DEFAULT_INTENSITY,solid_color)
			else
				xmas.set_bulb(j,fading_intensity,solid_color)
	repeat j from 0 to 49
		ifnot j&1
			xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,solid_color)
		else
			xmas.set_bulb(j,0,solid_color)
	delay_ms(250)


PRI program_7_step | i2,j,j2,count,intensity
    ' solid
	repeat j from 0 to xmas#MAX_BULB
		xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,solid_color)
    prog_step++

PRI program_8_step | j,r,g,b
    repeat j from 0 to xmas#MAX_BULB
		r := sinTable(j*$A0 - prog_step*$59*3)+$FFFF
		g := sinTable(j*$FF + prog_step*$40*3)+$FFFF
		b := sinTable(j*$8B + prog_step*$22*3)+$FFFF
		xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,xmas.make_color_rgb(r>>13,g>>13,b>>13))
    prog_step++

PRI make_fire_gradient(x)
    case (x>>4)
        0:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(x,0,0)
        1:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(xmas#MAX_COLOR_VALUE,x,0)
        2:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(xmas#MAX_COLOR_VALUE,xmas#MAX_COLOR_VALUE,x)
    return 0

PRI program_9_step | j,r
    repeat j from 0 to xmas#MAX_BULB
		r := sinTable(j*$A0 - prog_step*$59*3)+$FFFF
		r += sinTable(j*$FF + prog_step*$40*3)+$FFFF
		r += sinTable(j*$8B + prog_step*$22*3)+$FFFF
		xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,make_fire_gradient(r>>13))
    prog_step++

PRI make_ice_gradient(x)
    case (x>>4)
        0:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(0,0,x)
        1:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(0,x,xmas#MAX_COLOR_VALUE)
        2:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(x,xmas#MAX_COLOR_VALUE,xmas#MAX_COLOR_VALUE)
    return 0

PRI program_10_step | j,r
    repeat j from 0 to xmas#MAX_BULB
		r := sinTable(j*$A0 - prog_step*$59*3)+$FFFF
		r += sinTable(j*$FF + prog_step*$40*3)+$FFFF
		r += sinTable(j*$8B + prog_step*$22*3)+$FFFF
		xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,make_ice_gradient(r>>13))
    prog_step++

PRI program_11_step | j,r
    repeat j from 0 to xmas#MAX_BULB
		r := sinTable(j*$A0 - prog_step*$59*3)+$FFFF
		r += sinTable(j*$FF + prog_step*$40*3)+$FFFF
		r += sinTable(j*$8B + prog_step*$22*3)+$FFFF
		xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,xmas.make_color_hue(r>>12))
    prog_step++

PRI make_xmas_gradient(x)
    case (x>>3)
        0:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(xmas#MAX_COLOR_VALUE-x,0,0)
        1:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(xmas#MAX_COLOR_VALUE,x*2,x*2)
        2:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(xmas#MAX_COLOR_VALUE-x*2,xmas#MAX_COLOR_VALUE,xmas#MAX_COLOR_VALUE-x*2)
        3:  x &= xmas#MAX_COLOR_VALUE
            return xmas.make_color_rgb(0,xmas#MAX_COLOR_VALUE-x,0)
    return 0

PRI program_12_step | j,r
    repeat j from 0 to xmas#MAX_BULB
		r := sinTable(j*$A0 - prog_step*$59*3)+$FFFF
		r += sinTable(j*$FF + prog_step*$40*3)+$FFFF
		r += sinTable(j*$8B + prog_step*$22*3)+$FFFF
		r += sinTable(j*$56 - prog_step*$30*3)+$FFFF
		xmas.set_bulb(j,xmas#DEFAULT_INTENSITY,make_xmas_gradient(r>>14))
    prog_step++

PRI sinTable(angle) ' input is $0000-$1FFF, output is 17-bit signed
  return (word[((angle * ((not(not(angle & $800))) | 1)) | constant($E000 >> 1)) << 1] * ((not(not(angle & $1000))) | 1))

PUB set_program(prog)
    current_program := prog
    prog_step := 0
	settings.setByte(CURRENT_PROGRAM_KEY,prog)

PUB toggle_active
	if active
		active~
	else
		active~~
    'active := ~active

PUB set_active(x)
    active := x        

PUB set_solid_color(x)
    solid_color := x
    settings.setLong(SOLID_COLOR_KEY,x)
    
VAR
  long solid_color

VAR
  long on_alarm_time 
  long off_alarm_time 

pub set_time_of_day(hours,minutes,seconds)
    subsys.setRTC(subsys.RTC/constant(60*60*24)*constant(60*60*24)+(hours*60*60+minutes*60+seconds))

pub get_current_hour
    return subsys.RTC/constant(60*60)//24

pub get_current_minute
    return subsys.RTC/60//60

pub get_current_second
    return subsys.RTC//60
    
pub set_on_alarm_time_of_day(hours,minutes)
    settings.setByte(ON_ALARM_HOUR,hours)
    settings.setByte(ON_ALARM_MIN,minutes)

pub set_off_alarm_time_of_day(hours,minutes,seconds)
    settings.setByte(OFF_ALARM_HOUR,hours)
    settings.setByte(OFF_ALARM_MIN,minutes)

pub get_next_on_alarm_time : retval
    retval := settings.getByte(ON_ALARM_HOUR)*constant(60*60)+settings.getByte(ON_ALARM_MIN)*60
    retval += subsys.RTC/constant(60*60*24)*constant(60*60*24)
    if subsys.RTC > retval
        retval += constant(60*60*24)

pub get_next_off_alarm_time : retval
    retval := settings.getByte(OFF_ALARM_HOUR)*constant(60*60)+settings.getByte(OFF_ALARM_MIN)*60
    retval += subsys.RTC/constant(60*60*24)*constant(60*60*24)
    if subsys.RTC > retval
        retval += constant(60*60*24)

pub get_on_off_status
    return get_next_on_alarm_time > get_next_off_alarm_time
