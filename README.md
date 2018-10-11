# Fuzz

## Prerequisites

Fuzz is written in Elixir. You'll need Elixir (and Erlang) to build. On a Mac,
you can do

    brew install elixir

## Building

Fuzz uses PropCheck for its random data generation. You'll need to fetch the
project dependencies first.

    mix deps.get
    mix deps.compile
    mix escript.build

## Running

Once built, you can see which data type placeholders Fuzz supports by running
`fuzz --help`.

```
➜  fuzz ./fuzz --help
usage: fuzz <url_with_placeholder_tokens>

Fuzz will use placeholders that will be replaced with randomly generated
data at run-time.

For example:

  fuzz "http://www.google.com/search?source=hp&btnK=Google+Search&q={{int}}"

This will replace {{int}} with random integers and execute a Google search.
Any response that is not between 200 (inclusive) and 300 (exclusive) will
produce an error.

Possible placeholders:
  {{string}}
  {{int}}
  {{integer}}
  {{large_int}
  {{float}}
  {{neg_integer}}
  {{non_neg_integer}}
  {{non_neg_float}}
  {{boolean}}


```

Once you know which data types you want to add to the URL, you can run Fuzz like
this:

```
➜  fuzz mix escript.build
Compiling 1 file (.ex)
Generated escript fuzz with MIX_ENV=dev
➜  fuzz ./fuzz "http://www.google.com/search?source=hp&btnK=Google+Search&q={{int}}"
....................................................................................................
OK: Passed 100 test(s).
```


## License

Fuzz uses PropCheck, which in turn uses proper, which is GPLv3. Therefore, Fuzz
is also GPLv3.
