# Subject
An implementation of the observer pattern.

Notable differences from Roblox's Signal pattern and similar implementations:
- Subscribers can be threads or functions.
- Subscribers are unordered.
- Subscribing returns an unsubscribe function instead of a Connection object which interfaces well with the Maid pattern.