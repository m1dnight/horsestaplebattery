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

  @typedoc "A category of words, as accepted by `generate_compound/1`."
  @type category :: :adjective | :adverb | :noun | :verb

  @typedoc "Internal collection key matching `priv/<collection>.bin`."
  @type collection :: :adjectives | :adverbs | :nouns | :verbs

  @typedoc "A tuple of words; indexed in O(1) via `Kernel.elem/2`."
  @type word_tuple :: tuple()

  @typedoc """
  Supported casings for `generate_compound/2`.

  Each atom joins the generated words in a different style. Examples below use
  the input `["horse", "staple", "battery"]`:

  | Atom                    | Result                  |
  | ----------------------- | ----------------------- |
  | `:pascal_case`          | `HorseStapleBattery`    |
  | `:camel_case`           | `horseStapleBattery`    |
  | `:snake_case`           | `horse_staple_battery`  |
  | `:screaming_snake_case` | `HORSE_STAPLE_BATTERY`  |
  | `:kebab_case`           | `horse-staple-battery`  |
  | `:screaming_kebab_case` | `HORSE-STAPLE-BATTERY`  |
  | `:train_case`           | `Horse-Staple-Battery`  |
  | `:dot_case`             | `horse.staple.battery`  |
  | `:path_case`            | `horse/staple/battery`  |
  | `:flat_case`            | `horsestaplebattery`    |
  | `:upper_flat_case`      | `HORSESTAPLEBATTERY`    |
  | `:title_case`           | `Horse Staple Battery`  |
  """
  @type casing ::
          :pascal_case
          | :camel_case
          | :snake_case
          | :screaming_snake_case
          | :kebab_case
          | :screaming_kebab_case
          | :train_case
          | :dot_case
          | :path_case
          | :flat_case
          | :upper_flat_case
          | :title_case

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

      # for each file, gunzip it in-memory, split into lines, and accumulate
      # into a single tuple for O(1) lookup at runtime.
      tuple =
        files
        |> Enum.flat_map(fn file ->
          file
          |> File.read!()
          |> :zlib.gunzip()
          |> String.split("\n", trim: true)
          |> Enum.map(&String.trim/1)
          |> Enum.map(&String.replace(&1, ~r/[^A-z]/u, ""))
        end)
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
  @spec adjectives() :: word_tuple()
  def adjectives, do: load(:adjectives)

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
  @spec adverbs() :: word_tuple()
  def adverbs, do: load(:adverbs)

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
  @spec nouns() :: word_tuple()
  def nouns, do: load(:nouns)

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
  @spec verbs() :: word_tuple()
  def verbs, do: load(:verbs)

  ####################
  # Random elements. #
  ####################

  @doc """
  Returns a single adverb, chosen at random from the entire collection.

  ## Examples

      iex> HorseStapleBattery.random_adverb()
      "ruthlessly"


  """
  @spec random_adverb() :: String.t()
  def random_adverb, do: random(adverbs(), @adverbs_size)

  @doc """
  Returns a single adjective, chosen at random from the entire collection.

  ## Examples

      iex> HorseStapleBattery.random_adjective()
      "exoteric"


  """
  @spec random_adjective() :: String.t()
  def random_adjective, do: random(adjectives(), @adjectives_size)

  @doc """
  Returns a single noun, chosen at random from the entire collection.

  ## Examples

      iex> HorseStapleBattery.random_noun()
      "spermatophyte"


  """
  @spec random_noun() :: String.t()
  def random_noun, do: random(nouns(), @nouns_size)

  @doc """
  Returns a single verb, chosen at random from the entire collection.

  ## Examples

      iex> HorseStapleBattery.random_verb()
      "embruting"


  """
  @spec random_verb() :: String.t()
  def random_verb, do: random(verbs(), @verbs_size)

  ##############
  # Generators #
  ##############

  @doc """
  Generates a compound with random values.

  `casing` controls how the words are joined (see `t:casing/0` for the full
  list of supported styles — defaults to `:pascal_case`).

  `structure` is a list of `t:category/0` atoms describing which part of speech
  to pick for each position. Defaults to `[:adverb, :adverb, :noun]`; another
  popular choice is `[:verb, :noun]`.

  ## Examples


      iex> HorseStapleBattery.generate_compound()
      "WrylySpiritlesslySavours"

      iex> HorseStapleBattery.generate_compound(:snake_case)
      "safely_unwarrantedly_pluralities"

      iex> HorseStapleBattery.generate_compound(:snake_case, [:verb, :noun])
      "cockneyfying_gustav"

      iex> HorseStapleBattery.generate_compound(:kebab_case, [:adjective, :noun])
      "exoteric-spermatophyte"


  """
  @spec generate_compound(casing(), [category()]) :: String.t()
  def generate_compound(casing \\ :pascal_case, structure \\ [:adverb, :adverb, :noun]) do
    structure
    |> generate_from_structure()
    |> apply_casing(casing)
  end

  ###################
  # Private Helpers #
  ###################

  # generate a list of words based on the given structure
  @spec generate_from_structure([category()]) :: [String.t()]
  defp generate_from_structure(structure) do
    Enum.map(structure, fn
      :adverb -> random_adverb()
      :adjective -> random_adjective()
      :noun -> random_noun()
      :verb -> random_verb()
    end)
  end

  # apply the given casing style to the list of words.
  # examples below use the input ["horse", "staple", "battery"].
  @spec apply_casing([String.t()], casing()) :: String.t()
  # HorseStapleBattery
  defp apply_casing(words, :pascal_case),
    do: Enum.map_join(words, &String.capitalize/1)

  # horseStapleBattery
  defp apply_casing(words, :camel_case) do
    case Enum.map(words, &String.downcase/1) do
      [] -> ""
      [first | rest] -> first <> Enum.map_join(rest, &String.capitalize/1)
    end
  end

  # horse_staple_battery
  defp apply_casing(words, :snake_case),
    do: Enum.map_join(words, "_", &String.downcase/1)

  # HORSE_STAPLE_BATTERY
  defp apply_casing(words, :screaming_snake_case),
    do: Enum.map_join(words, "_", &String.upcase/1)

  # horse-staple-battery
  defp apply_casing(words, :kebab_case),
    do: Enum.map_join(words, "-", &String.downcase/1)

  # HORSE-STAPLE-BATTERY
  defp apply_casing(words, :screaming_kebab_case),
    do: Enum.map_join(words, "-", &String.upcase/1)

  # Horse-Staple-Battery
  defp apply_casing(words, :train_case),
    do: Enum.map_join(words, "-", &String.capitalize/1)

  # horse.staple.battery
  defp apply_casing(words, :dot_case),
    do: Enum.map_join(words, ".", &String.downcase/1)

  # horse/staple/battery
  defp apply_casing(words, :path_case),
    do: Enum.map_join(words, "/", &String.downcase/1)

  # horsestaplebattery
  defp apply_casing(words, :flat_case),
    do: Enum.map_join(words, &String.downcase/1)

  # HORSESTAPLEBATTERY
  defp apply_casing(words, :upper_flat_case),
    do: Enum.map_join(words, &String.upcase/1)

  # Horse Staple Battery
  defp apply_casing(words, :title_case),
    do: Enum.map_join(words, " ", &String.capitalize/1)

  # load a .bin file term into persistent term memory.
  # https://www.erlang.org/doc/apps/erts/persistent_term.html
  #
  # if the tuple did not exist yet, read it from the bin file and store it for
  # future fetches.
  @spec load(collection()) :: word_tuple()
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

  @spec random(word_tuple(), pos_integer()) :: String.t()
  defp random(coll, size) do
    idx = :rand.uniform(size) - 1
    elem(coll, idx)
  end
end
