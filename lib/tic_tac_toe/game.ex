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

  def register(id \\ UUID.uuid4) do
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

  # GenServer Callbacks

  def handle_call(:get, _from, game) do
    {:reply, {:ok, game}, game}
  end

  # Private Helpers

  defp via_registry(id), do: {:via, Game.Registry, id}
end
