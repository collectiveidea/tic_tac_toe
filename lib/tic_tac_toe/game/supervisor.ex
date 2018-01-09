defmodule TicTacToe.Game.Supervisor do
  use Supervisor

  @name TicTacToe.Game.Supervisor

  # Supervisor Initialization

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    Supervisor.init([TicTacToe.Game], strategy: :simple_one_for_one)
  end

  # Public API

  def register_game(id) do
    Supervisor.start_child(@name, [id])
  end
end
