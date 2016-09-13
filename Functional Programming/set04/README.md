# CS 5010: Problem Set 04: Working with Lists

The goal of this problem set is to help you design functions that deal with lists, and with the Iterative Design Recipe

## 1. screensaver-3.rkt 
Your boss has decided that your screensaver needs to show more stuff on the screen. In the new screensaver, there will be a list of rectangles.
Initially, there are no rectangle. Hitting the "n" key adds a new rectangle, at the center of the canvas, at rest (velocity is 0).

When a rectangle is selected, the arrow keys increase the velocity of the rectangle in the specified direction (up, down, left, or right). Each push of the arrow key increases the velocity by 2 pixels/tick. When the rectangle is deselected, the rectangle resumes its motion with the new velocity.

Here's a demo (0:53): [Click Here For Video Demo](http://www.ccs.neu.edu/course/cs5010/Problem%20Sets/Videos/screensaver-3-take-3.mp4)  

You are to deliver a file named screensaver-3.rkt that provides all the functions of screensaver-2.rkt, plus the following:

                 ;; world-rects : WorldState -> ListOfRectangle  
                 ;; RETURNS: the specified attribute of the WorldState  
                 ;; NOTE: this replaces world-rect1 and world-rect2.  
                 ;; NOTE: if these are part of the world struct, you don't need to  
                 ;; write any deliverables for these functions.  

                 ;; rect-after-key-event : Rectangle KeyEvent -> Rectangle  
                 ;; RETURNS: the state of the rectangle that should follow the given  
                 ;; rectangle after the given key event  

## 2. screensaver-4.rkt 
Your boss is so pleased with your work that he assigns you yet another feature. Screensaver 4.0 adds the following feature:
When a rectangle is selected, the "d" key drops a pen down. When the pen is down, the rectangle records on the screen a dot marking its center at each tick. The dot is displayed as a solid black circle of radius 1.

When a rectangle is selected, the "u" key lifts the pen up. When the pen is up, the rectangle does not leave a track on the screen.

No marks are made during a drag.

Here's a demo: [Click Here For Video Demo] (http://www.ccs.neu.edu/course/cs5010/Problem%20Sets/Videos/screensaver-4.mp4)


## 3. class-lists.rkt

Professor Felleisen and Professor Shivers each keep their class lists on slips of paper, one student on each slip. Professor Felleisen keeps his list on slips of yellow paper. Professor Shivers keeps his list on slips of blue paper.
Unfortunately, both professors are sloppy record-keepers. Sometimes they have more than one slip for the same student. Sometimes they record the student names first-name first; sometimes they record the names last-name first.

One day, Professor Felleisen was walking up the stairs in WVH, talking to one of his graduate students. At the same time, Professor Shivers was walking down the stairs, all the time talking to one of his graduate students. They collided, and dropped all the slips containing their class lists on the stairs, where they got all mixed up.

Your job is to clean up this mess. Deliver a file named class-lists.rkt that provides the following functions:

                 ;; felleisen-roster : ListOfSlip -> ListOfSlip  
                 ;; GIVEN: a list of slips  
                 ;; RETURNS: a list of slips containing all the students in Professor  
                 ;; Felleisen's class, without duplication.  

                 ;; shivers-roster: ListOfSlip -> ListOfSlip  
                 ;; GIVEN: a list of slips  
                 ;; RETURNS: a list of slips containing all the students in Professor  
                 ;; Shivers' class, without duplication.  
                 ;; Here is the beginning of the data definition for ListOfSlip:  

                 (define-struct slip (color name1 name2))  
                 A Slip is a (make-slip Color String String)  

                 A Color is one of  
                 -- "yellow"  
                 -- "blue"  
As mentioned before, the professors are confused about first names and last names, so (make-slip "yellow" "Wang" "Xi") and (make-slip "yellow" "Xi" "Wang") represent the same student in Professor Felleisen's class. The phrase "without duplication" in the purpose statements above means that your function should return a list in which this student is represented only once.

Be sure to finish the data definitions I've started above, and to provide make-slip, slip-color, slip-name1 and slip-name2.