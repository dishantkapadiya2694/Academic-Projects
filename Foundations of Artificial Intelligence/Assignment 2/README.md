***
#OUTLINE
1. [Brief Description](#brief-description)
2. [Tasks](#tasks)
3. [Additional Details](#additional-details)

***

#BRIEF DESCRIPTION

In this project, you will design agents for the classic version of Pacman, including ghosts. Along the way, you will implement both minimax and expectimax search and try your hand at evaluation function design.

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
          <td><code>multiAgents.py</code></td>
          <td>Where all of your multi-agent search agents will reside.</td>
        </tr>
        <tr>
          <td><code>pacman.py</code></td>
          <td>The main file that runs Pacman games. This file also describes a Pacman <code>GameState</code> type, which you will use extensively in this project</td>
        </tr>
        <tr>
          <td><code>game.py</code></td>
          <td>The logic behind how the Pacman world works. This file describes several supporting types like AgentState, Agent, Direction, and Grid.</td>
        </tr>
        <tr>
          <td><code>util.py</code></td>
          <td>Useful data structures for implementing search algorithms.</td>
        </tr>
        <tr>
          <td colspan="2"><b>Files you can ignore:</b></td>
        </tr>
        <tr>
          <td><code>graphicsDisplay.py</code></td>
          <td>Graphics for Pacman</td>
        </tr>
        <tr>
          <td><code>graphicsUtils.py</code></td>
          <td>Support for Pacman graphics</td>
        </tr>
        <tr>
          <td><code>textDisplay.py</code></td>
          <td>ASCII graphics for Pacman</td>
        </tr>
        <tr>
          <td><code>ghostAgents.py</code></td>
          <td>Agents to control ghosts</td>
        </tr>
        <tr>
          <td><code>keyboardAgents.py</code></td>
          <td>Keyboard interfaces to control Pacman</td>
        </tr>
        <tr>
          <td><code>layout.py</code></td>
          <td>Code for reading layout files and storing their contents</td>
        </tr>
        <tr>
          <td><code>autograder.py</code></td>
          <td>Project autograder</td>
        </tr>
        <tr>
          <td><code>testParser.py</code></td>
          <td>Parses autograder test and solution files</td>
        </tr>
        <tr>
          <td><code>testClasses.py</code></td>
          <td>General autograding test classes</td>
        </tr>
        <tr>
          <td><code>test_cases/</code></td>
          <td>Directory containing the test cases for each question</td>
        </tr>
        <tr>
          <td><code>multiagentTestClasses.py</code></td>
          <td>Project 2 specific autograding test classes</td>
        </tr>
      </tbody>
    </table>
###To run pacman and play the game, use following command:

```python
python pacman.py
```

##Multi-Agent Pacman

First, play a game of classic Pacman:

```python
python pacman.py
```
Now, run the provided ReflexAgent in multiAgents.py:

```python
python pacman.py -p ReflexAgent
```
Note that it plays quite poorly even on simple layouts:

```python
python pacman.py -p ReflexAgent -l testClassic
```
Inspect its code (in multiAgents.py) and make sure you understand what it's doing.
#TASKS:
###1. Reflex Agent
Improve the ReflexAgent in ```multiAgents.py``` to play respectably. The provided reflex agent code provides some helpful examples of methods that query the GameState for information. A capable reflex agent will have to consider both food locations and ghost locations to perform well. Your agent should easily and reliably clear the ```testClassic``` layout:

```python
python pacman.py -p ReflexAgent -l testClassic
```
Try out your reflex agent on the default mediumClassic layout with one ghost or two (and animation off to speed up the display):

```python
python pacman.py --frameTime 0 -p ReflexAgent -k 1
python pacman.py --frameTime 0 -p ReflexAgent -k 2
```

###2. Minimax
Now you will write an adversarial search agent in the provided MinimaxAgent class stub in ```multiAgents.py```. Your minimax agent should work with any number of ghosts, so you'll have to write an algorithm that is slightly more general than what you've previously seen in lecture. In particular, your minimax tree will have multiple min layers (one for each ghost) for every max layer.

Your code should also expand the game tree to an arbitrary depth. Score the leaves of your minimax tree with the supplied ```self.evaluationFunction```, which defaults to ```scoreEvaluationFunction```. MinimaxAgent extends ```MultiAgentSearchAgent```, which gives access to ```self.depth``` and ```self.evaluationFunction```. Make sure your minimax code makes reference to these two variables where appropriate as these variables are populated in response to command line options.

###3. Alpha-Beta Pruning
Make a new agent that uses alpha-beta pruning to more efficiently explore the minimax tree, in ```AlphaBetaAgent```. Again, your algorithm will be slightly more general than the pseudocode from lecture, so part of the challenge is to extend the alpha-beta pruning logic appropriately to multiple minimizer agents.

```python
python pacman.py -p AlphaBetaAgent -a depth=3 -l smallClassic
```
###4. Expectimax
Minimax and alpha-beta are great, but they both assume that you are playing against an adversary who makes optimal decisions. As anyone who has ever won tic-tac-toe can tell you, this is not always the case. In this question you will implement the ExpectimaxAgent, which is useful for modeling probabilistic behavior of agents who may make suboptimal choices.

```python
python pacman.py -p ExpectimaxAgent -l minimaxClassic -a depth=3
```
You should now observe a more cavalier approach in close quarters with ghosts. In particular, if Pacman perceives that he could be trapped but might escape to grab a few more pieces of food, he'll at least try. Investigate the results of these two scenarios:

```python
python pacman.py -p AlphaBetaAgent -l trappedClassic -a depth=3 -q -n 10
python pacman.py -p ExpectimaxAgent -l trappedClassic -a depth=3 -q -n 10
```
###5. Evaluation Function
Write a better evaluation function for pacman in the provided function betterEvaluationFunction. The evaluation function should evaluate states, rather than actions like your reflex agent evaluation function did. You may use any tools at your disposal for evaluation, including your search code from the last project. With depth 2 search, your evaluation function should clear the smallClassic layout with one random ghost more than half the time and still run at a reasonable rate (to get full credit, Pacman should be averaging around 1000 points when he's winning).




#ADDITIONAL DETAILS
For more information regarding this assignment, visit this [webpage](http://www.ccs.neu.edu/home/rplatt/cs5100_2015/pa2/homework2.html)