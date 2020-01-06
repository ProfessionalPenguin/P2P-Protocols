defmodule Assign2.GossipNode do
  use GenServer, restart: :transient

  def start_link(topology) do
    GenServer.start_link(__MODULE__, topology)
  end

  def init(topology) do
    {:ok, {1, topology}}
  end

   def handle_info(:broadcast, {c, t}) do
     GenServer.cast(self(), {:next,self()})
     {:noreply, {c, t}}
   end


  def handle_cast({:next,pid}, {count, topology} ) do

    if(count == 1) do
        Assign2.GossipServer.tagged(self())
    end

    if(count <= 10) do
      if topology == "full" do
        deleted= Assign2.Topologies.getDeleted()
        neighbors=Assign2.Topologies.getAllNodes() -- deleted -- [self()]
        if neighbors == [] do
        Assign2.Topologies.deleteNode(self())
        else
        randomNeighbor=Enum.random(neighbors)
        GenServer.cast(randomNeighbor, {:next,self()})
        Process.send_after(self(), :broadcast, 10)
        end
      else
        deleted= Assign2.Topologies.getDeleted()
        neighbors = Assign2.Topologies.allNeighbors(self()) -- deleted
        if neighbors == [] do
          Assign2.Topologies.deleteNode(self())
          Assign2.Topologies.updateNeighbor(self(), neighbors)
        else
          Assign2.Topologies.updateNeighbor(self(), neighbors)
          randomNeighbor=Enum.random(neighbors)
          GenServer.cast(randomNeighbor, {:next,self()})
          Process.send_after(self(), :broadcast, 10)
          #num.each(neighbors, fn neighborPID -> GenServer.cast(neighborPID, {:next, self()}) end)
        end
      end
    end

    if(count==11) do
      Assign2.Topologies.deleteNode(self())
    end
    if pid==self() do
      {:noreply, {count , topology}}
    else
    {:noreply, {count + 1, topology}}
    end
  end

end
