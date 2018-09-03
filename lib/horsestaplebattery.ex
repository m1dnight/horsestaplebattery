defmodule HorseStapleBattery do
  @moduledoc """
  In lib/source/ there are four categories of words, each in their seperate
  directory. The source code for these words can be found here:
  http://www.ashley-bovan.co.uk/words/partsofspeech.html

  The compiler will then take each of these categories (i.e., ajdectives,
  adverbs, nouns, and verbs) and compile them into big-ass tuples.

  At runtime the user should access these tuples with `Kernel.elem/2` to have
  O(1) read.

  Some helper functions are provided to create compounds.
  """

  adjectives_tuple =
    Path.wildcard(Path.join([__DIR__, "source/adjectives", "*"]))
    |> Stream.flat_map(fn file ->
      File.stream!(file, [], :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(fn word ->
        word
        |> String.replace(~r/[^A-z]/u, "")
      end)
    end)
    |> Enum.to_list()
    |> List.to_tuple()

  @adjectives_size :erlang.size(adjectives_tuple)

  adverbs_tuple =
    Path.wildcard(Path.join([__DIR__, "source/adverbs", "*"]))
    |> Stream.flat_map(fn file ->
      File.stream!(file, [], :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(fn word ->
        word
        |> String.replace(~r/[^A-z]/u, "")
      end)
    end)
    |> Enum.to_list()
    |> List.to_tuple()

  @adverbs_size :erlang.size(adverbs_tuple)

  nouns_tuple =
    Path.wildcard(Path.join([__DIR__, "source/nouns", "*"]))
    |> Stream.flat_map(fn file ->
      File.stream!(file, [], :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(fn word ->
        word
        |> String.replace(~r/[^A-z]/u, "")
      end)
    end)
    |> Enum.to_list()
    |> List.to_tuple()

  @nouns_size :erlang.size(nouns_tuple)

  verbs_tuple =
    Path.wildcard(Path.join([__DIR__, "source/verbs", "*"]))
    |> Stream.flat_map(fn file ->
      File.stream!(file, [], :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(fn word ->
        word
        |> String.replace(~r/[^A-z]/u, "")
      end)
    end)
    |> Enum.to_list()
    |> List.to_tuple()

  @verbs_size :erlang.size(verbs_tuple)

  ###############
  # Collections #
  ###############

  @doc """
  Returns a big tuple containing all the adjectives in the database.
  (Data from http://www.ashley-bovan.co.uk/words/partsofspeech.html)

  ## Examples


      iex> HorseStapleBattery.adjectives()
      {"ace", "aft", "ain", "all", "alt", "anal", "ane", "ant", "apt", "arch",
      "arched", "auld", "awed", "backed", "baked", "barbed", "bare", "barred",
      "bats", "beaut", "beige", "bent", "birch", "birk", "bit", "blae", "blah",
      "blame", "blamed", "bland", "blate", "bleak", "blear", "blest", "blocked",
      "blond", "blonde", "bloomed", "blown", "blowzed", "bluff", "blunt", "bobs",
      "boiled", "bold", "boned", "boon", "both", "bought", "boulle", ...}

  """
  def adjectives(), do: unquote(Macro.escape(adjectives_tuple))

  @doc """
  Returns a big tuple containing all the adverbs in the database.
  (Data from http://www.ashley-bovan.co.uk/words/partsofspeech.html)

  ## Examples


      iex> HorseStapleBattery.adverbs()
      {"aft", "all", "anes", "anon", "aught", "bang", "bene", "bis", "blamed", "bolt",
      "but", "cheap", "chock", "clean", "cool", "course", "damn", "damned", "dang",
      "darn", "darned", "dash", "dashed", "days", "dern", "dooms", "dryer", "due",
      "eer", "eath", "eft", "eighth", "else", "erst", "fain", "far", "firm", "flop",
      "flush", "fore", "forte", "foul", "fresh", "fro", "gey", "grave", "heads",
      "heap", "heigh", "hence", ...}

  """
  def adverbs(), do: unquote(Macro.escape(adverbs_tuple))

  @doc """
  Returns a big tuple containing all the nouns in the database.
  (Data from http://www.ashley-bovan.co.uk/words/partsofspeech.html)

  ## Examples


      iex> HorseStapleBattery.nouns()
      {"abb", "abbs", "ace", "ache", "aches", "adz", "adze", "aid", "aide", "aides",
      "aids", "ail", "ails", "aim", "aims", "ain", "aint", "airs", "airt", "airts",
      "aisle", "aisles", "ait", "aitch", "aits", "ake", "akes", "alb", "albs", "ale",
      "ales", "alfa", "alfas", "alias", "all", "alms", "alp", "alps", "alt", "alts",
      "alum", "alums", "amp", "amps", "and", "ands", "ane", "anes", "angst",
      "angsts", ...}

  """
  def nouns(), do: unquote(Macro.escape(nouns_tuple))

  @doc """
  Returns a big tuple containing all the verbs in the database.
  (Data from http://www.ashley-bovan.co.uk/words/partsofspeech.html)

  ## Examples


      iex> HorseStapleBattery.verbs()
      {"ace", "ache", "aches", "add", "adds", "aid", "aids", "ail", "ails", "aim",
      "aims", "airt", "airts", "ake", "akes", "ape", "apes", "arch", "are", "ares",
      "arm", "arms", "ate", "awe", "awed", "awes", "axe", "bade", "badge", "baff",
      "baffs", "bag", "bags", "bail", "bails", "bait", "baits", "baize", "bake",
      "baked", "bakes", "bale", "bales", "balk", "balks", "ban", "bang", "bangs",
      "bans", "barb", ...}

  """
  def verbs(), do: unquote(Macro.escape(verbs_tuple))

  ####################
  # Random elements. #
  ####################

  @doc """
  Returns a single adverb, chosen at random from the entire collection.

  ## Examples

      iex> HorseStapleBattery.random_adverb()
      "ruthlessly"


  """
  def random_adverb(), do: random(adverbs(), @adverbs_size)

  @doc """
  Returns a single adjective, chosen at random from the entire collection.

  ## Examples

      iex> HorseStapleBattery.random_adjective()
      "exoteric"


  """
  def random_adjective(), do: random(adjectives(), @adjectives_size)

  @doc """
  Returns a single noun, chosen at random from the entire collection.

  ## Examples

      iex> HorseStapleBattery.random_noun()
      "spermatophyte"


  """
  def random_noun(), do: random(nouns(), @nouns_size)

  @doc """
  Returns a single verb, chosen at random from the entire collection.

  ## Examples

      iex> HorseStapleBattery.random_verb()
      "embruting"


  """
  def random_verb(), do: random(verbs(), @verbs_size)

  ##############
  # Generators #
  ##############

  @doc """
  Generates a compound with random values. The structure of the compound can be
  defined with a list of arguments, or it can be predefined.

  In case of the predefined compound, <adverb><adverb><noun> will be chosen.
  Another popular choise is <verb><noun>.

  ## Examples


      iex> HorseStapleBattery.generate_compound()
      "WrylySpiritlesslySavours"

      iex> HorseStapleBattery.generate_compound([:verb, :noun])
      "CockneyfyingGustav"


  """
  def generate_compound(structure \\ [:adverb, :adverb, :noun]) do
    structure
    |> Enum.map(fn element ->
      word =
        case element do
          :adverb ->
            random_adverb()

          :adjective ->
            random_adjective()

          :noun ->
            random_noun()

          :verb ->
            random_verb()
        end

      String.capitalize(word)
    end)
    |> Enum.reduce("", fn w, acc -> acc <> w end)
  end

  ###################
  # Private Helpers #
  ###################

  defp random(coll, size) do
    idx = :rand.uniform(size) - 1
    elem(coll, idx)
  end
end
