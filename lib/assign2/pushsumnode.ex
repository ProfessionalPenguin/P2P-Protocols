defmodule Assign2.PushSumNode do
  use GenServer, restart: :transient

  def start_link({nodeNumber,topology}) do
    GenServer.start_link(__MODULE__, {nodeNumber,topology})
  end

  def init({nodeNumber, topology}) do
    #{s , w, count}
    #ratio=nodeNumber/1
    {:ok, {nodeNumber, 1, 0, topology} }
  end

  def handle_info(:broadcast, {s, w, updateCount, topology}) do
    GenServer.cast(self(), {:next, s, w ,self()})
    {:noreply, {s, w, updateCount, topology}}
  end

  def handle_cast({:next, incomingS, incomingW, pid}, {s, w, updateCount, topology}) do
    s=s+incomingS
    w=w+incomingW
    ratio=s/w
    new_s=s/2
    new_w=w/2
    newRatio=new_s/new_w
    difference=abs(newRatio-ratio)
    limit=:math.pow(10, -10)

    updateCount=
      if (updateCount >= 3) do #111

        if updateCount==3 do
          Assign2.PushSumServer.tagged(self())
          Assign2.Topologies.deleteNode(self())
        end
        updateCount+1
      else

        if topology == "full" do
          deleted= Assign2.Topologies.getDeleted()
          neighbors=Assign2.Topologies.getAllNodes() -- deleted -- [self()]
                     if neighbors == [] do
                       Assign2.Topologies.deleteNode(self())
                     else
                    #  Enum.each(neighbors, fn neighborPID -> GenServer.cast(neighborPID,  {:next, new_s, new_w} ) end)
                      randomNeighbor=Enum.random(neighbors)
                      GenServer.cast(randomNeighbor, {:next, new_s, new_w, self()})
                      Process.send_after(self(), :broadcast, 10)

                    end
                     if (difference < limit) do updateCount+1 else 0 end
        else

          if topology=="line" do
            deleted= Assign2.Topologies.getDeleted()
            neighbors = Assign2.Topologies.allNeighbors(self()) -- deleted

            if neighbors == [] do
              Assign2.Topologies.deleteNode(self())
              Assign2.Topologies.updateNeighbor(self(), neighbors)
            else
              Assign2.Topologies.updateNeighbor(self(), neighbors)

              Enum.each(neighbors, fn neighborPID -> GenServer.cast(neighborPID,  {:next, new_s, new_w, self()} ) end)
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
             GenServer.cast(randomNeighbor, {:next,new_s, new_w, self()})
              Process.send_after(self(), :broadcast, 10)
             # Enum.each(neighbors, fn neighborPID -> GenServer.cast(neighborPID,  {:next, new_s, new_w, self()} ) end)
            end
          end


          if (difference < limit) do updateCount+1 else 0 end
        end

      end #111
      updateCount= if pid==self() do
        updateCount-1
      else
        updateCount
      end


    {:noreply, {new_s, new_w, updateCount, topology} }
  end
end
