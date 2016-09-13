# CS 5010: Problem Set 6

The goal of this problem set is to help you design and use multiply-recursive and mutually-recursive data definitions, and to give you practice using the list abstractions and HOFC.

In this problem, you will design and implement a system for a graphical interface for trees. Your system will allow you to create and manipulate trees on a canvas. Create a file called "trees.rkt" with the following properties:

1. The canvas starts empty. Its size is 500 pixels wide by 400 pixels high.

2. Nodes of the tree are rendered as green outline circles of a fixed radius. The default value for the radius is 10, but your system should allow you to change the radius for the next run by changing a single line of your code.

3. When the tree is displayed, there should be a straight blue line from the center of a node to the center of each of its sons.

4. You can select a node by clicking on it, as in previous problems. Selected nodes are displayed as green solid circles. Clicking on a node selects only the node, not any of its subtrees. If the mouse is clicked in the overlap of two or more nodes, all the nodes are selected, even if one node is a son or descendant of the other.

5. Dragging a selected node causes the entire tree rooted at that node to be dragged. The relative positions of all the nodes in the subtree should stay the same. It is ok if this action causes some nodes to be moved off the edge of the canvas; if the node is moved again so that they are now back on the canvas, they should reappear in the proper place.

6. Hitting "t" at any time creates a new root node in the center of the top of the canvas. The root appears tangent to the top of the canvas and initially has no sons.

7. Hitting "n" while a node is selected adds a new son, whose center has an x-coordinate that is 3 radii to the right of the center of the currently rightmost son, and a y-coordinate that is 3 radii down from the center of the parent. The first son of a node should appear 3 radii down and directly beneath the node.

8. Hitting "d" while a node is selected deletes the node and its whole subtree.

9. Hitting "l" at any time (whether a node is selected or not) deletes every node whose center is in the left half of the canvas. (If a node is deleted, all of its children are also deleted, as with "d")

Here's a demo (about 6 minutes). [Click here] (http://www.ccs.neu.edu/course/cs5010/Problem%20Sets/tree-editor-2.mp4)

Your solution should provide the following functions: 

     initial-world : Any -> World  
     GIVEN: any value  
     RETURNS: an initial world.  The given value is ignored.  

     run :  Any -> World  
     GIVEN: any value  
     EFFECT: runs a copy of an initial world  
     RETURNS: the final state of the world.  The given value is ignored.  

     world-after-mouse-event : World Integer Integer MouseEvent -> World  
     GIVEN: a World, a location, and a MouseEvent  
     RETURNS: the state of the world as it should be following the given mouse event at that location.  

     world-after-key-event : World KeyEvent -> World  
     GIVEN: a World and a key event  
     RETURNS: the state of the world as it should be following the given key event  
 
     world-to-trees : World -> ListOfTree  
     GIVEN: a World  
     RETURNS: a list of all the trees in the given world.  

     tree-to-root : Tree -> Node  
     GIVEN: a tree  
     RETURNS: the node at the root of the tree  
     EXAMPLE: Consider the tree represented as follows:  

                      A  
                      |  
            +---+-----+-----+  
            |   |     |     |  
            B   C     D     E  
                |           |  
              +---+      +-----+  
              |   |      |     |  
              F   G      H     I  

If tree-to-root is given the subtree rooted at C, it should return the  
data structure associated with node C. This data structure may or may  
not include data associated with rest of the tree, depending on  
whether you have chosen to represent nodes differently from trees.  


     tree-to-sons : Tree -> ListOfTree  
     GIVEN: a tree  
     RETURNS: the data associated with the immediate subtrees of the given  
     tree.  
     EXAMPLE: In the situation above, if tree-to-sons is given the subtree  
     rooted at C, it should return a list consisting of the subtree rooted  
     at F and the subtree rooted at G.  

[Note how these examples are expressed.  They are not just tests, but  
are constructed to illuminate possible ambiguities or  
misunderstandings in the purpose statement.  This is what a good  
example does.]  


     node-to-center : Node -> Posn  
     RETURNS: the center of the given node as it is to be displayed on the  
     scene.  
Note: this function returns a Posn (an ISL builtin).  This is for the  
convenience of the testing framework, and you may or may not wish to  
represent the center of the node in this way.  

     node-to-selected? : Node -> Boolean  
     RETURNS: true iff the given node is selected.  

Hints:   

- Follow the design recipe!! If you write good data definitions, and follow the templates, you will be led to a good solution. If you stray from the templates, you will create a mess. If you are following your templates and still creating a mess, try an alternate path. For example, if you are doing structural decomposition on one data type, followed immediately by structural decomposition on another data type, try doing them in the other order.
- The specifications talk about Tree and Node, because some students may wish to implement these as different data definitions. If you wish to represent Trees and Nodes as the SAME data structure, that is also permissible.
- The built-in abstraction functions, like map, foldr, and filter, are your friends. Use them wherever it is feasible to do so. As before, you may want to write your functions using explicit recursions, and then rewrite them using the abstractions and higher-order function combination. You will be penalized for recursions in your code that "obviously" could have been replaced by HOFC.
- Most likely you will want to use scene+line from the image library rather than add-line, since the latter changes the dimensions of the image in surprising ways.


