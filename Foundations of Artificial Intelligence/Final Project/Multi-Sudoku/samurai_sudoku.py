from globals import MyGlobals

def cross(A, B, C=""):
    "Cross product of elements in A and elements in B."
    return [c+a+b for c in C for a in A for b in B]

def initialize_samurai():

    sudoku_grid = 'PQRST'
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
    cols_overlapping_Q = '123'
    rows_overlapping_Q = 'GHI'

    cols_overlapping_Rp = '123'
    rows_overlapping_Rp = 'ABC'
    cols_overlapping_Rq = '789'
    rows_overlapping_Rq = 'ABC'
    cols_overlapping_Rs = '123'
    rows_overlapping_Rs = 'GHI'
    cols_overlapping_Rt = '789'
    rows_overlapping_Rt = 'GHI'

    cols_overlapping_S = '789'
    rows_overlapping_S = 'ABC'
    cols_overlapping_T = '123'
    rows_overlapping_T = 'ABC'

    square_P = cross(rows_overlapping_P, cols_overlapping_P, 'P')
    square_Q = cross(rows_overlapping_Q, cols_overlapping_Q, 'Q')

    square_Rp = cross(rows_overlapping_Rp, cols_overlapping_Rp, 'R')
    square_Rq = cross(rows_overlapping_Rq, cols_overlapping_Rq, 'R')
    square_Rs = cross(rows_overlapping_Rs, cols_overlapping_Rs, 'R')
    square_Rt = cross(rows_overlapping_Rt, cols_overlapping_Rt, 'R')

    square_S = cross(rows_overlapping_S, cols_overlapping_S, 'S')
    square_T = cross(rows_overlapping_T, cols_overlapping_T, 'T')

    MyGlobals.common_squares = zip(square_P, square_Rp)
    MyGlobals.common_squares += (zip(square_Q, square_Rq))
    MyGlobals.common_squares += (zip(square_S, square_Rs))
    MyGlobals.common_squares += (zip(square_T, square_Rt))

    for key1, val1 in MyGlobals.peers.items():
        for overlap_from_X, overlap_from_Y in MyGlobals.common_squares:
            if key1 == overlap_from_X:
                MyGlobals.peers[key1] = val1.union(MyGlobals.peers[overlap_from_Y])
            elif key1 == overlap_from_Y:
                MyGlobals.peers[key1] = val1.union(MyGlobals.peers[overlap_from_X])