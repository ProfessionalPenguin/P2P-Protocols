
**Gossip and PushSum P2P protocols**

### Contributors:

##### Rahul Bhatia UFID: ########




The Main driver files for Gossip and PushSum are GossipServer and PushSumServer respectively.

Program Flow:

The program kicks off by checking the algorithm required and starts the GenServers needed for each algorithm.
It takes the number of nodes and starts a GenServer for each node using a Dynamic Supervisor.
The nodes are then used to create the topology and neighbors for each node are calculated.
For both algorithms a Node recieves a message and starts periodically sending a new message every 10ms
to any one of its neighbors (randomly chosen). The program terminates if all nodes die or the algorithm 
converges.

### Input Format:

Building and Execution instructions

Naviagate into the folder Assignment2
cd Assignment2

Create the executible file
mix escript.build

Run the program
./assign2 arg1 arg2 arg3

On windows use
escript ./assign2 arg1 arg2 arg3

The arguments can be of the form:

| Argument            | Description     | Options                                               |
|---------------------|-----------------|-------------------------------------------------------|
| arg1                | Number of Nodes | any positive integer                                  |
| arg2                | Topology        | full, line, rand2D, 3Dtorus, honeycomb, randhoneycomb |
| arg3                | Algorithm       | gossip, pushsum                                       |

### Output Format:

For 1000 Full Gossip

"Started Topology Server."
"Started Gossip Node Supervisor."
"Started Gossip Server."
"Created Topology...Added Nodes..."
"Converging..."
 Convergence Time: 363 milliseconds
 Nodes Tagged: 1000 

We print the time to converge and nodes tagged.

#### What is working?

All the topologies and the algorithms are working.

#### What is the largest network you managed to deal with for each type of topology and algorithm?
All tests were performed on an 8 Core 16GB system. The program can be scaled endlessly,
but our tests are limited by the RAM size.

| Topology            | Gossip | Push Sum |
| -------------       | ------ | -------- |
| line                | 20_000 | 20_000   |
| 3Dtorus             | 20_000 | 30_000   |
| full                | 18_000 | 18_000   |
| rand2D              | 30_000 | 30_000   |
| honeycomb           | 20_000 | 20_000   |
| randhoneycomb       | 20_000 | 20_000   |


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/assign2](https://hexdocs.pm/assign2).



```

