defmodule TicTacToe.GameTest do
  use ExUnit.Case
  doctest TicTacToe.Game

  alias TicTacToe.Game

  describe "register/1" do
    test "registers and returns a new game" do
      return = Game.register

      assert {:ok, %Game{} = game} = return
      assert is_binary(game.id)
      assert game.player_1 == nil
      assert game.player_2 == nil
      assert game.moves == []
      assert game.winner == nil
    end

    test "registers and returns a new game with a provided ID" do
      custom_id = UUID.uuid4

      return = Game.register(custom_id)

      assert {:ok, %Game{id: ^custom_id}} = return
    end

    test "returns an error if the provided ID is already registered" do
      custom_id = UUID.uuid4
      {:ok, _game} = Game.register(custom_id)

      return = Game.register(custom_id)

      assert {:error, :already_registered} = return
    end
  end

  describe "get/1" do
    test "returns a registered game with the provided ID" do
      {:ok, game} = Game.register

      return = Game.get(game.id)

      assert {:ok, ^game} = return
    end

    test "returns an error if the provided ID is not registered" do
      missing_id = UUID.uuid4

      return = Game.get(missing_id)

      assert {:error, :not_registered} = return
    end
  end
end
