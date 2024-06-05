MIT License

Copyright (c) 2024 csBlueChip

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---------------
 Polite Notice
---------------

This project is released under the MIT licence (free as in "free").

That said. This IS a community project, so issues, feedback, pull requests, etc.
are welcomed and encouraged.

------------------
 Revision History
------------------

v1.1 - initial release
v1.1 - interim patch for lubuntu coredump handling
v1.2 - fixed (unintended) backdoor in cerberus()
       added `make server`

---------------
 WSL : WARNING
---------------

On the 24/Oct/2016 stakemura reported to Microsoft that WSL does not produce
coredump files. This has never been fixed. [June 2024]
	https://github.com/microsoft/WSL/issues/1262

As such, you cannot debug ANY program post-segfault under WSL !

This set of challenges can definitely be solved without coredumps,
but it is (debatably) going to be a LOT harder.

I can only suggest you use VirtualBox or VMWare, and install Debian.

-------
 Setup
-------

Before you start, you MAY need to run: `make setup`
to ensure you have an appropriate selection of hacker tools installed
...You only ever need to do this once

---------------
 The Challenge
---------------

1. Run the program with : `make run`

2. Select a game mode: {Easy, Medium, Hard}
   ...this only effects later challenges

2. Type in the (nick)name of a friend

3. Repeat until you have summoned all the friends you need to make a:
   complete, well groomed cerberean dog, wearing a Sherrif badge;
   with a deputy who is also wearing their Shiny Badge :)

BUT: To count as a win. You MUST be able to call each friend using:
	# the unmodified original code,
	# as executed by the unmodified original Makefile [qv. Instruction #1].

-------
 Notes
-------

The friends are presented in order of perceived difficulty,
but you may collect them in any order you wish.

You may use any tools you desire to work out how to solve the puzzles.
And feel free two write scripts in any language of your choosing
to help you speed run it.

If you want a benchmark: My helper scripts are written in BASh 
and I can speed run all 11 challenges in ~46 seconds.
...There is a LOT of room for improvement!

Tested on:-
	# Debian 12 x64 VM running inside VMWare v17

----------------
 The Challenges
----------------

The overflow challenges will be:

(1) Who can find the most hilarious way to follow the instructions, 
    while (deliberately) completely missing the point 
    ...PoC||GTFO ...You MUST get all 11 Flags/Friends

(2) Who can get the most Flags/Friends before the July 2024 meet.

(3) The first person collect all 11 Flags/Friends

---------------
 Additional...
---------------

Aside of a couple of Hilarious (deliberately missing the point) solution
proposals (sans PoC), I've had a couple of serious questions about what is
and isn't "allowed" with regard to inputting data...

I guess at some level: "This is hacking; a win is a win!"
However, if you want to know what my original intent was:-

The reason challenges 1..5 get gradually more difficult is because the data
required becomes more and more difficult to produce with a keyboard - and the
aim is to push you slowly toward looking at what happens between you pressing
down on a keycap, and data being written to the program's input buffer.
  [So that you are in a strong position to perform the later attacks, and
   (possibly) even against an environment you don't fully control]

The whole puzzle can be solved using only a keyboard - in fact my autopwn
method literally simulates (as close as possible) someone pressing keys.
  [cos I had to do this hundreds of times to make sure everything was stable
   prior to release]

One question was to change the `make run` line (in a redacted manner);
and another was to wrap the `make run` up inside another program.

Consider this:
The more complicated version of this code would be *exactly* the same attack
vectors, just sprinkled throughout many thousands of lines of code, and the 
program will already be running (on the target machine) when you get there.
...and instead of getting "you have a friend" printed on the screen,
you get to perform an action such as "open a port in a firewall", or
"bypass a password mechanism", etc.

If you cannot or do not beat the challenges against an already-running copy of
`overflow`, you will still learn a **LOT** about buffer overflow exploits by
getting all the flags.
...BUT, if you CAN attack `overflow` in a "realistic server-client
configuration", you will be in a much stronger position to affect this style of
attack in a real-life scenario.

So perhaps we could add another challenge: 
(4) Most number of flags, but the attack(s) will only work 
    if you can control the way the program is started.

If it helps, here is my "server" script:
#!/bin/bash
make clean
while true ; do
	printf "\n\n" ; printf "=%0.s" $(seq 1 70) ; printf "\n"
	make run
done

And, running in a separate session, here is my autopwn script:
#!/bin/bash
for i in $(seq 1 11) ; do
	./Call.sh $i
	echo -e "\n"
	sleep 1
done

`Call.sh` works out what needs to be typed for 'Friend $i' and types it.
