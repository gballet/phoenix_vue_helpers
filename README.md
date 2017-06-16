# Phoenix Vue Helpers

A series of helpers for efficient phoenix development with Vuejs. The long term
goal of this project is to propose a [meteor](https://www.meteor.com/)-like
environment to build rapid SPAs.

## Installation

The package can be installed by adding `phoenix_vue` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [{:phoenix_vue_helpers, "~> 0.1.0"}]
end
```

## Getting started

Add Vue to your project by typing:

```
$ mix phoenix.vue.install
```

It will ask you if you want to add a root component. Assuming that you haven't done
so yet, it is recommended to say yes.

You can add more components by typing:

```
$ mix phoenix.gen.vue.component FooComponent
```

And a `FooComponent.vue` file will be generated in `web/static/components`.

## TODO

- [ ] `vue-router2` integration
- [ ] socket integration
