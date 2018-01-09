defmodule TicTacToe do
  use Application

  # Application Initialization

  def start(_type, _args) do
    TicTacToe.Supervisor.start_link
  end
end
