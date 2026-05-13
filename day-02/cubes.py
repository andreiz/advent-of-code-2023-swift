import sys

# Cube constraints defined as a dictionary
CUBE_LIMITS = {'red': 12, 'green': 13, 'blue': 14}

def is_game_possible(game_data, cube_limits):
    cube_counts = {'red': 0, 'green': 0, 'blue': 0}

    for try_data in game_data.split(';'):
        for color_data in try_data.split(','):
            count, color = color_data.strip().split()
            count = int(count)
            cube_counts[color] += count
            if cube_counts[color] > cube_limits[color]:
                return False

    return True

def process_file(filename):
    possible_game_sum = 0

    with open(filename, 'r') as file:
        for line in file:
            game_number, game_data = line.split(':')
            game_number = int(game_number.strip().split()[1])
            if is_game_possible(game_data, CUBE_LIMITS):
                print(f"Game {game_number}: possible")
                possible_game_sum += game_number
            else:
                print(f"Game {game_number}: impossible")

    print(f"Sum of possible game numbers: {possible_game_sum}")

process_file(sys.argv[1])


