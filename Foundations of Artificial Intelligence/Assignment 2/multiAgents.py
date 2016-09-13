# multiAgents.py
# --------------
# Licensing Information:  You are free to use or extend these projects for 
# educational purposes provided that (1) you do not distribute or publish 
# solutions, (2) you retain this notice, and (3) you provide clear 
# attribution to UC Berkeley, including a link to 
# http://inst.eecs.berkeley.edu/~cs188/pacman/pacman.html
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero 
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and 
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


from util import manhattanDistance
from game import Directions
import random, util

from game import Agent

class ReflexAgent(Agent):
    """
      A reflex agent chooses an action at each choice point by examining
      its alternatives via a state evaluation function.

      The code below is provided as a guide.  You are welcome to change
      it in any way you see fit, so long as you don't touch our method
      headers.
    """


    def getAction(self, gameState):
        """
        You do not need to change this method, but you're welcome to.

        getAction chooses among the best options according to the evaluation function.

        Just like in the previous project, getAction takes a GameState and returns
        some Directions.X for some X in the set {North, South, West, East, Stop}
        """
        # Collect legal moves and successor states
        legalMoves = gameState.getLegalActions()
        # Choose one of the best actions
        scores = [self.evaluationFunction(gameState, action) for action in legalMoves]
        bestScore = max(scores)
        bestIndices = [index for index in range(len(scores)) if scores[index] == bestScore]
        chosenIndex = random.choice(bestIndices) # Pick randomly among the best

        "Add more of your code here if you want to"

        return legalMoves[chosenIndex]

    def evaluationFunction(self, currentGameState, action):
        """
        Design a better evaluation function here.

        The evaluation function takes in the current and proposed successor
        GameStates (pacman.py) and returns a number, where higher numbers are better.

        The code below extracts some useful information from the state, like the
        remaining food (newFood) and Pacman position after moving (newPos).
        newScaredTimes holds the number of moves that each ghost will remain
        scared because of Pacman having eaten a power pellet.

        Print out these variables to see what you're getting, then combine them
        to create a masterful evaluation function.
        """
        # Useful information you can extract from a GameState (pacman.py)
        successorGameState = currentGameState.generatePacmanSuccessor(action)
        newPos = successorGameState.getPacmanPosition()
        newFood = successorGameState.getFood()
        newGhostStates = successorGameState.getGhostStates()
        newScaredTimes = [ghostState.scaredTimer for ghostState in newGhostStates]


        "*** YOUR CODE HERE ***"
        ghostDistance = util.manhattanDistance(currentGameState.getGhostPosition(1), newPos)
        pref = successorGameState.getScore() + max(ghostDistance, 1)
        foodList = newFood.asList()
        posOfPowerPallets = currentGameState.getCapsules()
        foodList += posOfPowerPallets
        minDistToFood = 150
        for posOfFood in foodList:
            dist = util.manhattanDistance(posOfFood, newPos)
            if (dist < minDistToFood):
                minDistToFood = dist
        if (currentGameState.getNumFood() > successorGameState.getNumFood()):
            pref += 100
        if action == Directions.STOP:
            pref -= 10
        pref -= 3 * minDistToFood
        if successorGameState.getPacmanPosition() in posOfPowerPallets:
            pref += 150

        return pref

        #return successorGameState.getScore()

def scoreEvaluationFunction(currentGameState):
    """
      This default evaluation function just returns the score of the state.
      The score is the same one displayed in the Pacman GUI.

      This evaluation function is meant for use with adversarial search agents
      (not reflex agents).
    """
    return currentGameState.getScore()

class MultiAgentSearchAgent(Agent):
    """
      This class provides some common elements to all of your
      multi-agent searchers.  Any methods defined here will be available
      to the MinimaxPacmanAgent, AlphaBetaPacmanAgent & ExpectimaxPacmanAgent.

      You *do not* need to make any changes here, but you can if you want to
      add functionality to all your adversarial search agents.  Please do not
      remove anything, however.

      Note: this is an abstract class: one that should not be instantiated.  It's
      only partially specified, and designed to be extended.  Agent (game.py)
      is another abstract class.
    """

    def __init__(self, evalFn = 'scoreEvaluationFunction', depth = '2'):
        self.index = 0 # Pacman is always agent index 0
        self.evaluationFunction = util.lookup(evalFn, globals())
        self.depth = int(depth)

class MinimaxAgent(MultiAgentSearchAgent):
    """
      Your minimax agent (question 2)
    """

    def getAction(self, gameState):
        """
          Returns the minimax action from the current gameState using self.depth
          and self.evaluationFunction.

          Here are some method calls that might be useful when implementing minimax.

          gameState.getLegalActions(agentIndex):
            Returns a list of legal actions for an agent
            agentIndex=0 means Pacman, ghosts are >= 1

          gameState.generateSuccessor(agentIndex, action):
            Returns the successor game state after an agent takes an action

          gameState.getNumAgents():
            Returns the total number of agents in the game
        """
        "*** YOUR CODE HERE ***"
        def maxvalue(gameState, height, ghostcount):
            if (gameState.isWin() or gameState.isLose() or height == 0):
                #print "returning from maxvalue with:", self.evaluationFunction(gameState)
                return self.evaluationFunction(gameState)

            possibleMoves = gameState.getLegalActions(0)
            val = -float("inf")
            #print "outside loop of maxvalue"
            for move in possibleMoves:
                #print "entered loop of maxvalue"
                val = max(val, minvalue(gameState.generateSuccessor(0, move), height, ghostcount, 1))
                #print val
            #print "exited loop of maxvalue"
            return val

        def minvalue(gameState, height, ghostcount, agentindex):
            if (gameState.isWin() or gameState.isLose() or height == 0):
                return self.evaluationFunction(gameState)

            possibleMoves = gameState.getLegalActions(agentindex)
            val = float("inf")

            if agentindex == ghostcount:
                for move in possibleMoves:
                    val = min(val, maxvalue(gameState.generateSuccessor(agentindex, move), height - 1, ghostcount))
                    #print "minvalue->if->val:\t", val

            else:
                for move in possibleMoves:
                    val = min(val, minvalue(gameState.generateSuccessor(agentindex, move), height, ghostcount, agentindex + 1))
                    #print "minvalue->else->val:\t", val
            return val

        possibleMoves = gameState.getLegalActions(0)
        ghostCount = gameState.getNumAgents() - 1
        possibleScore = -float("inf")
        mostOptimalMove = Directions.STOP
        for move in possibleMoves:
            oldScore = possibleScore
            possibleScore = max(possibleScore, minvalue(gameState.generateSuccessor(0, move), self.depth, ghostCount, 1))
            #print "maximum is :", possibleScore
            if oldScore < possibleScore:
                #print "changing score to:", possibleScore
                mostOptimalMove = move
                #print mostOptimalMove
        return mostOptimalMove

        #util.raiseNotDefined()


class AlphaBetaAgent(MultiAgentSearchAgent):
    """
      Your minimax agent with alpha-beta pruning (question 3)
    """

    def getAction(self, gameState):
        """
          Returns the minimax action using self.depth and self.evaluationFunction
        """
        def maxvalue(gameState, height, ghostcount, alpha, beta):
            if (gameState.isWin() or gameState.isLose() or height == 0):
                #print "returning from maxvalue with:", self.evaluationFunction(gameState)
                return self.evaluationFunction(gameState)

            possibleMoves = gameState.getLegalActions(0)
            val = -float("inf")
            #print "outside loop of maxvalue"
            for move in possibleMoves:
                #print "entered loop of maxvalue"
                val = max(val, minvalue(gameState.generateSuccessor(0, move), height, ghostcount, 1, alpha, beta))
                if val > beta:
                    return val
                alpha = max(alpha, val)
                #print val
            #print "exited loop of maxvalue"
            return val

        def minvalue(gameState, height, ghostcount, agentindex, alpha, beta):
            if (gameState.isWin() or gameState.isLose() or height == 0):
                return self.evaluationFunction(gameState)

            possibleMoves = gameState.getLegalActions(agentindex)
            val = float("inf")

            if agentindex == ghostcount:
                for move in possibleMoves:
                    val = min(val, maxvalue(gameState.generateSuccessor(agentindex, move), height - 1, ghostcount, alpha, beta))
                    if val < alpha:
                        return val
                    beta = min(beta, val)
                    #print "minvalue->if->val:\t", val

            else:
                for move in possibleMoves:
                    val = min(val, minvalue(gameState.generateSuccessor(agentindex, move), height, ghostcount, agentindex + 1, alpha, beta))
                    if val < alpha:
                        return  val
                    beta = min(beta, val)
                    #print "minvalue->else->val:\t", val
            return val

        possibleMoves = gameState.getLegalActions(0)
        ghostCount = gameState.getNumAgents() - 1
        possibleScore = -float("inf")
        alpha = float("-inf")
        beta = float("inf")
        mostOptimalMove = Directions.STOP
        for move in possibleMoves:
            oldScore = possibleScore
            possibleScore = max(possibleScore, minvalue(gameState.generateSuccessor(0, move), self.depth, ghostCount, 1, alpha, beta))
            #print "maximum is :", possibleScore
            if oldScore < possibleScore:
                #print "changing score to:", possibleScore
                mostOptimalMove = move
                #print mostOptimalMove
            alpha = max(alpha, possibleScore)
        return mostOptimalMove
        util.raiseNotDefined()

class ExpectimaxAgent(MultiAgentSearchAgent):
    """
      Your expectimax agent (question 4)
    """

    def getAction(self, gameState):
        """
          Returns the expectimax action using self.depth and self.evaluationFunction

          All ghosts should be modeled as choosing uniformly at random from their
          legal moves.

          """
        "*** YOUR CODE HERE ***"
        def maxvalue(gameState, height, ghostcount):
            if (gameState.isWin() or gameState.isLose() or height == 0):
                #print "returning from maxvalue with:", self.evaluationFunction(gameState)
                return self.evaluationFunction(gameState)

            possibleMoves = gameState.getLegalActions(0)
            val = -float("inf")
            #print "outside loop of maxvalue"
            for move in possibleMoves:
                #print "entered loop of maxvalue"
                val = max(val, averagevalue(gameState.generateSuccessor(0, move), height, ghostcount, 1))
                #print val
            #print "exited loop of maxvalue"
            return val

        def averagevalue(gameState, height, ghostcount, agentindex):
            if (gameState.isWin() or gameState.isLose() or height == 0):
                return self.evaluationFunction(gameState)

            possibleMoves = gameState.getLegalActions(agentindex)
            val = 0
            for move in possibleMoves:
                if agentindex == ghostcount:
                    for move in possibleMoves:
                        val += maxvalue(gameState.generateSuccessor(agentindex, move), height - 1, ghostcount)
                        #print "minvalue->if->val:\t", val

                else:
                    for move in possibleMoves:
                        val += averagevalue(gameState.generateSuccessor(agentindex, move), height, ghostcount, agentindex + 1)
                        #print "minvalue->else->val:\t", val
            return val/len(possibleMoves)

        if (gameState.isLose() or gameState.isWin()):
            return self.evaluationFunction(gameState)
        possibleMoves = gameState.getLegalActions(0)
        ghostCount = gameState.getNumAgents() - 1
        possibleScore = -float("inf")
        mostOptimalMove = Directions.STOP
        for move in possibleMoves:
            oldScore = possibleScore
            possibleScore = max(possibleScore, averagevalue(gameState.generateSuccessor(0, move), self.depth, ghostCount, 1))
            #print "maximum is :", possibleScore
            if oldScore < possibleScore:
                #print "changing score to:", possibleScore
                mostOptimalMove = move
                #print mostOptimalMove
        return mostOptimalMove

        util.raiseNotDefined()

def betterEvaluationFunction(currentGameState):
    """
      Your extreme ghost-hunting, pellet-nabbing, food-gobbling, unstoppable
      evaluation function (question 5).

      DESCRIPTION: <write something here so we know what you did>
    """
    "*** YOUR CODE HERE ***"

    if currentGameState.isWin():
        return float("inf")
    if currentGameState.isLose():
        return float("-inf")

    curPacmanPos = currentGameState.getPacmanPosition()
    ghostCount = currentGameState.getNumAgents() - 1
    i = 1
    val = scoreEvaluationFunction(currentGameState)
    ghostDistance = float("inf")
    while i <= ghostCount:
        dist = util.manhattanDistance(curPacmanPos, currentGameState.getGhostPosition(i))
        if dist < ghostDistance:
            ghostDistance = dist
        i += 1

    val += max(5, ghostDistance)

    foodList = currentGameState.getFood().asList()
    posOfPowerPallets = currentGameState.getCapsules()
    minDistToFood = float("inf")
    for posOfFood in foodList:
        dist = util.manhattanDistance(posOfFood, curPacmanPos)
        if dist < minDistToFood:
            minDistToFood = dist

    val -= (minDistToFood * 1.5)
    val -= (len(foodList) * 3)
    val -= (len(posOfPowerPallets) * 7)
    return val


    util.raiseNotDefined()

# Abbreviation
better = betterEvaluationFunction

