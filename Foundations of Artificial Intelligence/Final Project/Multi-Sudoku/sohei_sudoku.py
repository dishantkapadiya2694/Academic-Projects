from globals import MyGlobals

def cross(A, B, C=""):
    "Cross product of elements in A and elements in B."
    return [c+a+b for c in C for a in A for b in B]

def initialize_sohei():

    sudoku_grid = 'PQRS'
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

    cols_overlapping_Pq = '123'
    rows_overlapping_Pq = 'GHI'
    cols_overlapping_Pr = '789'
    rows_overlapping_Pr = 'GHI'

    cols_overlapping_Qp = '789'
    rows_overlapping_Qp = 'ABC'
    cols_overlapping_Qs = '789'
    rows_overlapping_Qs = 'GHI'

    cols_overlapping_Rp = '123'
    rows_overlapping_Rp = 'ABC'
    cols_overlapping_Rs = '123'
    rows_overlapping_Rs = 'GHI'

    cols_overlapping_Sq = '123'
    rows_overlapping_Sq = 'ABC'
    cols_overlapping_Sr = '789'
    rows_overlapping_Sr = 'ABC'

    square_Pq = cross(rows_overlapping_Pq, cols_overlapping_Pq, 'P')
    square_Pr = cross(rows_overlapping_Pr, cols_overlapping_Pr, 'P')

    square_Qp = cross(rows_overlapping_Qp, cols_overlapping_Qp, 'Q')
    square_Qs = cross(rows_overlapping_Qs, cols_overlapping_Qs, 'Q')

    square_Rp = cross(rows_overlapping_Rp, cols_overlapping_Rp, 'R')
    square_Rs = cross(rows_overlapping_Rs, cols_overlapping_Rs, 'R')

    square_Sq = cross(rows_overlapping_Sq, cols_overlapping_Sq, 'S')
    square_Sr = cross(rows_overlapping_Sr, cols_overlapping_Sr, 'S')

    MyGlobals.common_squares = zip(square_Pq, square_Qp)
    MyGlobals.common_squares += (zip(square_Pr, square_Rp))
    MyGlobals.common_squares += (zip(square_Sq, square_Qs))
    MyGlobals.common_squares += (zip(square_Sr, square_Rs))

    for key1, val1 in MyGlobals.peers.items():
        for overlap_from_X, overlap_from_Y in MyGlobals.common_squares:
            if key1 == overlap_from_X:
                MyGlobals.peers[key1] = val1.union(MyGlobals.peers[overlap_from_Y])
            elif key1 == overlap_from_Y:
                MyGlobals.peers[key1] = val1.union(MyGlobals.peers[overlap_from_X])