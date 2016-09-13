# CS 5010: Problem Set 8

                 


The goal of this problem set is to give you practice using everything that you've learned this semester.

Remember that you must follow the design recipe, and write invariants (as WHERE clauses) whenever an argument represents context information. We expect that your data definitions, interpretations, and invariants will be sufficient to explain the meaning of every quantity in your program. You will be judged on the adequacy of these deliverables.

For each function that you write using general recursion, you must deliver:

- A STRATEGY line describing briefly what you are recurring on. If the the value returned by the recursive call is not the final answer, describe briefly what you do with the result of the recursive call to obtain the final answer. Remember: the strategy is a tweet-sized description of how your function works.
- A HALTING MEASURE, specifying the quantity that you are proposing as a halting measure.
- A TERMINATION ARGUMENT, giving an informal proof that your proposed halting measure is always a non-negative integer and that it decreases at every recursive call.
- If your function fails to terminate for some inputs, explain which inputs those are. (I don't believe there are any such functions on this problem set.)
- The example files contain numerous examples of the first three of these deliverables.

You will be judged on the correctness of your halting measures and termination arguments.

If you really need to do so, it is ok to write two mutually-recursive functions using general recursion. If you do this, you need make sure that your halting measure decreases on EVERY recursive call to the function, even if that call comes via the other function.

As before, if your function does not fulfill its purpose for all combinations of arguments that satisfy the contract, then you must write an invariant that documents what additional assumptions your function makes about its arguments.

Note: not everything on this problem set requires the use of invariants or the use of general recursion. Part of your task is to figure out when you need these things and when you do not. Remember, it is the purpose statement that determines whether or not you need to state an invariant.

### 1. pretty.rkt

Consider the following definition of expressions:

   	(define-struct sum-exp (exprs))
   	(define-struct diff-exp (exprs))

   	;; An Expr is one of
   	;; -- Integer
   	;; -- (make-sum-exp NELOExpr)
   	;; -- (make-diff-exp NELOExpr)
   	;; Interpretation: a sum-exp represents a sum and a diff-exp
   	;; represents a difference calculation. 

   	;; A LOExpr is one of
   	;; -- empty
   	;; -- (cons Expr LOExpr)

   	;; A NELOExpr is a non-empty LOExpr.
Your task is to write a program called pretty.rkt that contains a pretty-printer for Exprs. More precisely, you are to provide a function

 	expr-to-strings : Expr NonNegInt -> ListOfString
   	GIVEN: An expression and a width
   	RETURNS: A representation of the expression as a sequence of lines, with
	each line represented as a string of length not greater than the width.
   	The rules for rendering the expression as a list of lines are as follows:

The expression should be rendered on a single line if it fits within the specified width.  
Otherwise, render the subexpressions in a stacked fashion, that is, like

	(+ expr1  
		expr2  
		...  
		exprN)
and similarly for difference expressions.  
All subexpressions must fit within the space allotted minus the space for surrounding parentheses, if any. Apply the rendering algorithm recursively if needed.
Note: there should be no spaces preceding a right parenthesis.
The algorithm may determine that the given expression cannot fit within the allotted space. In this case, the algorithm should raise an appropriate error, using the function error.
In addition to expr-to-strings, you must provide make-sum-exp, sum-exp-exprs, make-diff-exp, and diff-exp-exprs.

In addition, you must turn in a file containing the call graph for your program. This file must show which functions call which, so we (and you) can see the overall structure of your program and find all the recursive calls. You may turn this in as a text file, pdf, jpg, or Racket file. Call your file pretty-call-tree with an appropriate suffix, and bring a paper copy to your codewalk.

In order to help you debug your program, we have provided in extras.rkt the function:

     display-strings! : ListOfString -> Void
     GIVEN: a list of strings
     EFFECT: displays the strings on separate lines
     RETURNS: no value

     Example:  
     > (display-strings! (list "xyz" "abc")) 
     xyz
     abc
     > 
     Be sure to download a fresh copy of extras.rkt containing this function.

Here is a sample interaction:

     > hw-example-1
     (make-sum-exp (list 22 333 44))
     > (expr-to-strings hw-example-1 15)
     (list "(+ 22 333 44)")
     > (expr-to-strings hw-example-1 10)
     (list "(+ 22" "   333" "   44)")
     > 
     > (define (display-expr expr n)
       (display-strings! (expr-to-strings expr n)))
     > (display-expr hw-example-1 25)
     (+ 22 333 44)
     > (display-expr hw-example-1 10)
     (+ 22
        333
        44)
     > (display-expr hw-example-1 5)
     not enough room
     > hw-example-2
     (make-sum-exp
      (list
       (make-diff-exp (list 22 3333 44))
       (make-diff-exp
        (list
         (make-sum-exp (list 66 67 68))
         (make-diff-exp (list 42 43))))
       (make-diff-exp (list 77 88))))
     > (display-expr hw-example-2 100)
     (+ (- 22 3333 44) (- (+ 66 67 68) (- 42 43)) (- 77 88))
     > (display-expr hw-example-2 50)
     (+ (- 22 3333 44)
        (- (+ 66 67 68) (- 42 43))
        (- 77 88))
     > (display-expr hw-example-2 20)
     (+ (- 22 3333 44)
        (- (+ 66 67 68)
           (- 42 43))
        (- 77 88))
     > (display-expr hw-example-2 15)
     (+ (- 22
           3333
           44)
        (- (+ 66
              67
              68)
           (- 42
              43))
        (- 77 88))
     > 
Here are some hints on this problem.

- display-strings! is useful for you to use in debugging your program, but we will be testing the lists of strings produced by expr-to-strngs. There is at most one list of strings that satisfies the requirements of the problem.
- This problem requires careful analysis of the context. For example, when your program gets to the (- 42 43) in (expr-to-strings hw-example-2 20), what does it need to know about the context in order to produce this line? If there is more than one thing that it needs to know, you can introduce multiple context variables to keep track of them.
- In the book, you will find two different data definitions for non-empty lists. One of these treats the first element of the list specially; the other treats the last one specially. I needed both in my solution; I suspect you will also need both. Be sure to write down both definitions and both templates, and be sure to indicate which one you are using when you use structural decomposition on a non-empty list.


### 2. robot.rkt

Imagine an infinite chessboard. The chessboard extends infinitely in all directions. You can think of the positions on the board as pairs of integers.
On the chessboard, we have a robot and some blocks. The robot occupies a single square on the chessboard, as does each of the blocks. The robot can move any number of squares in any diagonal direction, but it can never move to or through a square occupied by a block. In this way, its behavior is like that of a bishop in chess.

You are to write a file called robot.rkt that provides the following functions:

     path : Position Position ListOfPosition -> MaybePlan
     GIVEN:
     1. the starting position of the robot,
     2. the target position that robot is supposed to reach
     3. A list of the blocks on the board
     RETURNS: a plan that, when executed, will take the robot from
     the starting position to the target position without passing over any
     of the blocks, or false if no such sequence of moves exists.

     eval-plan : Position ListOfPosition Plan ->  MaybePosition
     GIVEN:
     1. the starting position of the robot,
     2. A list of the blocks on the board
     3. A plan for the robot's motion
     RETURNS:
     The position of the robot at the end of executing the plan, or false
     if  the plan sends the robot to or  through any block.
     This API uses the following data definitions:
     ;; A Position is a (list Integer Integer)
     ;; (list x y) represents the position (x,y).
     ;; Note: this is not to be confused with the built-in data type Posn.

     ;; A Move is a (list Direction PosInt)
     ;; Interp: a move of the specified number of steps in the indicated
     ;; direction. 

     ;; A Direction is one of
     ;; -- "ne"
     ;; -- "se"
     ;; -- "sw"
     ;; -- "nw"

     ;; A Plan is a ListOfMove
     ;; WHERE: the list does not contain two consecutive moves in the same
     ;; direction.
     ;; INTERP: the moves are to be executed from the first in the list to
     ;; the last in the list.
Here are some examples that your program should be able to handle easily. Why do the first two fail, but the other two succeed? I haven't shown solutions to the second two, because there are many correct answers. Your tests should accept any correct answer.

	 (define wall1
	   '((0 3)(2 3)(4 3)
	     (0 5)     (4 5)
	     (0 7)(2 7)(4 7)))
	
	 (define two-walls
	   '((0 3)(4 3)
	     (0 5)(4 5)
	     (0 7)(4 7)
	     (0 9)(4 9)
	     (0 11)(4 11)))
	
	 (path (list 2 5) (list 2 6) empty)
	 (path (list 2 5) (list 4 9) wall1)
	 (path (list 2 5) (list 4 9) (rest wall1))
	 (path (list -3 6) (list 7 6) two-walls)

Your tests should also check that if you run eval-plan on the output of path, you get to the desired position.

For this problem also, you must turn in a file containing the call graph for your program. This file must show which functions call which, so we (and you) can see the overall structure of your program and find all the recursive calls. You may turn this in as a text file, pdf, jpg, or Racket file. Call your file robot-call-tree with an appropriate suffix, and bring a paper copy to your codewalk.

