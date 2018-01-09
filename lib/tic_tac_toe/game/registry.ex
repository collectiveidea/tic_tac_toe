defmodule TicTacToe.Game.Registry do
  use GenServer

  @name TicTacToe.Game.Registry

  # GenServer Initalization

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    registry = %{}

    {:ok, registry}
  end

  # Public API

  def get do
    GenServer.call(@name, :get)
  end

  # Public API for Process Name Registration

  def whereis_name(id) do
    GenServer.call(@name, {:whereis_name, id})
  end

  def register_name(id, pid) do
    GenServer.call(@name, {:register_name, id, pid})
  end

  def unregister_name(id) do
    GenServer.cast(@name, {:unregister_name, id})
  end

  def send(id, message) do
    case whereis_name(id) do
      :undefined ->
        {:badarg, {id, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  # GenServer Callbacks

  def handle_call(:get, _from, registry) do
    {:reply, registry, registry}
  end

  def handle_call({:whereis_name, id}, _from, registry) do
    pid = Map.get(registry, id, :undefined)

    {:reply, pid, registry}
  end

  def handle_call({:register_name, id, pid}, _from, registry) do
    if Map.has_key?(registry, id) do
      {:reply, :no, registry}
    else
      Process.monitor(pid)
      registry = Map.put(registry, id, pid)

      {:reply, :yes, registry}
    end
  end

  def handle_cast({:unregister_name, id}, registry) do
    registry = Map.delete(registry, id)

    {:noreply, registry}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, registry) do
    registry = registry
    |> Enum.reject(fn({_, p}) -> p == pid end)
    |> Enum.into(%{})

    {:noreply, registry}
  end

  def handle_info(_msg, registry) do
    {:noreply, registry}
  end
end
