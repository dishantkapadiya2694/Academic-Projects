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
            <td><code>valueIterationAgents.py</code></td>
            <td>A value iteration agent for solving known MDPs.</td>
          </tr>
          <tr>
            <td><code>qlearningAgents.py</code></td>
            <td>Q-learning agents for Gridworld, Crawler and Pacman.</td>
          </tr>
          <tr>
            <td><code>analysis.py</code></td>
            <td>A file to put your answers to questions given in the project.</td>
          </tr>
          <tr>
            <td colspan="2"><b>Files you should read but NOT edit:</b></td>
          </tr>
          <tr>
            <td><code>mdp.py</a></code></td>
            <td>Defines methods on general MDPs.</td>
          </tr>
          <tr>
            <td><code>learningAgents.py</code></td>
            <td>Defines the base classes <code>ValueEstimationAgent</code> and <code>QLearningAgent</code>, which your agents will extend.</td>
          </tr>
          <tr>
            <td><code>util.py</code></td>
            <td>Utilities, including <code>util.Counter</code>, which is particularly useful for Q-learners.</td>
          </tr>
          <tr>
            <td><code>gridworld.py</code></td>
            <td>The Gridworld implementation.</td>
          </tr>
          <tr>
            <td><code>featureExtractors.py</code></td>
            <td>Classes for extracting features on (state,action) pairs. Used for the approximate Q-learning agent (in qlearningAgents.py).</td>
          </tr>
          <tr>
            <td colspan="2"><b>Files you can ignore:</b></td>
          </tr>
          <tr>
            <td><code>environment.py</a></code></td>
            <td>Abstract class for general reinforcement learning environments. Used by <code>gridworld.py</code>.</td>
          </tr>
          <tr>
            <td><code>graphicsGridworldDisplay.py</code></td>
            <td>Gridworld graphical display.</td>
          </tr>
          <tr>
            <td><code>graphicsUtils.py</code></td>
            <td>Graphics utilities.</td>
          </tr>
          <tr>
            <td><code>textGridworldDisplay.py</code></td>
            <td>Plug-in for the Gridworld text interface.</td>
          </tr>
          <tr>
            <td><code>crawler.py</code></td>
            <td>The crawler code and test harness. You will run this but not edit it.</td>
          </tr>
          <tr>
            <td><code>graphicsCrawlerDisplay.py</code></td>
            <td>GUI for the crawler robot.</td>
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
            <td><code>reinforcementTestClasses.py</code></td>
            <td>Project 3 specific autograding test classes</td>
          </tr>
        </tbody>
      </table>
      
###To run pacman and play the game, use following command:

```python
python pacman.py
```
#TASKS:
###1. Value Iteration
Write a value iteration agent in ```ValueIterationAgent```, which has been partially specified for you in ```valueIterationAgents.py```. Your value iteration agent is an offline planner, not a reinforcement learning agent, and so the relevant training option is the number of iterations of value iteration it should run (option -i) in its initial planning phase. ```ValueIterationAgent``` takes an MDP on construction and runs value iteration for the specified number of iterations before the constructor returns.

```python
python gridworld.py -a value -i 100 -k 10
python gridworld.py -a value -i 5
```
###2. Bridge Crossing Analysis
```BridgeGrid``` is a grid world map with the a low-reward terminal state and a high-reward terminal state separated by a narrow "bridge", on either side of which is a chasm of high negative reward. The agent starts near the low-reward state. With the default discount of 0.9 and the default noise of 0.2, the optimal policy does not cross the bridge. Change only ONE of the discount and noise parameters so that the optimal policy causes the agent to attempt to cross the bridge. Put your answer in question2() of ```analysis.py```. (Noise refers to how often an agent ends up in an unintended successor state when they perform an action.) The default corresponds to:

```python
python gridworld.py -a value -i 100 -g BridgeGrid --discount 0.9 --noise 0.2
```
###3. Policies
In this question, you will choose settings of the discount, noise, and living reward parameters for this MDP to produce optimal policies of several different types. Your setting of the parameter values for each part should have the property that, if your agent followed its optimal policy without being subject to any noise, it would exhibit the given behavior. If a particular behavior is not achieved for any setting of the parameters, assert that the policy is impossible by returning the string 'NOT POSSIBLE'.

Here are the optimal policy types you should attempt to produce:

1. Prefer the close exit (+1), risking the cliff (-10)
2. Prefer the close exit (+1), but avoiding the cliff (-10)
3. Prefer the distant exit (+10), risking the cliff (-10)
4. Prefer the distant exit (+10), avoiding the cliff (-10)
5. Avoid both exits and the cliff (so an episode should never terminate)

###4. Q-Learning
You will now write a Q-learning agent, which does very little on construction, but instead learns by trial and error from interactions with the environment through its update(```state```, ```action```, ```nextState```, ```reward```) method. A stub of a Q-learner is specified in ```QLearningAgent``` in ```qlearningAgents.py```, and you can select it with the option ```'-a q'```. For this question, you must implement the update, ```computeValueFromQValues```, ```getQValue```, and ```computeActionFromQValues``` methods.

```python
python gridworld.py -a q -k 5 -m
```
###5. Epsilon Greedy
Complete your Q-learning agent by implementing epsilon-greedy action selection in getAction, meaning it chooses random actions an epsilon fraction of the time, and follows its current best Q-values otherwise. Note that choosing a random action may result in choosing the best action - that is, you should not choose a random sub-optimal action, but rather any random legal action.

To execute, use one of the following commands.

```python
python gridworld.py -a q -k 100
```

With no additional code, you should now be able to run a Q-learning crawler robot:

```python
python crawler.py
```
###6. Bridge Crossing Revisited
First, train a completely random Q-learner with the default learning rate on the noiseless BridgeGrid for 50 episodes and observe whether it finds the optimal policy.

```python
python gridworld.py -a q -k 50 -n 0 -g BridgeGrid -e 1
```
Now try the same experiment with an epsilon of 0. Is there an epsilon and a learning rate for which it is highly likely (greater than 99%) that the optimal policy will be learned after 50 iterations? ```question6()``` in ```analysis.py``` should return EITHER a 2-item tuple of ```(epsilon, learning rate)``` OR the string '```NOT POSSIBLE```' if there is none. Epsilon is controlled by ```-e```, learning rate by ```-l```.

###7. Approximate Q-learning I
Time to play some Pacman! Pacman will play games in two phases. In the first phase, *training*, Pacman will begin to learn about the values of positions and actions. Because it takes a very long time to learn accurate Q-values even for tiny grids, Pacman's training games run in quiet mode by default, with no GUI (or console) display. Once Pacman's training is complete, he will enter testing mode. When *testing*, Pacman's `self.epsilon` and `self.alpha` will be set to 0.0, effectively stopping Q-learning and disabling exploration, in order to allow Pacman to exploit his learned policy. Test games are shown in the GUI by default. Without any code changes you should be able to run Q-learning Pacman for very tiny grids as follows:

```python
python pacman.py -p PacmanQAgent -x 2000 -n 2010 -l smallGrid 
```

Note that `PacmanQAgent` is already defined for you in terms of the `QLearningAgent` you've already written. `PacmanQAgent` is only different in that it has default learning parameters that are more effective for the Pacman problem `(epsilon=0.05, alpha=0.2, gamma=0.8)`. You will receive full credit for this question if the command above works without exceptions and your agent wins at least 80% of the time. The autograder will run 100 test games after the 2000 training games.


###8. Approximate Q-Learning II
Implement an approximate Q-learning agent that learns weights for features of states, where many states might share the same features. Write your implementation in `ApproximateQAgent` class in `qlearningAgents.py`, which is a subclass of `PacmanQAgent`.

```python
python pacman.py -p ApproximateQAgent -x 2000 -n 2010 -l smallGrid
python pacman.py -p ApproximateQAgent -a extractor=SimpleExtractor -x 50 -n 60 -l mediumGrid
python pacman.py -p ApproximateQAgent -a extractor=SimpleExtractor -x 50 -n 60 -l mediumClassic
```

#ADDITIONAL DETAILS
For more information regarding this assignment, visit this [webpage](http://www.ccs.neu.edu/home/rplatt/cs5100_2015/pa3/pa3.html)