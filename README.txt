Names: Viktar Chyhir and Zhan Lu

Project Name: Space Invaders-Special Edition

Project Description: 
This is a simple game with a similar style to the classic Space Invaders. The player controls a ship 
with the A and D keys and uses SPACE to shoot. Enemies come down in four "lanes" at random times and each enemy has a health bar.
Hitting an enemy increases the player's score and if the player is hit by the enemy, the player health decreases. In addition,
every time an enemy is hit, their colour changes. As the player's score grows, the difficulty of the game increases by increasing
the enemy health and speed. 

Controls: 
A: move left
D: move right
SPACE: shoot/go to next screen (when in Start menu screen)
KEY[0]: main circuit active-low reset (resets the game)

Display: 
HEX1 and HEX0 display the score in hexadecimal.
HEX3 displays the health of the player in hexadecimal. (Player starts with 10 health or a 0xA in hex)

Instructions on How to Run the Project:
Add all of the submitted files to the same project directory. Add all .v and .mif files to the same project.
Compile the project and load the circuit onto the DE1 board.
The game starts out in a START screen, press SPACE to begin the game. When the palyer's health goes down to 0,
the game goes to the game over screen. 
IN ORDER TO RESTART THE GAME FROM THE GAME OVER SCREEN, YOU HAVE TO USE THE KEY[0] RESET.


