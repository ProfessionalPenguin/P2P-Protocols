defmodule Assign2.PushSumNodeSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    message="Started PushSum Node Supervisor."
    IO.inspect(message)
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_node(nodeNumber,topology) do
    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, {Assign2.PushSumNode, {nodeNumber, topology}} )
    pid
  end
end
