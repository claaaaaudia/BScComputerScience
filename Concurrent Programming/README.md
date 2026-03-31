## ⚔️ Concurrent Programming

This project is a two-player dueling game called Duelo. Players control circular avatars, fire projectiles at each other, and can collect modifiers that affect their shooting behavior. The winner is whoever accumulates the most points within two minutes. The game also features a top-10 player ranking and a level progression system based on consecutive victories. The architecture follows a client-server model: the graphical client is written in Java, while the server - which handles matchmaking, game state, physics, collision detection, and account management - is written in Erlang.

The server side is organized into modules responsible for game logic, physics calculations, event processing, and state updates sent to clients each tick. The Java client handles graphical rendering of players, projectiles, and modifiers, as well as user input, and communicates with the server over TCP sockets using a message-prefix protocol. Account data (username, password, level, and win streak) is persisted in a flat text file on the server. 

🎯 Skills acquired: concurrent programming in Erlang, thread management, and client-server communication via TCP sockets.