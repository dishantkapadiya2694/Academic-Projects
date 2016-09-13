from globals import MyGlobals

def cross(A, B, C=""):
    "Cross product of elements in A and elements in B."
    return [c+a+b for c in C for a in A for b in B]

def initialize_3X3():

    sudoku_grid = 'PQR'
    columns = MyGlobals.numbers
    MyGlobals.squares = cross(MyGlobals.rows, columns, sudoku_grid)
    temp = []
    for i in range(len(sudoku_grid)):
        temp.append([cross(MyGlobals.rows, c, sudoku_grid[i]) for c in columns] +
                 [cross(r, columns, sudoku_grid[i]) for r in MyGlobals.rows] +
                 [cross(rs, cs, sudoku_grid[i]) for rs in ('ABC', 'DEF', 'GHI') for cs in ('123', '456', '789')])

    list_of_units = []
    for item in temp:
        list_of_units += item

    MyGlobals.units = dict((s, [u for u in list_of_units if s in u])
                 for s in MyGlobals.squares)
    MyGlobals.peers = dict((s, set(sum(MyGlobals.units[s], [])) - set([s]))
                 for s in MyGlobals.squares)

    cols_overlapping_P = '789'
    rows_overlapping_P = 'GHI'
    cols_overlapping_Qa = '123'
    rows_overlapping_Qa = 'ABC'
    cols_overlapping_Qb = '123'
    rows_overlapping_Qb = 'GHI'
    cols_overlapping_R = '789'
    rows_overlapping_R = 'ABC'
    
    
    square1 = cross(rows_overlapping_P, cols_overlapping_P, 'P')
    square2a = cross(rows_overlapping_Qa, cols_overlapping_Qa, 'Q')
    square2b = cross(rows_overlapping_Qb, cols_overlapping_Qb, 'Q')
    square3 = cross(rows_overlapping_R, cols_overlapping_R, 'R')
    
    common_squares_a = zip(square1, square2a)
    common_squares_b = zip(square2b, square3)
    MyGlobals.common_squares = list(set(common_squares_a + common_squares_b))

    for key1, val1 in MyGlobals.peers.items():
        for overlap_from_X, overlap_from_Y in MyGlobals.common_squares:
            if key1 == overlap_from_X:
                MyGlobals.peers[key1] = val1.union(MyGlobals.peers[overlap_from_Y])
            elif key1 == overlap_from_Y:
                MyGlobals.peers[key1] = val1.union(MyGlobals.peers[overlap_from_X])