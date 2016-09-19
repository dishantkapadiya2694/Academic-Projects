***
#OUTLINE
1. [Brief Description](#brief-description)
2. [Tasks](#tasks)
3. [Additional Details](#additional-details)

***

#BRIEF DESCRIPTION

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
            <td><code>bustersAgents.py</code></td>
            <td>Agents for playing the Ghostbusters variant of Pacman.</td>
          </tr>
          <tr>
            <td><code>inference.py</code></td>
            <td>Code for tracking ghosts over time using their sounds.</td>
          </tr>
          <tr>
            <td colspan="2"><b>Files you will not edit:</b></td>
          </tr>
          <tr>
            <td><code>busters.py</code></td>
            <td>The main entry to Ghostbusters (replacing Pacman.py)</td>
          </tr>
          <tr>
            <td><code>bustersGhostAgents.py</code></td>
            <td>New ghost agents for Ghostbusters</td>
          </tr>
          <tr>
            <td><code>distanceCalculator.py</code></td>
            <td>Computes maze distances</td>
          </tr>
          <tr>
            <td><code>game.py</code></td>
            <td>Inner workings and helper classes for Pacman</td>
          </tr>
          <tr>
            <td><code>ghostAgents.py</code></td>
            <td>Agents to control ghosts</td>
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
            <td><code>keyboardAgents.py</code></td>
            <td>Keyboard interfaces to control Pacman</td>
          </tr>
          <tr>
            <td><code>layout.py</code></td>
            <td>Code for reading layout files and storing their contents</td>
          </tr>
          <tr>
            <td><code>util.py</code></td>
            <td>Utility functions</td>
          </tr>
        </tbody>
   </table>
      
###To run pacman and play the game, use following command:

```python
python pacman.py
```
#TASKS:
###1. Exact Inference Observation
In this question, you will update the observe method in `ExactInference` class of `inference.py` to correctly update the agent's belief distribution over ghost positions given an observation from Pacman's sensors. A correct implementation should also handle one special case: when a ghost is eaten, you should place that ghost in its prison cell, as described in the comments of observe.

###2. Exact Inference with Time Elapse
In this question, you will implement the `elapseTime` method in `ExactInference`. Your agent has access to the action distribution for any `GhostAgent`. In order to test your `elapseTime` implementation separately from your observe implementation in the previous question, this question will not make use of your `observe` implementation.

###3. Exact Inference Full Test
Implement the `chooseAction` method in `GreedyBustersAgent` in `bustersAgents.py`. Your agent should first find the most likely position of each remaining (uncaptured) ghost, then choose an action that minimizes the distance to the closest ghost. If correctly implemented, your agent should win the game in q3/3-`gameScoreTest` with a score greater than 700 at least 8 out of 10 times. Note: the `autograder` will also check the correctness of your inference directly, but the outcome of games is a reasonable sanity check.

###4. Approximate Inference Observation
Approximate inference is very trendy among ghost hunters this season. Next, you will implement a particle filtering algorithm for tracking a single ghost.

Implement the functions `initializeUniformly`, `getBeliefDistribution`, and observe for the `ParticleFilter` class in `inference.py`. A correct implementation should also handle two special cases. 

1. When all your particles receive zero weight based on the evidence, you should resample all particles from the prior to recover. 
2. When a ghost is eaten, you should update all particles to place that ghost in its prison cell, as described in the comments of observe. 

When complete, you should be able to track ghosts nearly as effectively as with exact inference.
###5. Approximate Inference with Time Elapse
Implement the `elapseTime` function for the `ParticleFilter` class in `inference.py`. When complete, you should be able to track ghosts nearly as effectively as with exact inference.

Note that in this question, we will test both the `elapseTime` function in isolation, as well as the full implementation of the particle filter combining `elapseTime` and `observe`.

###6. Joint Particle Filter Observation
Complete the `initializeParticles`, `getBeliefDistribution`, and `observeState` method in `JointParticleFilter` to weight and resample the whole list of particles based on new evidence. As before, a correct implementation should also handle two special cases. 

1. When all your particles receive zero weight based on the evidence, you should resample all particles from the prior to recover. 
2. When a ghost is eaten, you should update all particles to place that ghost in its prison cell, as described in the comments of observeState.

###7. Joint Particle Filter with Elapse Time
Complete the `elapseTime` method in `JointParticleFilter` in `inference.py` to resample each particle correctly for the Bayes net. In particular, each ghost should draw a new position conditioned on the positions of all the ghosts at the previous time step. The comments in the method provide instructions for support functions to help with sampling and creating the correct distribution.

#ADDITIONAL DETAILS
For more information regarding this assignment, visit this [webpage](http://www.ccs.neu.edu/home/rplatt/cs5100_2015/pa3/pa3.html)