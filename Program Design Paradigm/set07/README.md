# CS 5010: Problem Set 7

The goal of this problem set is to give you practice using context arguments and invariants.

### 1. outlines.rkt

The first few problems on this problem set have to do with outlines. Consider a text in the form of an outline, for example:

     1 The first section  
     1.1 A subsection with no subsections  
     1.2 Another subsection  
     1.2.1 This is a subsection of 1.2  
     1.2.2 This is another subsection of 1.2  
     1.3 The last subsection of 1  
     2 Another section  
     2.1 More stuff  
     2.2 Still more stuff  

The point of an outline is to impose a tree structure on a document, so it is natural to represent an outline as a tree. For example, the outline above might be represented as:

	(list  
     (make-section "The first section"  
       (list  
         (make-section "A subsection with no subsections" empty)  
         (make-section "Another subsection"  
           (list  
             (make-section "This is a subsection of 1.2" empty)  
             (make-section "This is another subsection of 1.2" empty)))  
         (make-section "The last subsection of 1" empty)))  
     (make-section "Another section"  
       (list  
         (make-section "More stuff" empty)  
         (make-section "Still more stuff" empty))))  

using the data definition  

     ;; An Outline is a ListOfSection  
     ;; A Section is a (make-section String ListOfSection)  
     ;; INTERP: (make-section str secs) is a section where  
     ;; str is the header text of the section  
     ;; secs is the list of subsections of the section  

We'll call this the tree representation

Another representation of an outline could be as a list with one element per section or subsection. Each element of the list would consist of two members: the section number, represented as a list of natural numbers, and a string. This would look more like the text representation. We call this the flat representation.

In the flat representation, the outline above would be represented as  

    (list  
     (make-line (list 1) "The first section")  
     (make-line (list 1 1) "A subsection with no subsections")  
     (make-line (list 1 2) "Another subsection")  
     (make-line (list 1 2 1) "This is a subsection of 1.2")  
     (make-line (list 1 2 2) "This is another subsection of 1.2")  
     (make-line (list 1 3) "The last subsection of 1")  
     (make-line (list 2) "Another section")  
     (make-line (list 2 1) "More stuff")  
     (make-line (list 2 2) "Still more stuff"))  
Write a data definition for FlatRep. Be sure that your data definition defines exactly the legal flat representations. Be sure to include whatever invariants are applicable. Remember the rules about outlines that you learned in school: section numbers must be in order, and you are not allowed to skip any section numbers.
Then, design and provide the following function:  

     legal-flat-rep? : ListOfLine -> Boolean  
     GIVEN: a list of lines, like the one above  
     RETURNS: true iff it is a legal flat representation of an outline.  

Design and provide the following function:  

     tree-rep-to-flat-rep : Outline -> FlatRep  
     GIVEN: the representation of an outline as a list of Sections  
     RETURNS: the flat representation of the outline  

Deliver questions 1 and 2 as a file named "outlines.rkt."  

### 2. rainfall.rkt
Design a program that consumes a list of numbers representing daily rainfall amounts . The list may contain the number -999 indicating the end of the data of interest. Produce the average of the non-negative values in the list up to the first -999 (if it shows up). There may be negative numbers other than -999 in the list. Deliver your program by providing a function called rainfall in a file named rainfall.rkt.

