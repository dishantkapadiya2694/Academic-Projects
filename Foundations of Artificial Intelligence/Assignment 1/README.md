#BRIEF DESCRIPTION
***

In this project, your Pacman agent will find paths through his maze world, both to reach a particular location and to collect food efficiently. You will build general search algorithms and apply them to Pacman scenarios.

As in Project 0, this project includes an autograder for you to grade your answers on your machine. This can be run with the command:

```python
python autograder.py
```

See the autograder tutorial in Project 0 for more information about using the autograder.

The code for this project consists of several Python files, some of which you will need to read and understand in order to complete the assignment, and some of which you can ignore. You can download all the code and supporting files as a zip archive.

<table class="intro" border="0" cellpadding="10">
        <tbody>
          <tr>
            <td colspan="2"><b>Files you'll edit:</b></td>
          </tr>
          <tr>
            <td><code>
					search.py</code></td>
            <td><text>Where all of your search algorithms will reside.</text></td>
          </tr>
          <tr>
            <td><code>
					searchAgents.py</code></td>
            <td>Where all of your search-based agents will reside.</td>
          </tr>
          <tr>
            <td colspan="2"><b>Files you might want to look at:</b></td>
          </tr>
          <tr>
            <td><code>
				pacman.py</code></td>
            <td>The main file that runs Pacman games. This file describes a Pacman GameState type, which you use in this project.</td>
          </tr>
          <tr>
            <td><code>
					game.py</code></td>
            <td>The logic behind how the Pacman world works. This file describes several supporting types like AgentState, Agent, Direction, and Grid.</td>
          </tr>
          <tr>
            <td><code>
					util.py</code></td>
            <td>Useful data structures for implementing search algorithms.</td>
          </tr>
          <tr>
            <td colspan="2"><b>Supporting files you can ignore:</b></td>
          </tr>
          <tr>
            <td><code>
					graphicsDisplay.py</code></td>
            <td>Graphics for Pacman</td>
          </tr>
          <tr>
            <td><code>
					graphicsUtils.py</code></td>
            <td>Support for Pacman graphics</td>
          </tr>
          <tr>
            <td><code>
				textDisplay.py</code></td>
            <td>ASCII graphics for Pacman</td>
          </tr>
          <tr>
            <td><code>
					ghostAgents.py</code></td>
            <td>Agents to control ghosts</td>
          </tr>
          <tr>
            <td><code>
				keyboardAgents.py</code></td>
            <td>Keyboard interfaces to control Pacman</td>
          </tr>
          <tr>
            <td><code>
					layout.py</code></td>
            <td>Code for reading layout files and storing their contents</td>
          </tr>
          <tr>
            <td><code>
				autograder.py</code></td>
            <td>Project autograder</td>
          </tr>
          <tr>
            <td><code>
					testParser.py</code></td>
            <td>Parses autograder test and solution files</td>
          </tr>
          <tr>
            <td><code>
				testClasses.py</code></td>
            <td>General autograding test classes</td>
          </tr>
          <tr>
            <td><code>test_cases/</code></td>
            <td>Directory containing the test cases for each question</td>
          </tr>
          <tr>
            <td><code>searchTestClasses.py</code></td>
            <td>Project 1 specific autograding test classes</td>
          </tr>
        </tbody>
      </table>
###To run pacman and play the game, use following command:

```python
python pacman.py
```
#TASKS:
***
###1. Finding a Fixed Food Dot using Depth First Search
Implement DFS on Pacman and execute it find the food pallets using the same algorithm.<br>
To execute, use one of the following commands.

```python
python pacman.py -l tinyMaze -p SearchAgent
python pacman.py -l mediumMaze -p SearchAgent
python pacman.py -l bigMaze -z .5 -p SearchAgent
```
###2. Finding a Fixed Food Dot using Bredth First Search
Implement BFS on Pacman and execute it find the food pallets using the same algorithm.<br>
To execute, use one of the following commands.

```python
python pacman.py -l tinyMaze -p SearchAgent -a fn = bfs
python pacman.py -l mediumMaze -p SearchAgent -a fn = bfs
python pacman.py -l bigMaze -z .5 -p SearchAgent -a fn = bfs
```
###3. Varying the Cost Function
Implement Uniform Cost Function on Pacman and execute it find the food pallets using the same algorithm.<br>
To execute, use one of the following commands.

```python
python pacman.py -l tinyMaze -p SearchAgent -a fn = ucs
python pacman.py -l mediumMaze -p SearchAgent -a fn = ucs
python pacman.py -l bigMaze -z .5 -p SearchAgent -a fn = ucs
```
###4. A* Search
A* takes a heuristic function as an argument. Heuristics take two arguments: a state in the search problem (the main argument), and the problem itself (for reference information). Implement Uniform Cost Function on Pacman and execute it find the food pallets using the same algorithm.<br>
To execute, use one of the following commands.

```python
python pacman.py -l tinyMaze -p SearchAgent -a fn = astar, heuristic=manhattanHeuristic
python pacman.py -l mediumMaze -p SearchAgent -a fn = astar, heuristic=manhattanHeuristic
python pacman.py -l bigMaze -z .5 -p SearchAgent -a fn = astar, heuristic=manhattanHeuristic
```
###5. Finding All the Corners
In corner mazes, there are four dots, one in each corner. Our new search problem is to find the shortest path through the maze that touches all four corners (whether the maze actually has food there or not). Note that for some mazes like tinyCorners, the shortest path does not always go to the closest food first! Hint: the shortest path through tinyCorners takes 28 steps.
To execute, use one of the following commands.

```python
python pacman.py -l tinyCorners -p SearchAgent -a fn=bfs,prob=CornersProblem
python pacman.py -l mediumCorners -p SearchAgent -a fn=bfs,prob=CornersProblem
```
###6. Corners Problem: Heuristic
Implement a non-trivial, consistent heuristic for the CornersProblem in cornersHeuristic.

```python
python pacman.py -l mediumCorners -p AStarCornersAgent -z 0.5
```

Note: ```AStarCornersAgent``` is a shortcut for
```python
-p SearchAgent -a fn=aStarSearch,prob=CornersProblem,heuristic=cornersHeuristic.
```
###7. Eating All The Dots
A solution is defined to be a path that collects all of the food in the Pacman world. For the present project, solutions do not take into account any ghosts or power pellets; solutions only depend on the placement of walls, regular food and Pacman. (Of course ghosts can ruin the execution of a solution! We'll get to that in the next project.) If you have written your general search methods correctly, A* with a null heuristic (equivalent to uniform-cost search) should quickly find an optimal solution to testSearch with no code change on your part (total cost of 7).

```python
python pacman.py -l testSearch -p AStarFoodSearchAgent
```
###8. Suboptimal Search
Sometimes, even with A* and a good heuristic, finding the optimal path through all the dots is hard. In these cases, we'd still like to find a reasonably good path, quickly. In this section, you'll write an agent that always greedily eats the closest dot. ClosestDotSearchAgent is implemented for you in searchAgents.py, but it's missing a key function that finds a path to the closest dot.

Implement the function findPathToClosestDot in searchAgents.py. Our agent solves this maze (suboptimally!) in under a second with a path cost of 350:

```python
python pacman.py -l bigSearch -p ClosestDotSearchAgent -z .5
```


```{r, engine='bash', count_lines}
wc -l en_US.twitter.txt 
```