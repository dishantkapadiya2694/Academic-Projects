# CS 5010: Problem Set 02

The goal of this problem set is to help you design functions that deal with finite data.

## 1. (Tiny Text Editor): editor.rkt

Do exercise 84 (the function "edit") from Part I, section 5.10 of HtDP/2e.
You are to write a file called editor.rkt that provides the following functions:

make-editor   
editor-pre  
editor-post   
editor?    
edit  
Note: for our purposes, we will consider KeyEvent to be a scalar data type, which can be decomposed using the Cases strategy. KeyEvent and key=? are defined in the 2htdp/universe module. Look in the Help Desk for details. You will need to require 2htdp/universe to import key=?. The same holds for the regular-expression problem below.

Remember that we will be doing automated testing of your solution. So be sure that your solution is in the right place (set02/editor.rkt in your private cs5010f15/pdp-YOURUSERNAME repository), and that it provides all the functions listed above. To see if your file is in the right place, insert the following line somewhere near the top of your file:

## 2. Finite State Machine: fsm.rkt

This exercise is based on Exercise 111 in HtDP/2e. As in that exercise, you are to design a set of functions that illustrate the workings of a finite-state machine for accepting strings that exactly match the regular expression
(a | b)* c (a | b)* d (e | f)*
. So cd, abcd, abcbdef and aacbadf all match, but abc, abdbcef, and acbded do not.
The legal inputs to the machine are precisely the strings "a", "b", "c", "d", "e", and "f". Any other inputs violate the machine's contract, and its behavior on those inputs is unspecified.

For this problem, you will NOT create any displays.

First, perform an information analysis and design the data representation for the states of your machine. You may wish to write down a state-transition diagram (like the ones here) to illustrate the meaning of your state. Keep your diagram as simple as possible. You should submit your state-transition diagram either as ascii art in your solution file, or as a jpg or pdf (called "fsm.jpg" or "fsm.pdf"), created in your favorite graphics program.

Then design the following functions and provide them in a file named fsm.rkt

     initial-state : Number -> State  
     GIVEN: a number  
     RETURNS: a representation of the initial state of your machine.  The given number is ignored.  

     next-state : State MachineInput -> State  
     GIVEN: a state of the machine and a machine input  
     RETURNS: the state that should follow the given input.  

     accepting-state? : State -> Boolean  
     GIVEN: a state of the machine  
     RETURNS: true iff the given state is a final (accepting) state  

     error-state? : State -> Boolean  
     GIVEN: a state of the machine  
     RETURNS: true iff there is no path (empty or non-empty) from the given  
     state to an accepting state
     You will need to provide data definitions for State and for MachineInput. Be sure to write an interpretation for each state. There is no need to write an interpretation for MachineInput, since the problem is already phrased in terms of strings.

As before, remember that we will be doing automated testing of your solution. So be sure that your solution is in the right place (set02/fsm.rkt in your private cs5010f15/pdp-YOURUSERNAME repository), and that it provides all the functions listed above. To see if your file is in the right place, insert the following line somewhere near the top of your file:

## 3. Coffee Machine(Inventory Management System): coffee-machine.rkt  
A coffee machine has two items: coffee and hot chocolate. Coffee is $1.50, but hot chocolate is $0.60. A customer may put any sequence of coins into the machine, and then select an item. If the customer has deposited enough money into the machine, and the machine is not out of the selected item, then the machine will dispense the requested item. If the machine is out of the selected item, the machine will flash "Out of Item". The customer may also press "change", in which case the machine will return any unspent money that the customer has put in during the current transaction. If none of these apply, the machine does nothing.
For example, the customer may put three 25-cent pieces into the machine. If he then selects the hot chocolate, the machine will dispense a cup of hot chocolate. If he tries to select the coffee instead, nothing will happen. If the customer then presses "change", the machine will return the extra $0.15 that he is owed. The customer may request "change" at any time, whether or not he has ordered anything, and we assume that the machine can always make the required amount of change.

The machine has a container, called the bank, that contains all the money it has kept from customers' purchases. The customer's money is added to the bank only after he or she has successfully made a purchase.

The possible inputs from the customer are given by the following data definition:

     A CustomerInput is one of  
     -- a PosInt          interp: insert the specified amount of money, in cents  
     -- "coffee"          interp: request a coffee  
     -- "hot chocolate"   interp: request a hot chocolate  
     -- "change"          interp: return all the unspent money that the  
                                  customer has inserted  

     A MachineOutput is one of  
     -- "coffee"         interp: machine dispenses a cup of coffee  
     -- "hot chocolate"  interp: machine dispenses a cup of hot chocolate  
     -- "Out of Item"    interp: machine displays "Out of Item"  
     -- a PosInt         interp: machine releases the specified amount of
                                 money, in cents  
     -- "Nothing"        interp: the machine does nothing  
You are to write a file called coffee-machine.rkt that provides the following functions:  

     initial-machine : NonNegInt NonNegInt -> MachineState  
     GIVEN: a number of cups of coffee and of hot chocolate  
     RETURNS: the state of a machine loaded with the given number of cups  
              of coffee and of hot chocolate, with an empty bank.  

     machine-next-state : MachineState CustomerInput -> MachineState  
     GIVEN: a machine state and a customer input  
     RETURNS: the state of the machine that should follow the customer's  
     input  

     machine-output : MachineState CustomerInput -> MachineOutput  
     GIVEN: a machine state and a customer input  
     RETURNS: a MachineOutput that describes the machine's response to the  
     customer input  

     machine-remaining-coffee : MachineState -> NonNegInt  
     GIVEN: a machine state  
     RETURNS: the number of cups of coffee left in the machine  

     machine-remaining-chocolate : MachineState -> NonNegInt  
     GIVEN: a machine state  
     RETURNS: the number of cups of hot chocolate left in the machine  

     machine-bank : MachineState -> NonNegInt  
     GIVEN: a machine state  
     RETURNS: the amount of money in the machine's bank, in cents  

As before, remember that we will be doing automated testing of your solution. So be sure that your solution is in the right place, and that it provides all the functions listed above. You can use check-location to check whether your file is in the right place.  

## 4. Probe: probe.rkt
Your space probe to Pluto has just landed. Here's the situation:

1. The probe is a circle, 40cm in diameter.

2. At every step, the probe can move forward some number of steps, or it can rotate 90 degrees either right or left. The 
probe moves by taking steps of exactly 1 cm.

3. The Plutonians, anticipating the arrival of our probe, have constructed a trap in the form of a square with side 347 cm, centered on the origin.

4. The probe has landed right in the trap! It has landed with its center at the origin, facing north (up).

5. We will use graphics-style coordinates instead of standard mathematical coordinates. That is, when the probe moves north, its y-coordinate DECREASES. So the northernmost wall of the trap is at y = -173.5 .

6. The probe can also sense when it has run into a wall. If any move of the probe would cause the probe to run into the wall of the trap, then the probe will move forward until another 1cm step would take it past the wall, and then stop. For example, if the probe proceeded north from its initial position, it could move only 153 cm, since that puts its northernmost edge at (0, -173), and another 1cm step would send it crashing into the wall.

7. You are to write a file called probe.rkt that provides the following functions:


	     initial-probe probe-at: Integer Integer -> Probe  
	     GIVEN: an x-coordinate and a y-coordinate  
	     WHERE: these coordinates leave the robot entirely inside the trap  
	     RETURNS: a probe with its center at those coordinates, facing north.  
	     EXAMPLE: a set of coordinates that put the probe in contact with the  
	     wall is not consistent with the contract.  Note that this means that  
	     the behavior of probe-at in this situation is unspecified; you don't  
	     need to check for this.  
	
	     probe-turned-left : Probe -> Probe  
	     probe-turned-right : Probe -> Probe  
	     GIVEN: a probe  
	     RETURNS: a probe like the original, but turned 90 degrees either left  
	     or right.  
	
	     probe-forward : Probe PosInt -> Probe  
	     GIVEN: a probe and a distance  
	     RETURNS: a probe like the given one, but moved forward by the  
	     specified distance.  If moving forward the specified distance would  
	     cause the probe to hit any wall of the trap, then the probe should   
	     move as far as it can inside the trap, and then stop.  
	
	     probe-north? : Probe -> Boolean  
	     probe-south? : Probe -> Boolean  
	     probe-east? : Probe -> Boolean  
	     probe-west? : Probe -> Boolean  
	     GIVEN: a probe  
	     ANSWERS: whether the probe is facing in the specified direction.  

Note: When the specification groups functions as we have done here, you need only write down the purpose statement once (as we have done here). If your design strategy is the same for all the functions, then you only have to write that down once. Of course your examples must cover all the functions.  

As before, remember that we will be doing automated testing of your solution. Yeah, yeah, you know the drill now.

Last modified: Wed Oct 7 15:24:08 Eastern Daylight Time 2015