# HorseStapleBattery (the first 18+ Elixir library)

Small library that allows you to generate random words.

You probably have seen these things if you have ever used Docker, or image websites. 

The name is inspired on [an XKCD](https://xkcd.com/936/).

[Documentation](https://hexdocs.pm/horsestaplebattery)

## Disclaimer 

This library contains words that have a different meaning in a different context.

For example, "anal" can be the abbreviation for [anally retentive](https://en.wikipedia.org/wiki/Anal_retentiveness), and can mean, well, the 18+ thing. 

This can cause some combinations that can be perceived as offensive to some. I don't have the time to filter out these possibilities, so I would like pull requests in this area. 

## Example 

```
iex> HorseStapleBattery.adjectives()
{"ace", "aft", "ain", "all", "alt", "anal", "ane", "ant", "apt", "arch",
"arched", "auld", "awed", "backed", "baked", "barbed", "bare", "barred",
"bats", "beaut", "beige", "bent", "birch", "birk", "bit", "blae", "blah",
"blame", "blamed", "bland", "blate", "bleak", "blear", "blest", "blocked",
"blond", "blonde", "bloomed", "blown", "blowzed", "bluff", "blunt", "bobs",
"boiled", "bold", "boned", "boon", "both", "bought", "boulle", ...}

iex> HorseStapleBattery.adverbs()
{"aft", "all", "anes", "anon", "aught", "bang", "bene", "bis", "blamed", "bolt",
"but", "cheap", "chock", "clean", "cool", "course", "damn", "damned", "dang",
"darn", "darned", "dash", "dashed", "days", "dern", "dooms", "dryer", "due",
"eer", "eath", "eft", "eighth", "else", "erst", "fain", "far", "firm", "flop",
"flush", "fore", "forte", "foul", "fresh", "fro", "gey", "grave", "heads",
"heap", "heigh", "hence", ...}

iex> HorseStapleBattery.nouns()
{"abb", "abbs", "ace", "ache", "aches", "adz", "adze", "aid", "aide", "aides",
"aids", "ail", "ails", "aim", "aims", "ain", "aint", "airs", "airt", "airts",
"aisle", "aisles", "ait", "aitch", "aits", "ake", "akes", "alb", "albs", "ale",
"ales", "alfa", "alfas", "alias", "all", "alms", "alp", "alps", "alt", "alts",
"alum", "alums", "amp", "amps", "and", "ands", "ane", "anes", "angst",
"angsts", ...}

iex> HorseStapleBattery.verbs()
{"ace", "ache", "aches", "add", "adds", "aid", "aids", "ail", "ails", "aim",
"aims", "airt", "airts", "ake", "akes", "ape", "apes", "arch", "are", "ares",
"arm", "arms", "ate", "awe", "awed", "awes", "axe", "bade", "badge", "baff",
"baffs", "bag", "bags", "bail", "bails", "bait", "baits", "baize", "bake",
"baked", "bakes", "bale", "bales", "balk", "balks", "ban", "bang", "bangs",
"bans", "barb", ...}

iex> HorseStapleBattery.generate_compound()
"WrylySpiritlesslySavours"

iex> HorseStapleBattery.generate_compound([:verb, :noun])
"CockneyfyingGustav"

iex> HorseStapleBattery.random_adjective()
"exoteric"

iex> HorseStapleBattery.random_adverb()
"ruthlessly"

iex> HorseStapleBattery.random_noun()
"spermatophyte"

iex> HorseStapleBattery.random_verb()
"embruting"

```
## Installation

```elixir
def deps do
  [
    {:horsestaplebattery, "~> 0.1.0"}
  ]
end
```
