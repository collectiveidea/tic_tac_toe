defmodule TicTacToe.GameTest do
  use ExUnit.Case
  doctest TicTacToe.Game

  alias TicTacToe.Game

  describe "register/1" do
    test "registers and returns a new game" do
      return = Game.register

      assert {:ok, %Game{} = game} = return
      assert is_binary(game.id)
    end

    test "registers and returns a new game with a provided ID" do
      custom_id = UUID.uuid4

      return = Game.register(custom_id)

      assert {:ok, %Game{} = game} = return
      assert game.id == custom_id
    end

    test "returns an error if the provided ID is already registered" do
      custom_id = UUID.uuid4
      {:ok, _game} = Game.register(custom_id)

      return = Game.register(custom_id)

      assert {:error, :already_registered} = return
    end
  end
end
