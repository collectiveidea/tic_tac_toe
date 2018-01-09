defmodule TicTacToe.Game do
  defstruct [
    id: nil,
    player_1: nil,
    player_2: nil,
    moves: [],
    winner: nil,
  ]

  use GenServer, restart: :transient

  alias TicTacToe.Game

  # GenServer Initialization

  def start_link(_opts, id) do
    GenServer.start_link(__MODULE__, id, name: via_registry(id))
  end

  def init(id) do
    game = %Game{id: id}

    {:ok, game}
  end

  # Public API

  def register(id \\ UUID.uuid4) when is_binary(id) do
    case Game.Supervisor.register_game(id) do
      {:ok, pid} -> GenServer.call(pid, :get)
      {:error, {:already_started, _pid}} -> {:error, :already_registered}
    end
  end

  def get(id) do
    case GenServer.whereis(via_registry(id)) do
      nil -> {:error, :not_registered}
      pid -> GenServer.call(pid, :get)
    end
  end

  def join(id, player) when is_map(player) do
    GenServer.call(via_registry(id), {:join, player})
  end

  def leave(id, %{id: player_id}), do: leave(id, player_id)
  def leave(id, player_id) do
    GenServer.call(via_registry(id), {:leave, player_id})
  end

  # GenServer Callbacks

  def handle_call(:get, _from, game) do
    {:reply, {:ok, game}, game}
  end

  def handle_call({:join, player}, _from, %{player_1: nil} = game) do
    game = Map.put(game, :player_1, player)
    {:reply, {:ok, game}, game}
  end
  def handle_call({:join, player}, _from, %{player_2: nil} = game) do
    game = Map.put(game, :player_2, player)
    {:reply, {:ok, game}, game}
  end
  def handle_call({:join, _player}, _from, game) do
    {:reply, {:error, :no_vacancy}, game}
  end

  def handle_call({:leave, player_id}, _from, %{player_1: %{id: player_id}} = game) do
    game = Map.put(game, :player_1, nil)
    {:reply, {:ok, game}, game}
  end
  def handle_call({:leave, player_id}, _from, %{player_2: %{id: player_id}} = game) do
    game = Map.put(game, :player_2, nil)
    {:reply, {:ok, game}, game}
  end
  def handle_call({:leave, _player_id}, _from, game) do
    {:reply, {:ok, game}, game}
  end

  # Private Helpers

  def via_registry({:ok, game_or_id}), do: via_registry(game_or_id)
  def via_registry(%Game{id: id}), do: via_registry(id)
  def via_registry(id), do: {:via, Registry, {:game_registry, id}}
end
