defmodule HorseStapleBattery do
  @moduledoc """
  In lib/source/ there are four categories of words, each in their seperate
  directory. The source code for these words can be found here:
  http://www.ashley-bovan.co.uk/words/partsofspeech.html

  At compile time the four categories (adjectives, adverbs, nouns, verbs) are
  read, normalised, converted to tuples and written to `priv/<category>.bin` via
  `:erlang.term_to_binary/1`. At runtime the tuples are loaded lazily into
  `:persistent_term` on first access,  O(1) via `Kernel.elem/2`.

  Some helper functions are provided to create compounds.
  """

  @categories [:adjectives, :adverbs, :nouns, :verbs]

  # Build priv/<category>.bin at compile time from lib/source/<category>/*.
  # Giant tuple literals are not embedded into the BEAM, which keeps compilation
  # fast.
  priv_dir = Path.expand("../priv", __DIR__)
  File.mkdir_p!(priv_dir)

  sizes =
    for category <- @categories, into: %{} do
      source_dir = Path.join([__DIR__, "source", Atom.to_string(category)])
      files = source_dir |> Path.join("*") |> Path.wildcard()

      # declare each file as an external resource
      # helps in dev mode to recompile if they change.
      for f <- files, do: @external_resource(f)

      # for each file, generate a tuple that holds all the values.
      # this makes for fast lookup at runtime.
      tuple =
        files
        |> Stream.flat_map(fn file ->
          file
          |> File.stream!([], :line)
          |> Stream.map(&String.trim/1)
          |> Stream.map(&String.replace(&1, ~r/[^A-z]/u, ""))
        end)
        |> Enum.to_list()
        |> List.to_tuple()

      # write each tuple into its own binary
      File.write!(
        Path.join(priv_dir, "#{category}.bin"),
        :erlang.term_to_binary(tuple)
      )

      {category, tuple_size(tuple)}
    end

  @adjectives_size Map.fetch!(sizes, :adjectives)
  @adverbs_size Map.fetch!(sizes, :adverbs)
  @nouns_size Map.fetch!(sizes, :nouns)
  @verbs_size Map.fetch!(sizes, :verbs)

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
  def adjectives(), do: load(:adjectives)

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
  def adverbs(), do: load(:adverbs)

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
  def nouns(), do: load(:nouns)

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
  def verbs(), do: load(:verbs)

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

  # load a .bin file term into persistent term memory.
  # https://www.erlang.org/doc/apps/erts/persistent_term.html
  #
  # if the tuple did not exist yet, read it from the bin file and store it for
  # future fetches.
  defp load(category) do
    key = {__MODULE__, category}

    case :persistent_term.get(key, :__undefined__) do
      :__undefined__ ->
        path = Path.join(:code.priv_dir(:horsestaplebattery), "#{category}.bin")
        tuple = path |> File.read!() |> :erlang.binary_to_term()
        :persistent_term.put(key, tuple)
        tuple

      tuple ->
        tuple
    end
  end

  defp random(coll, size) do
    idx = :rand.uniform(size) - 1
    elem(coll, idx)
  end
end
