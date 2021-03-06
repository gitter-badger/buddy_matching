defmodule LolBuddy.PlayerServer.RegionMapperTest do
  use ExUnit.Case, async: true
  alias LolBuddy.PlayerServer
  alias LolBuddy.PlayerServer.RegionMapper
  alias LolBuddy.Players.Player
  alias LolBuddy.Players.Criteria

  setup do
    # Prepare two servers for our region mapper to use
    region1 = :region1
    region2 = :region2
    {:ok, _} = PlayerServer.start_link(name: {:global, region1})
    {:ok, _} = PlayerServer.start_link(name: {:global, region2})
    %{region1: region1, region2: region2}
  end

  test "player is added to region specific server", %{region1: region} do
    player = %Player{id: "1", name: "foo", region: region}
    RegionMapper.add_player(player)

    assert [^player] = RegionMapper.get_players(player.region)
  end

  test "player is not accessible from other servers", %{region1: region1, region2: region2} do
    player = %Player{id: "1", name: "foo", region: region1}
    RegionMapper.add_player(player)

    assert [] = RegionMapper.get_players(region2)
  end

  test "multiple players may be added to same server", %{region1: region} do
    player1 = %Player{id: "1", name: "bar", region: region}
    player2 = %Player{id: "2", name: "foo", region: region}
    RegionMapper.add_player(player1)
    RegionMapper.add_player(player2)

    assert 2 = length(RegionMapper.get_players(region))
  end

  test "players can be removed from server", %{region1: region} do
    player = %Player{id: "1", name: "foo", region: region}

    RegionMapper.add_player(player)
    assert [^player] = RegionMapper.get_players(player.region)

    RegionMapper.remove_player(player)
    assert [] = RegionMapper.get_players(player.region)
  end

  test "remove_player removes correct player", %{region1: region} do
    player1 = %Player{id: "1", name: "foo", region: region}
    player2 = %Player{id: "2", name: "bar", region: region}

    RegionMapper.add_player(player1)
    RegionMapper.add_player(player2)
    assert 2 = length(RegionMapper.get_players(region))

    RegionMapper.remove_player(player2)
    assert [^player1] = RegionMapper.get_players(region)
  end

  test "update player updates player in server", %{region1: region} do
    assert RegionMapper.get_players(region) == []

    c1 = %Criteria{positions: [:marksman]}
    c2 = %Criteria{positions: [:jungle]}
    player = %Player{id: "0", name: "bar", criteria: c1, region: region}
    updated_player = %{player | criteria: c2}

    # player is added
    RegionMapper.add_player(player)
    assert [^player] = RegionMapper.get_players(region)

    # player is removed
    RegionMapper.update_player(updated_player)
    assert [^updated_player] = RegionMapper.get_players(region)
  end

  test "updating a player that isn't in server has no effect", %{region1: region} do
    assert RegionMapper.get_players(region) == []

    c1 = %Criteria{positions: [:marksman]}
    player = %Player{id: "0", name: "bar", criteria: c1, region: region}

    # player should not get added because not already present
    RegionMapper.update_player(player)
    assert [] = RegionMapper.get_players(region)
  end
end
