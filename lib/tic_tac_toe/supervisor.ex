defmodule TicTacToe.Supervisor do
  use Supervisor

  @name TicTacToe.Supervisor

  # Supervisor Initialization

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: :game_registry},
      TicTacToe.Game.Supervisor,
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
