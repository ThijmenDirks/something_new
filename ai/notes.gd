#In Godot 4.6, the general rule is:
#
#> **The authority over an object is the only peer that changes its gameplay state.** RPCs are used to request actions, while `MultiplayerSynchronizer` is used to replicate state—not game logic.
#
#For a player-vs-player hit, a common authoritative flow looks like this.
#
#```text
#Player A presses attack
		#│
		#▼
#Client A
		#│
#rpc_id(server, "request_attack")
		#│
		#▼
#Server
	#• Validates attack
	#• Detects hit
	#• Calculates damage
	#• Applies damage to Player B
		#│
		#▼
#Player B health changes
		#│
#MultiplayerSynchronizer replicates health
		#│
		#▼
#All clients update automatically
#```
#
### Don't do this
#
#Avoid having Player A directly call:
#
#```gdscript
#player_b.rpc("take_damage", 25)
#```
#
#or
#
#```gdscript
#player_b.health -= 25
#```
#
#because a hacked client could damage anyone.
#
#---
#
### Recommended architecture
#
#### Player scene
#
#```
#Player
#├── MultiplayerSynchronizer
#├── Health
#├── Hitbox
#└── Weapon
#```
#
#The server owns the gameplay state.
#
#```gdscript
#health = 100
#```
#
#The synchronizer replicates
#
#* health
#* position
#* animation state
#* etc.
#
#---
#
#### Client requests attack
#
#```gdscript
#@rpc("any_peer", "reliable")
#func request_attack(direction):
	#if !multiplayer.is_server():
		#return
#
	#perform_attack(multiplayer.get_remote_sender_id(), direction)
#```
#
#Clients never decide damage.
#
#---
#
#### Server performs hit detection
#
#```gdscript
#func perform_attack(attacker_peer, direction):
#
	#var attacker = players[attacker_peer]
#
	#var victim = find_hit_player(attacker)
#
	#if victim:
		#victim.apply_damage(20)
#```
#
#---
#
#### Damage is local on server
#
#```gdscript
#func apply_damage(amount):
#
	#health -= amount
#
	#if health <= 0:
		#die()
#```
#
#No RPC is needed here.
#
#---
#
#### MultiplayerSynchronizer
#
#Synchronize
#
#```text
#health
#position
#velocity
#animation
#```
#
#When the server changes
#
#```gdscript
#health = 80
#```
#
#everyone automatically receives
#
#```gdscript
#health = 80
#```
#
#No RPC.
#
#---
#
### When should RPCs be used?
#
#Use RPCs for **requests** or **events**.
#
#Examples:
#
#Client → Server
#
#```text
#request_attack()
#request_jump()
#request_fire()
#request_interact()
#```
#
#Server → Everyone
#
#```text
#play_hit_effect()
#spawn_explosion()
#play_sound()
#```
#
#State like health should usually be synchronized rather than sent via RPC.
#
#---
#
### Example flow
#
#```
#Client A
#--------
#Sword swings
	  #│
	  #▼
#rpc_id(1, "request_attack")
#
		#│
#
#Server
#--------
#Hit Player B?
	  #│
	  #▼
#health -= 20
#
	  #│
#
#MultiplayerSynchronizer
#--------
#health = 80
#
	  #│
#
#Clients
#--------
#Player B health bar updates
#Death animation starts
#```
#
#---
#
### What about lag compensation?
#
#If you're making a fast-paced action game, clients can perform **local prediction** for responsiveness:
#
#* Client immediately plays the swing animation.
#* Client may even show a local hit effect.
#* Server still performs the authoritative hit detection and damage calculation.
#* If the server disagrees, the client corrects its state.
#
#This keeps combat feeling responsive while preventing cheating.
#
#---
#
### A scalable pattern
#
#A clean separation of responsibilities is:
#
#* **RPCs**: Ask the server to perform an action (`request_attack`, `request_use_item`, `request_interact`).
#* **Server**: Validate the request, perform hit detection, calculate damage, update authoritative game state.
#* **MultiplayerSynchronizer**: Replicate persistent state (health, position, velocity, ammo, etc.).
#* **RPCs (server → clients)**: Broadcast transient events that shouldn't be synchronized as state (particles, sounds, camera shake, temporary effects).
#
#This pattern scales well from small co-op games to competitive multiplayer because the server remains the single source of truth while `MultiplayerSynchronizer` handles state replication efficiently.
