defmodule Assign2.Topologies do
  use GenServer

  # start
  def start_link(_) do
    message="Started Topology Server."
    IO.inspect(message)
    GenServer.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  #takes list from main server
  def create_topology(list, topology) do
    n=get_neighbors(list, topology)
    #IO.inspect(n)
    setNeighbors(list, n)
  end

  #create empty map
  def init(:no_args) do
    {:ok, { [] , %{} , [] }}
  end

  def handle_cast({:setNeighbors, {allNodes, neighborsList}}, {_a, _b, deletedNodes}) do
    {:noreply, {allNodes, neighborsList, deletedNodes}}
  end

  def handle_cast({:deleteNode, node }, {allNodes, neighborsList , deletedNodes}) do
    deletedNodes=[node] ++ deletedNodes|> Enum.uniq()
    if length(deletedNodes) == length(allNodes)-1 do
      Assign2.GossipServer.allNodesDeleted()
      Assign2.PushSumServer.allNodesDeleted()
    end
    #lend=length(deletedNodes)
    #IO.puts("deleted nodes : #{lend}")
    {:noreply, {allNodes, neighborsList, deletedNodes}}
  end

  def handle_cast({:updateNeighbor , node, neighbors}, {allNodes, neighborsList , deletedNodes}) do
    neighborsList=Map.put(neighborsList, node, neighbors)
    {:noreply, {allNodes, neighborsList, deletedNodes}}
  end

  def handle_call({:random_neighbor, _pid}, _from, {allNodes, neighborsList, deletedNodes}) do
    random_pid = Enum.random(allNodes)
    {:reply, random_pid, {allNodes, neighborsList, deletedNodes}}
  end

  def handle_call({:all_neighbors, pid}, _from, {allNodes, neighborsList, deletedNodes}) do
    neighbors = Map.get(neighborsList, pid)
    {:reply, neighbors, {allNodes, neighborsList, deletedNodes}}
  end

  def handle_call(:get_first, _from, {allNodes, neighborsList, deletedNodes}) do
    {:reply, Enum.random(Map.keys(neighborsList)), {allNodes, neighborsList, deletedNodes}}
  end

  def handle_call(:get_deleted, _from, {allNodes, neighborsList, deletedNodes}) do
    {:reply, deletedNodes, {allNodes, neighborsList, deletedNodes}}
  end

  def handle_call(:get_allNodes, _from, {allNodes, neighborsList, deletedNodes}) do
    {:reply, allNodes, {allNodes, neighborsList, deletedNodes}}
  end


    #neighbor functions API

    def setNeighbors(allNodes, neighborsList)do
      GenServer.cast(__MODULE__, {:setNeighbors , {allNodes, neighborsList}})
    end

    def updateNeighbor(node, neighbors) do
      GenServer.cast(__MODULE__, {:updateNeighbor ,node , neighbors})
    end

    def getDeleted() do
      GenServer.call(__MODULE__, :get_deleted, :infinity)
    end

    def getAllNodes() do
      GenServer.call(__MODULE__, :get_allNodes,:infinity)
    end

    def allNeighbors(pid) do
      GenServer.call(__MODULE__, {:all_neighbors, pid},:infinity)
    end

    def randomNeighbor(pid) do
      GenServer.call(__MODULE__, {:random_neighbor, pid},:infinity)
    end

    def getRandomNode() do
      GenServer.call(__MODULE__, :get_first,:infinity)
    end

    def deleteNode(node) do
      GenServer.cast(__MODULE__, {:deleteNode, node})
    end



  #calculate neighbor functions

  def get_neighbors(nodeList, topology) do
    numNodes = length(nodeList)
    if topology == "full" do
      Enum.reduce(0..(numNodes - 1), %{}, fn x, map ->
        Map.put(map, Enum.at(nodeList, x), [0])
      end)
    else

      neighbors = calculateNeighbors(nodeList, topology)


      Enum.reduce(0..(numNodes - 1), %{}, fn x, map ->
        if Enum.at(neighbors, x) == [] do
          Assign2.Topologies.deleteNode(Enum.at(nodeList, x))
        end
        Map.put(map, Enum.at(nodeList, x), Enum.at(neighbors, x))
      end)
    end
  end

  def calculateNeighbors(nodeList, topology) do
    numNodes = length(nodeList)

    cond do

      topology == "line" ->
        for i <- 0..(numNodes - 1) do
          neighbors =
            cond do
              i == 0 -> [i+1]
              i == numNodes-1 -> [i-1]
              true -> [i-1,i+1]
            end
            [] ++ Enum.map(neighbors, fn x -> Enum.at(nodeList, x) end)
        end
         #end line

            #start honey

        #end honey

      #rand2D
      topology == "rand2D" ->
        emptyMap = %{}

        squareGrid =
          Enum.map(nodeList, fn x -> Map.put(emptyMap, x, [:rand.uniform(100)] ++ [:rand.uniform(100)]) end)

        Enum.reduce(squareGrid, [], fn (k, list2) ->
          [key] = Map.keys(k)
          nodeList = Map.values(k)

          list1 =[] ++
              Enum.map(squareGrid, fn x ->
                if checkDistance(nodeList, Map.values(x)) do
                  Enum.at(Map.keys(x), 0)
                end
              end)
              list1 = Enum.filter(list1, &(!is_nil(&1)))
              list1 = list1 -- [key]
              list2 ++ [list1]
        end)

        #start honey
        topology == "honeycomb" ->
          rows=ceil(length(nodeList)/6)
          l = for i <- 1..rows*6 do
          honeycomb(i,rows)
          end
          l|>Enum.map( fn x ->
          for i<-0..length(x)-1 do
            Enum.at(nodeList, Enum.at(x,i)-1)
          end
          end)
          # nbrs = for i <- 0..length(l) do
          #    Enum.at(nodeList, Enum.at(l,i))
          #       end

        #end honey

        #start honey
        topology == "randhoneycomb" ->
          rows=ceil(length(nodeList)/6)
          l = for i <- 1..rows*6 do
          randhoneycomb(i,rows)
          end
          l|>Enum.map( fn x ->
          for i<-0..length(x)-1 do
            Enum.at(nodeList, Enum.at(x,i)-1)
          end
          end)
          # nbrs = for i <- 0..length(l) do
          #    Enum.at(nodeList, Enum.at(l,i))
          #       end

        #end honey

                #start torus3d
                topology == "3Dtorus" ->
                 l= torus3D(numNodes)
                 _l=l|>Enum.map( fn x ->
                  for i<-0..length(x)-1 do
                    Enum.at(nodeList, Enum.at(x,i)-1)
                  end
                  end)

                #end torus3d

     end #cond end
  end
  def torus3D(numNodes) do
    nodes=ceil(:math.pow(numNodes,1/3))
    _list= for i<- 0..numNodes-1 do


      reqnode = convertback(i,nodes)

      x = Enum.at(reqnode,0)
      y = Enum.at(reqnode,1)
      z = Enum.at(reqnode,2)
      _left = 0
      _right = 0
      _bottom = 0
      _top = 0
      _front = 0
      _back = 0

      {left} =
        cond do
        x-1 < 0 -> {[nodes-1,y,z]}
        true ->  {[x-1,y,z]}
      end
      {right} =
      cond do
        x+1 > nodes-1 -> {[0,y,z]}
        true ->    {[x+1,y,z]}
      end
      {bottom } =
      cond do
        y-1 < 0 -> {[x,nodes-1,z]}
        true ->  {[x,y-1,z]}
      end
      { top } =
      cond do
        y+1 > nodes-1 -> {[x,0,z]}
        true ->      {[x,y+1,z]}
      end
      {front} =
      cond do
        z-1 < 0 -> { [x,y,nodes-1]}
        true ->      {[x,y,z-1]}
      end
      { back } =
      cond do
        z+1 > nodes-1 -> { [x,y,0]}
        true ->       {[x,y,z+1]}
      end
      [_left, _right, _bottom, _top, _front, _back ] = [convert(left,nodes), convert(right,nodes),convert(bottom,nodes),convert(top,nodes),convert(front,nodes),convert(back,nodes)]
    end
  end

  def convert(node,n) do
    Enum.at(node,0)*(n*n) + Enum.at(node,1)*(n) + Enum.at(node,2)
  end
  def convertback(n,degree) do
    d1 = div(n,degree)
    r1 = rem(n,degree)
    d2 = div(d1,degree)
    r2 = rem(d1,degree)
    r3 = rem(d2,degree)
    [r3,r2,r1]

  end
  def checkDistance(node1, node2) do
    node1 = Enum.at(node1, 0)
    node2 = Enum.at(node2, 0)
    x = :math.pow(Enum.at(node2, 0) - Enum.at(node1, 0), 2)
    y = :math.pow(Enum.at(node2, 1) - Enum.at(node1, 1), 2)
    dist = round(:math.sqrt(x + y))
    cond do
      dist <= 10 -> true
      dist > 10 -> false
    end
  end

  def honeycomb(x,  maxrow)do
    _node=x
    i=if rem(x,6)==0 do
      div(x,6)
    else
      div(x,6)+1
    end
    j=if rem(x,6)==0 do
      6
    else
      rem(x,6)
    end
    nbrs=
      if rem(i,2)==0 do
          if i==maxrow do
            cond do
              rem(j,6) == 2 or rem(j,6) == 4 -> [(i-1)*6+j-6, (i-1)*6+j+1]
              rem(j,6) == 1 or rem(j,6)==0 -> [(i-1)*6+j-6]
              rem(j,6) == 3 or rem(j,6) == 5-> [ (i-1)*6+j-6, (i-1)*6+j-1]
              true -> {:ok}
            end

          else

          cond do
            rem(j,6) == 2 or rem(j,6) == 4 -> [(i-1)*6+j+6, (i-1)*6+j-6, (i-1)*6+j+1]
            rem(j,6) == 1 or rem(j,6)==0 -> [(i-1)*6+j+6,(i-1)*6+j-6]
            rem(j,6) == 3 or rem(j,6) == 5-> [(i-1)*6+j+6, (i-1)*6+j-6, (i-1)*6+j-1]
            true -> {:ok}
          end

        end

      else
        if i==maxrow do

          cond do

            rem(j,6) == 2 or rem(j,6) == 4 or rem(j,6) == 0 -> [ (i-1)*6+j-6, (i-1)*6+j-1]
            rem(j,6) == 1 or rem(j,6)==3 or rem(j,6)==5 -> [(i-1)*6+j-6, (i-1)*6+j+1]
            true -> {:ok}
          end

        else

          if i==1 do
            cond do

              rem(j,6) == 2 or rem(j,6) == 4 or rem(j,6) == 0 -> [(i-1)*6+j+6, (i-1)*6+j-1]
              rem(j,6) == 1 or rem(j,6)==3 or rem(j,6)==5 -> [(i-1)*6+j+6, (i-1)*6+j+1]
              true -> {:ok}
            end
          else
            cond do
              rem(j,6) == 2 or rem(j,6) == 4 or rem(j,6) == 0 -> [(i-1)*6+j+6, (i-1)*6+j-6, (i-1)*6+j-1]
              rem(j,6) == 1 or rem(j,6)==3 or rem(j,6)==5 -> [(i-1)*6+j+6,(i-1)*6+j-6, (i-1)*6+j+1]
              true -> {:ok}
            end
          end
        end
      end

      nbrs
 end
 def randhoneycomb(x,  maxrow)do
  _node=x
  i=if rem(x,6)==0 do
    div(x,6)
  else
    div(x,6)+1
  end
  j=if rem(x,6)==0 do
    6
  else
    rem(x,6)
  end
  nbrs=
    if rem(i,2)==0 do
        if i==maxrow do
          cond do
            rem(j,6) == 2 or rem(j,6) == 4 -> [(i-1)*6+j-6, (i-1)*6+j+1]
            rem(j,6) == 1 or rem(j,6)==0 -> [(i-1)*6+j-6]
            rem(j,6) == 3 or rem(j,6) == 5-> [ (i-1)*6+j-6, (i-1)*6+j-1]
            true -> {:ok}
          end

        else

        cond do
          rem(j,6) == 2 or rem(j,6) == 4 -> [(i-1)*6+j+6, (i-1)*6+j-6, (i-1)*6+j+1]
          rem(j,6) == 1 or rem(j,6)==0 -> [(i-1)*6+j+6,(i-1)*6+j-6]
          rem(j,6) == 3 or rem(j,6) == 5-> [(i-1)*6+j+6, (i-1)*6+j-6, (i-1)*6+j-1]
          true -> {:ok}
        end

      end

    else
      if i==maxrow do

        cond do

          rem(j,6) == 2 or rem(j,6) == 4 or rem(j,6) == 0 -> [ (i-1)*6+j-6, (i-1)*6+j-1]
          rem(j,6) == 1 or rem(j,6)==3 or rem(j,6)==5 -> [(i-1)*6+j-6, (i-1)*6+j+1]
          true -> {:ok}
        end

      else

        if i==1 do
          cond do

            rem(j,6) == 2 or rem(j,6) == 4 or rem(j,6) == 0 -> [(i-1)*6+j+6, (i-1)*6+j-1]
            rem(j,6) == 1 or rem(j,6)==3 or rem(j,6)==5 -> [(i-1)*6+j+6, (i-1)*6+j+1]
            true -> {:ok}
          end

        else
          cond do
            rem(j,6) == 2 or rem(j,6) == 4 or rem(j,6) == 0 -> [(i-1)*6+j+6, (i-1)*6+j-6, (i-1)*6+j-1]
            rem(j,6) == 1 or rem(j,6)==3 or rem(j,6)==5 -> [(i-1)*6+j+6,(i-1)*6+j-6, (i-1)*6+j+1]
            true -> {:ok}
          end
        end

      end

    end

    nbrs ++ [Enum.random(1..maxrow*6)]
end
end
