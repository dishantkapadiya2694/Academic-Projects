Foundations of Artificial Intelligence (FoAI) Project Proposal:
------------------------------------------------------------------
“Diagonal Sudoku” is a game played on 9X9 grid. Game is initialized with some cells 
already filled in and the player must fill remaining cells such that, every row, every
column, both diagonals and every 3X3 sub-grid contains all the numbers from 1 to 9. 

Solution: We can use the concept of Constraint Satisfaction Problem(CSP) to solve the
game of Sudoku. This can be done by implementing algorithms like backtracking, 
forward checking, arc consistency. Performance of CSP can be improvised using minimum 
remaining value Heuristics and least containing value heuristics.