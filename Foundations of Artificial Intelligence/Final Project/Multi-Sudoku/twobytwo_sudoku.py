from globals import MyGlobals

def cross(A, B, C=""):
    "Cross product of elements in A and elements in B."
    return [c+a+b for c in C for a in A for b in B]

def initialize_2X2():

    sudoku_grid = 'PQ'
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

    cols_overlapping_X = '456789'
    rows_overlapping_X = 'DEFGHI'
    cols_overlapping_Y = '123456'
    rows_overlapping_Y = 'ABCDEF'

    square1 = cross(rows_overlapping_X, cols_overlapping_X, 'P')
    square2 = cross(rows_overlapping_Y, cols_overlapping_Y, 'Q')

    MyGlobals.common_squares = zip(square1, square2)

    for key1, val1 in MyGlobals.peers.items():
        for overlap_from_X, overlap_from_Y in MyGlobals.common_squares:
            if key1 == overlap_from_X:
                MyGlobals.peers[key1] = val1.union(MyGlobals.peers[overlap_from_Y])
            elif key1 == overlap_from_Y:
                MyGlobals.peers[key1] = val1.union(MyGlobals.peers[overlap_from_X])