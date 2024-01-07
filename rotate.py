import math

'''
    Положи эту функцию в класс, который должен вращаться и ( если нет update )
    запусти ее в главном классе

'''

TURN_SPEED = 15
SPEED = 10
def update(self):
        self.angle += TURN_SPEED * self.turning * self.game.delta_time

        move_magnitude = self.direction * SPEED * self.game.delta_time

        x_dir = math.cos(self.radians - math.pi / 2) * move_magnitude
        y_dir = math.sin(self.radians - math.pi / 2) * move_magnitude

        self.position = (self.center_x + x_dir, self.center_y + y_dir)