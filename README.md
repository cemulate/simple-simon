Simple Simon
==============

Simple Simon game implemented in Verilog. 

The required signals that must be connected to the top-level module (`main`) are:

* `clk`, `reset` -- self explanatory

* `b1`, `b2`, `b3`, `b4` -- Game buttons

* `led1`, `led2`, `led3`, `led4` -- Lights for each game button

Recommended signals:

* `speaker_out1`, `speaker_out2` -- For sound support. These assume the actual voltage from the pinout will operate the speakers, so the speaker signals use PWM manually

The following features are supported:

* Full sound support (with different pitches for each button)

* Game increases in speed with each successful round

* Progress sound plays every 10 successful rounds

* Upon victory, the unit will play Oklahoma State University's Alma Mater