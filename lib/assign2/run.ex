defmodule Assign2.Run do

  def start(args) do

    nodes = String.to_integer(Enum.at(args, 0))
    topology = Enum.at(args, 1)
    algorithm = Enum.at(args, 2)
    startTime=System.monotonic_time(:millisecond)

    System.no_halt(true)

    children =
      # Starts a worker by calling: Assign2.Worker.start_link(arg)
      # {Assign2.Worker, arg}

      if algorithm=="gossip" do
        [
          Assign2.Topologies,
          Assign2.GossipNodeSupervisor,
          {Assign2.GossipServer, {nodes, topology, startTime}}
        ]
      else
        [
          Assign2.Topologies,
          Assign2.PushSumNodeSupervisor,
          {Assign2.PushSumServer, {nodes, topology, startTime}}
        ]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: Assign2.Supervisor]
    Supervisor.start_link(children, opts)
    :timer.sleep(:infinity)
  end
end
