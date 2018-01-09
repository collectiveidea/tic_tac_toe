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

  describe "join/2" do
    test "adds the provided player into the first position" do
      alice = %{id: "alice"}
      {:ok, game} = Game.register

      return = Game.join(game.id, alice)

      assert {:ok, %Game{player_1: ^alice, player_2: nil}} = return
    end

    test "is pipeable" do
      alice = %{id: "alice"}

      return = Game.register
               |> Game.join(alice)

      assert {:ok, %Game{player_1: ^alice, player_2: nil}} = return
    end

    test "adds the provided player into the second position" do
      alice = %{id: "alice"}
      bob = %{id: "bob"}

      return = Game.register
               |> Game.join(alice)
               |> Game.join(bob)

      assert {:ok, %Game{player_1: ^alice, player_2: ^bob}} = return
    end

    test "returns the game if the provided player has already joined" do
      alice = %{id: "alice"}

      return = Game.register
               |> Game.join(alice)
               |> Game.join(alice)

      assert {:ok, %Game{player_1: ^alice, player_2: nil}} = return
    end

    test "returns an error if the game cannot be joined" do
      alice = %{id: "alice"}
      bob = %{id: "bob"}
      charlie = %{id: "charlie"}

      return = Game.register
               |> Game.join(alice)
               |> Game.join(bob)
               |> Game.join(charlie)

      assert {:error, :no_vacancy} = return
    end
  end

  describe "leave/2" do
    test "removes the provided player from the first position" do
      alice = %{id: "alice"}
      {:ok, game} = Game.register |> Game.join(alice)

      return = Game.leave(game.id, alice)

      assert {:ok, %Game{player_1: nil, player_2: nil}} = return
    end

    test "is pipeable" do
      alice = %{id: "alice"}

      return = Game.register
               |> Game.join(alice)
               |> Game.leave(alice)

      assert {:ok, %Game{player_1: nil, player_2: nil}} = return
    end

    test "removes the provided player from the second position" do
      alice = %{id: "alice"}
      bob = %{id: "bob"}

      return = Game.register
               |> Game.join(alice)
               |> Game.join(bob)
               |> Game.leave(bob)

      assert {:ok, %Game{player_1: ^alice, player_2: nil}} = return
    end

    test "returns the game if the provided player hasn't joined" do
      alice = %{id: "alice"}
      bob = %{id: "bob"}

      return = Game.register
               |> Game.join(alice)
               |> Game.leave(bob)

      assert {:ok, %Game{player_1: ^alice, player_2: nil}} = return
    end

    test "accepts a player ID" do
      alice = %{id: "alice"}

      return = Game.register
               |> Game.join(alice)
               |> Game.leave(alice.id)

      assert {:ok, %Game{player_1: nil, player_2: nil}} = return
    end

    test "promotes the second player when the first player leaves" do
      alice = %{id: "alice"}
      bob = %{id: "bob"}

      return = Game.register
               |> Game.join(alice)
               |> Game.join(bob)
               |> Game.leave(alice)

      assert {:ok, %Game{player_1: ^bob, player_2: nil}} = return
    end
  end
end
