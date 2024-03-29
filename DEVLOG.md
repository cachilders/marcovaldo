## Dev Notes
**(2/17/2024)**
Swinging through to apply a lil bugfix (sequence selection by ring) and write up some documentation. Moving this log to its own file for posterity since we're over the main drive.

**(2/11/2024)**
Wrapped initial development today with a bunch of param actions and some bugfixes. A little over a month, all-in. Still needs docs, but [I made a demo video yesterday](https://youtu.be/riol61rH76A?si=Ci7GM_jfeH_xNC8z), and it explains the functionality pretty well. I went a little crazy on this one, and for all of the code cleanup and extension I'd like to do, I think it's no rush. I want to focus on another canvas for a minute. I'll pick up whatever bugs come by. We'll see what happens.

**(2/9/2024)**
Basically feature complete, if buggy. Now it's all params, bugfixes, and nice to haves.

**(2/9/2024)**
Settling in for the home stretch. Everything left is going to be a journey of discovery. Found many sloppy errors last night, and I suspect it's time to wrap things up. I let the scope get way out of hand on this project, and as cool as proud as I am of where it's gone, the biggest lesson of Marcovaldo (the app) is to strive for simplicity.
- ~~Cleaning up the console UI to make things shiny~~
- ~~A few more animations and the machinery for rotating them~~
- ~~File params (we'll see)~~
- ~~Clear and randomize~~
- ~~Bugfixes (slow tempo bug in path, etc)~~
- ~~Cleanup sequencer and maybe rework some state (file ops above)~~
- --- Initial Release Line ---
- ~~Random at Sequencer level~~
- ADSR Enhancements (Additional seq or step page)
- Nota Bene integration with voice per sequencer 
- cosleepers (next project) integration

**(2/4/2024)**
Oof. Spent too many hours on this, yesterday, and my brain went to mush when it came time to revisit the input and feedback model for the arc. Think I've cleaned up the relationships of things for the better, but there are some edges yet to be teased out. Hoisted some behavior, pushed other bits down. Feel like I want to move some of the new global context stuff (for switching between viewer and editor modes) someplace more contained, but I'll come to that once everything is on the page.

I'm at the editing functionality now, and I can't stall anymore on it. Should be the last complex piece, and from there its cleanup and polish.

**(1/31/2024)**
This was a big one. Figured out a workable pattern for communicating events across the domains after getting the radiation plan to emit waves fluidly in sequence, and now individual sequences can be toggled on and off. I'm also set up with the tools to start knocking out the remaining functionality a piece at a time. I'm not out of the woods, but this felt like cresting the hill. I can see how to reach the end, and i can already see a ton of the ideas actually working.

**(1/28/2024)**
Puzzled over a bug in offsets I noticed on the first run with a 256 this morning and had to grapple with the cognitive complexity of the spript, to date. There's a dual reminder here that a design is worth its weight in gold and that I should have coffee before programming.

**(1/26/2024)**
Thought up some new scope creep (keyboard navigation) while fixing the bugs of the last scope creep (relief plan), and that got me thinking about the problems of software design as an expression of artistic impulse. Also having doubts about the radiation plan now that I've seen it on a 128 beside the relief plan. The two are too busy side-by side. I think I want to reduce the expression of the waves to pulses in the radiant plan and only show the full waves in the relief. Going to play with variable brightness before I make a call. Also going to wait until the emitters represent actual sequencer pulse and I set them up to decay.

**(1/23/2024)**
Hooked up a 64 to test the page scaling. Works great, but need to have a conditional brightness adjustment for non-varibright grids.

**(1/23/2024)**
So much of this program is a free writing exercise that the bigger traps are the moments in which I attempt to pause and revise and insert some rigor into the structure. I had a page system that mostly worked, but the state was out of sync on page flip gestures—all gestures, I guess, but the clear gesture on the pane was unimpacted. Anyway, it was an underlying bug in my reasoning. Woke up with the piece I was missing the night before to address. The end result is much better, but the overall sketch will not get completed if I don't stop and think about the next revision I'll insist on before painting a section of floor.

**(1/20/2024)**
Muddled through implementation of the path follower plan. It was a long week and my attention was split, but it's nice to see this piece in action. The big win in this latest week's worth of effort, aside from the actual goal of completing this view, was clocking the updates and keeping the grid refresh frequent. It was inevitable we'd get there, but now that it's in place it's easier to see the musical outcomes this whole exercise is meant to support.

**(1/12/2024)**
Structure materialized in the shower for a method of laying out the app as a series of disconected 64 pixel layers, each with a purpose and representing an overlapping reality. Built out a few of the low level prototypes and got the arc and grid into an interactive state with most of the abstraction I wanted. Still need Panes.

Created the cat plan and cat symbol so I wouldn't forget, but didn't get far.

**(1/11/2024)**
It was more of a struggle to nail the radians to rings ratio than I'd prefer to admit.

**(1/8/2024)**
Back in November of 2020 I feverishly captured this idea on the whiteboard on my bedroom door (generally used for chores and family notes). 

![sketch of idea](./assets/images/whiteboard.jpeg)

I forgot about it until finishing a passable draft of [Forge](https://github.com/cachilders/forge/tree/main) and contemplating what to work on next. As a musical instrument idea, Marcovaldo is opaque and nearly incomprehensible to me, now; so it'll be an exercise in imagination and projection into a past personal state to get any semblance of the idea on the whiteboard into reality.

I have some thoughts, though.
- A sequencer programmed in four stages with a arc (something like step, fundamental, substep, harmonic)
- Something something sofcut
- Spatial exploration with a grid
- Non-player cats wandering around, scratching on harmonics and slew

IDK. There's a lot I don't know how to accomplish, so this will be a journey of discovery and hopefully some scope reduction.

Props to [the GOAT](https://en.wikipedia.org/wiki/Italo_Calvino) for [the inspiration](https://en.wikipedia.org/wiki/Marcovaldo)—[past](https://github.com/cachilders/qfwfq), present and future.
