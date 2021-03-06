defmodule LolBuddy.Players.Criteria do
  @moduledoc """
  Struct definining the possible criterias with which Players can
  filter their matches.
  """
  alias LolBuddy.Players.Player

  @position_limit 5
  @voice_limit 2
  @age_group_limit 3

  defstruct positions: [], voice: [], age_groups: [], ignore_language: false

  @doc """
  Parses the checkbox format the frontend uses for criteria
  into the criteria struct used in the backend.
  """
  def from_json(data) do
    %LolBuddy.Players.Criteria{
      positions: Player.positions_from_json(data["positions"]),
      voice: voice_from_json(data["voiceChat"]),
      age_groups: age_groups_from_json(data["ageGroups"]),
      ignore_language: data["ignoreLanguage"]
    }
  end

  @doc """
  Validates that the given criteria json adheres to some reasonable bounds.
  Doesn't attempt to catch errors that may be apparent from merely
  parsing the json map.
  """
  def validate_criteria_json(data) do
    map_size(data["positions"]) <= @position_limit && map_size(data["voiceChat"]) <= @voice_limit &&
      map_size(data["ageGroups"]) <= @age_group_limit
  end

  defp voice_parse("YES"), do: true
  defp voice_parse("NO"), do: false

  @doc """
  Parses the checkbox format the frontend uses for voice criteria,
  into a list of only booleans indicating whether true/false are
  accepted values for a player's voice field.

  ## Examples
    iex> voice = {"YES" => true, "NO" => true}
    iex> voice_from_json(voice)
    [true, false]
  """
  def voice_from_json(voice), do: for({val, true} <- voice, do: voice_parse(val))

  @doc """
  Parses the checkbox format the frontend uses for age_groups.
  Age groups are compared with list intersection, and as such
  we merely return keys for which the value is true

  ## Examples
  iex> age_groups = {"interval1" => true, "interval2" -> true, "interval3" -> false}
  iex> age_groups_from_json(age_groups)
  ["interval1", "interval2"]
  """
  def age_groups_from_json(age_groups), do: for({val, true} <- age_groups, do: val)
end
