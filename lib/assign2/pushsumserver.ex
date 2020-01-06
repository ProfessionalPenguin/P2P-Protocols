defmodule Assign2.PushSumServer do
  use GenServer

  def start_link(args) do
    message="Started PushSum Server."
    IO.inspect(message)

    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def tagged(pid) do
    GenServer.cast(__MODULE__, {:tagged, pid})
  end

  def allNodesDeleted() do
    GenServer.cast(__MODULE__, :allNodesDeleted)
  end

  def init({nodeCount, topology, start_time}) do
    Process.send_after(self(), :execute, 0)
    {:ok, {nodeCount, topology, 0, start_time}}
  end

  def handle_info(:execute, {nodeCount, topology, taggedNodes, _start_time}) do
    nodeCount=
      if topology=="honeycomb" or topology=="randhoneycomb" do
    ceil(nodeCount/6)*6
      else
        nodeCount
      end

    nodeCount=
      if topology=="3Dtorus" do
        floor(:math.pow(ceil(:math.pow(nodeCount,1/3)),3))
      else
        nodeCount
      end
    1..nodeCount|> Enum.map(fn x-> Assign2.PushSumNodeSupervisor.add_node(x,topology) end)|> Assign2.Topologies.create_topology(topology)
    message="Created Topology...Added Nodes..."
    IO.inspect(message)
    message="Converging..."
    IO.inspect(message)
    node = Assign2.Topologies.getRandomNode()
    #topo = Assign2.Topologies.getAllNeighbors()
    #IO.inspect(topo)
    start_time_new=System.monotonic_time(:millisecond)
    GenServer.cast(node, {:next, 0, 0, self()})
    {:noreply, {nodeCount, topology, taggedNodes, start_time_new}}
  end


  def handle_cast({:tagged, _pid}, {nodeCount, topology, taggedNodes, start_time}) do

    taggedNodes = taggedNodes + 1

    if(nodeCount <= 1) do
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("Convergence Time: #{time_taken} milliseconds")
      IO.puts("Nodes with no ratio change: #{taggedNodes} ")
      System.halt(0)
    end

    {:noreply, {nodeCount - 1, topology, taggedNodes, start_time}}
  end

  def handle_cast(:allNodesDeleted, {_nodeCount, _topology, taggedNodes, start_time}) do
    end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("All nodes deleted, Convergence Time: #{time_taken} milliseconds")
      IO.puts("Nodes with no ratio change: #{taggedNodes}")
      System.halt(0)
  end
end
