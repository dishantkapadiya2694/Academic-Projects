# CS 5010: Problem Set 05: Working with Higher-Order Functions

The goal of this problem set is to help you design functions using higher-order functions like map, filter, foldr, etc.

## 1. The absent-minded professors, part 2  
Reimplement the last problem from last week's problem set (class-lists.rkt), but using HOFs wherever possible and appropriate. Be sure to provide make-slip, slip-color, slip-name1 and slip-name2, which I forgot to specify in PS04. Use the filename class-lists.rkt, as you did before.

## 2. screensaver-5.rkt 
Rewrite screensaver-4 to use higher-order functions whenever possible instead of using recursions down a list. Provide the same functions you did for screensaver-4. Name your file screensaver-5.rkt .

## 3. rosters.rkt

The Registrar has heard about your excellent work with the absent-minded professors and so he asks you to solve the following problem:
You are given a list of (student, class) pairs. Deliver a file called rosters.rkt that produces the class roster for each class that has at least one student enrolled. Here are more detailed specifications:

     A SetOfX is a list of X's without duplication.  Two SetOfX's are  
     considered equal if they have the same members.  

     Example: (list (list 1 2) (list 2 1)) is NOT a SetOfSetOfNumber,  
     because (list 1 2) and (list 2 1) represent the same set of numbers.   

     An Enrollment is a (make-enrollment Student Class)  
     (make-enrollment s c) represents the assertion that student s is  
     enrolled in class c.  

     A ClassRoster is a (make-roster Class SetOfStudent)  
     (make-roster c ss) represents that the students in class c are exactly  
     the students in set ss.  

Student is unspecified, but you may assume that students may be  
compared for equality with equal?  

Class is unspecified, but you may assume that classes may be  
compared for equality with equal?  

Two ClassRosters are equal if they have the same class and equal  
sets of students.  

You are to provide the following functions:  

     make-enrollment  
     enrollment-student  
     enrollment-class  
     make-roster  
     roster-classname  
     roster-students  

     roster=? : ClassRoster ClassRoster -> Boolean  
     RETURNS: true iff the two arguments represent the same roster  

     rosterset=? : SetOfClassRoster SetOfClassRoster -> Boolean  
     RETURNS: true iff the two arguments represent the same set of rosters  
  
     enrollments-to-rosters: SetOfEnrollment -> SetOfClassRoster             
     GIVEN: a set of enrollments  
     RETURNS: the set of class rosters for the given enrollments  

EXAMPLE:  

    (enrollments-to-rosters  
     (list (make-enrollment "John" "PDP")  
           (make-enrollment "Kathryn" "Networks")  
           (make-enrollment "Feng" "PDP")  
           (make-enrollment "Amy" "PDP")  
           (make-enrollment "Amy" "Networks")))  
     =>  
      (list  
        (make-roster "PDP" (list "John" "Feng" "Amy"))  
        (make-roster "Networks" (list "Kathryn" "Amy")))  

In the output, the classes may be in any order, and the students in  
each class may be in any order.  
As elsewhere in this problem set, use HOFs whenever possible and appropriate.  

For your tests, you may use any data type for Student and Class. However, your code should not depend on your choice of data type; that is, it should work for any definition of Student and Class (so long as each is testable using equal?, as specified above).

Be sure that your tests accept any correct answer, not just the one that your function happens to produce. (Hint: don't use check-equal?; instead use check with an appropriate equality test.)
