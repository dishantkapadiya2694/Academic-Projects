import time
import operator

from globals import MyGlobals
import twobytwo_sudoku
import threebythree_sudoku
import sohei_sudoku
import samurai_sudoku


def generate_problems(list_of_lines, n):

    assert (len(list_of_lines) % n == 0)
    i = 0
    a = []
    while i != len(list_of_lines):
        lines = ''
        for j in range(n):
            lines = lines + list_of_lines[i+j]
        a.append(lines)
        i += n
    b = []
    for problem in a:
        b.append(combine_with_values(problem))
    return b

def combine_with_values(problem):
    values = {}
    for key1 , val1 in zip(MyGlobals.squares, problem):
        if val1 == '.':
            values[key1] = MyGlobals.numbers
        else:
            values[key1] = val1
    return values

def assign(values, s, d):
    #Eliminate all the other values (except d) from values[s] and propagate.
    #Return values, except return False if a contradiction is detected.
    other_values = values[s].replace(d, '')
    if all(eliminate(values, s, d2) for d2 in other_values):
        return values
    else:
        return False

def eliminate(values, s, d):
    #Eliminate d from values[s]; propagate when values or places <= 2.
    #Return values, except return False if a contradiction is detected.
    if d not in values[s]:
        return values ## Already eliminated
    values[s] = values[s].replace(d,'')
    ## (1) If a square s is reduced to one value d2, then eliminate d2 from the peers.
    if len(values[s]) == 0:
        return False ## Contradiction: removed last value
    elif len(values[s]) == 1:
        d2 = values[s]
        if not all(eliminate(values, s2, d2) for s2 in MyGlobals.peers[s]):
            return False
    ## (2) If a unit u is reduced to only one place for a value d, then put it there.
    for u in MyGlobals.units[s]:
        dplaces = [s for s in u if d in values[s]]
        if len(dplaces) == 0:
            return False ## Contradiction: no place for this value
        elif len(dplaces) == 1:
            # d can only be in one place in unit; assign it there
            if not assign(values, dplaces[0], d):
                return False
    return values

def search(values):
    global nodes
    nodes += 1
    "Using depth-first search and propagation, try all possible values."
    if values is False:
        return False ## Failed earlier
    if all(len(values[s]) == 1 for s in MyGlobals.squares):
        return values ## Solved!
    
    #VARIABLE ORDERING:
    
    ## MRV: Choose the unfilled square s with the fewest possibilities
    #minDomainSize = size of smallest domain
    domainSizes = [len(values[s]) for s in MyGlobals.squares if len(values[s]) > 1]
    minDomainSize = min(domainSizes)
    #min_keys = indices of squares that have the fewest possibilities
    min_keys = [s for s in MyGlobals.squares if len(values[s])== minDomainSize]    
    
    ## Max degree heuristic: choose the square with the most unassigned peers.    
    sqWithMostUnfilledPeers = min_keys[0] #by default, if just one key with min value, take that key    
    
    
    #break ties
    if len(min_keys)>1:
        #determine which of the ties have the most unassigned peers
        maxNumUnfilledPeers = 0
        for k in min_keys:        
            #calculate number of unassigned peers for k
            unfilledPeers = [p for p in MyGlobals.peers[k] if len(values[p])>1]
            numUnfilledPeers = len(unfilledPeers)
            if numUnfilledPeers > maxNumUnfilledPeers:
                numUnfilledPeers = maxNumUnfilledPeers
                sqWithMostUnfilledPeers = k                
    
    s = sqWithMostUnfilledPeers
    
    """
    #VALUE ORDERING:
    
    ## LCV: Choose the value that constrains its neighbors the least
    valueCounter = {}
    #for every value in the square's domain, check how many neighbors have that value in their domains
    #choose the value that has the fewest count in neighbors
    
    for v in values[s]: #go through all the values v in the square's domain
        for p in peers[s]: #go through all the square's peers
            if v in values[p]: #if a peer has the value v in its domain
                #check whether a key is in the dictionary first before incrementing it
                if v in valueCounter:
                    valueCounter[v] += 1
                else:
                    valueCounter[v] = 1
                    
    #d = min(valueCounter, key=valueCounter.get)                
    #return seqOrFalse(search(assign(values.copy(), s, d)))
    
    
    #get sorted list of valueCounter keys, ordered by value
    sorted_valueCounter = sorted(valueCounter.items(), key=operator.itemgetter(1))
    sorted_values=[]
    for key, value in sorted_valueCounter:
        sorted_values.append(key)
    
    for d in sorted_values:
        #print "d=", d
        result=search(assign(values.copy(), s, d))
        #print "result=", result
        if result!=False:
            return result
            break
    return False
    
    """
    
    return some(search(assign(values.copy(), s, d))
                for d in values[s])
    

def some(seq):
    "Return some element of seq that is true."
    for e in seq:
        if e: return e
    return False


def check_solution(a, s):
    global solutions_matched
    answer_string = ""
    for x, y in s:
        answer_string += y
    print answer_string
    if a == answer_string:
        solutions_matched += 1

################################################################################
#Main
################################################################################
print "-------------------------- 2 x 2 --------------------------"
tic = time.clock()

twobytwo_sudoku.initialize_2X2()
ques = open('2x2_sudoku_q.txt')
ans = open('2x2_sudoku_a.txt')
list_of_problems = generate_problems(ques.read().split(), 2)
list_of_answers = ans.read().split()
number_of_problems = len(list_of_problems)
solutions_matched = 0
solved_grids = []
nodes = 0
for i in list_of_problems:
    a = search(i)
    solved_grids.append(a)

if len(list_of_problems) == 1:
    check_solution(list_of_answers[0], sorted(solved_grids[0].items()))
else:
    for i in range(len(list_of_problems)):
        temp = sorted(solved_grids[i].items())
        check_solution(list_of_answers[i], temp)

print solutions_matched, "out of", number_of_problems, "puzzles solved correctly."

toc = time.clock()

print "2x2 puzzles took:", toc - tic, "s"
print "Nodes expanded:", nodes

################################################################################
print "-------------------------- 3 x 3 --------------------------"
tic = time.clock()

threebythree_sudoku.initialize_3X3()
ques = open('3X3_sudoku_q.txt')
ans = open('3X3_sudoku_a.txt')
list_of_problems = generate_problems(ques.read().split(), 3)
list_of_answers = ans.read().split()
number_of_problems = len(list_of_problems)
solutions_matched = 0
solved_grids = []
nodes = 0
for i in list_of_problems:
    a = search(i)
    solved_grids.append(a)

if len(list_of_problems) == 1:
    check_solution(list_of_answers[0], sorted(solved_grids[0].items()))
else:
    for i in range(len(list_of_problems)):
        temp = sorted(solved_grids[i].items())
        check_solution(list_of_answers[i], temp)

print solutions_matched, "out of", number_of_problems, "puzzles solved correctly."

toc = time.clock()

print "3X3 puzzles took:", toc - tic, "s"
print "Nodes expanded:", nodes
################################################################################
print "-------------------------- SOHEI --------------------------"
tic = time.clock()

sohei_sudoku.initialize_sohei()
ques = open('sohei_sudoku_q.txt')
ans = open('sohei_sudoku_a.txt')
list_of_problems = generate_problems(ques.read().split(), 4)
list_of_answers = ans.read().split()
number_of_problems = len(list_of_problems)
solutions_matched = 0
solved_grids = []
nodes = 0
for i in list_of_problems:
    a = search(i)
    solved_grids.append(a)

if len(list_of_problems) == 1:
    check_solution(list_of_answers[0], sorted(solved_grids[0].items()))
else:
    for i in range(len(list_of_problems)):
        temp = sorted(solved_grids[i].items())
        check_solution(list_of_answers[i], temp)

print solutions_matched, "out of", number_of_problems, "puzzles solved correctly."

toc = time.clock()

print "Sohei puzzles took:", toc - tic, "s"
print "Nodes expanded:", nodes

################################################################################
print "-------------------------- SAMURAI --------------------------"
tic = time.clock()

samurai_sudoku.initialize_samurai()
ques = open('samurai_sudoku_q.txt')
ans = open('samurai_sudoku_a.txt')
list_of_problems = generate_problems(ques.read().split(), 5)
list_of_answers = ans.read().split()
number_of_problems = len(list_of_problems)
solutions_matched = 0
solved_grids = []
nodes = 0
for i in list_of_problems:
    a = search(i)
    solved_grids.append(a)

if len(list_of_problems) == 1:
    check_solution(list_of_answers[0], sorted(solved_grids[0].items()))
else:
    for i in range(len(list_of_problems)):
        temp = sorted(solved_grids[i].items())
        check_solution(list_of_answers[i], temp)

print solutions_matched, "out of", number_of_problems, "puzzles solved correctly."

toc = time.clock()

print "Samurai puzzles took:", toc - tic, "s"
print "Nodes expanded:", nodes