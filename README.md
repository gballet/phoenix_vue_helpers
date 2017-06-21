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

### Without `vue-router`

Add Vue to your project by typing:

```
$ mix phoenix_vue_helpers.install
```

It will ask you if you want to add a default component. Assuming that you haven't done
so yet, it is recommended to say yes.

### Using `vue-router`

Add the list of routes when calling `phoenix_vue_helpers.install`. Route names can
be with camel case or snake case.

```
$ mix phoenix_vue_helpers.install home todos profile_page
```

As in the previous case, you will be asked if you want components files to be generated.

### Adding more components

You can add more components by typing:

```
$ mix phoenix_vue_helpers.gen.component FooComponent
```

And a `FooComponent.vue` file will be generated in `web/static/components`.

## TODO

- [x] `vue-router` integration
- [ ] socket integration
- [ ] login integration with ueberauth
