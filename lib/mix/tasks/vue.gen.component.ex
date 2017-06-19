defmodule Mix.Tasks.PhoenixVueHelpers.Gen.Component do
    use Mix.Task

    @moduledoc """
    Generate a vue component.

        mix phoenix_vue_helpers.gen.component Component

    The generated component will be added to web/static/components with a `.vue`
    extension.
    """

    @shortdoc "Generate a Vuejs component file"

    @components_dir "web/static/components"

    def run(args) do
        [component] = validate_args!(args)

        binding = Mix.Phoenix.inflect(component)
        IO.puts inspect binding

        if !File.exists?(@components_dir), do: File.mkdir_p!(@components_dir)

        Mix.Phoenix.copy_from paths(), "priv/templates/gen.vue.component", "", binding, [
            {:eex, "component.vue.eex", "#{@components_dir}/#{binding[:scoped]}.vue"}
        ]

        Mix.shell.info """
        Your component has now been created. You can use it in your javascript files
        by writing:

        import #{binding[:scoped]} from '#{@components_dir}/#{binding[:scoped]}.vue';
        """
    end

    @spec raise_with_help() :: no_return()
    defp raise_with_help do
        Mix.raise """
            mix phoenix.gen.vue.component expects just the component name
        """
    end

    defp validate_args!(args) do
        unless length(args) == 1 do
            raise_with_help()
        end
        args
    end

    defp paths do
        [".", :phoenix_vue_helpers]
    end
end
