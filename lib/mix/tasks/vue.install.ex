defmodule Mix.Tasks.PhoenixVueHelpers.Install do
    use Mix.Task

    @npmDependencies ["vue"]
    @npmDevDependencies ["vue-brunch", "babel-plugin-transform-runtime"]

    @shortdoc "Install Vuejs support into this phoenix project"

    @appjs_path "web/static/js/app.js"
    @apphtml_path "web/templates/layout/app.html.eex"
    @components_path "web/static/components"
    @indexhtml_path "web/templates/page/index.html.eex"

    def run(_args) do
        # Add npm dependencies
        if Mix.shell.cmd("npm install --save #{Enum.join(@npmDependencies, " ")}") != 0, do: Mix.raise "Error installing npm packages. Please copy the npm output above when reporting a bug."
        if Mix.shell.cmd("npm install --save-dev #{Enum.join(@npmDevDependencies, " ")}") != 0, do: Mix.raise "Error installing npm packages. Please copy the npm output above when reporting a bug."

        # Add brunch configuration to load `.vue` files
        if File.exists?("brunch-config.js") do
            brunchconfigjs = File.read!("brunch-config.js")
            |> String.replace(~r{\n(\s*)(plugins:\s*\{\n)},"\n\\1\\2\\1\\1vue: {\n\\1\\1\\1extractCSS: true,\n\\1\\1\\1out: 'priv/static/css/vue-components.css'\n\\1\\1},\n")
            File.write!('brunch-config.js', brunchconfigjs)

            # Import the aggregated CSS into `app.html.eex`
            apphtml = File.read!(@apphtml_path)
            |> String.replace(~r{(\n\s*)(.link\s+rel[^\n]+href[^\n]*css.app.css[^\n]*)\n(?![^\n]+vue-components.css)}, "\\1\\2\\1<link rel=\"stylesheet\" href=\"<%= static_path(@conn, \"/css/vue-components.css\") %>\">\n")
            File.write!(@apphtml_path, apphtml)
        else
            Mix.shell.info """
            Brunch doesn't seem to be installed, skipping configuration. However
            you decide to load the package, make sure that the CSS is extracted
            and then imported into your `app.html.eex`.
            """
        end

        # Add vue import to app.js
        appjs = File.read!(@appjs_path) |> add_vue_import |> add_root_component?
        File.write!(@appjs_path, appjs)
    end

    defp paths do
        [".", :phoenix_vue]
    end

    # Imports Vue into `app.js` if it is not already present.
    defp add_vue_import(appjs) do
        if Regex.match?(~r/import Vue from 'vue\/dist\/vue';/, appjs) do
            appjs
        else
            "import Vue from 'vue/dist/vue';\n"
        end
    end

    # Ask the user if they want a scaffolded root component
    defp add_root_component?(appjs) do
        if Mix.shell.yes?("Scaffold the app by adding a root component?") do
            add_root_component(appjs)
        else
            appjs
        end
    end

    # Effectively add the root component to the project's config files.
    defp add_root_component(appjs) do
        binding = Mix.Phoenix.inflect("app")

        Mix.Phoenix.copy_from paths(), "priv/templates/app.component", "", binding, [
            {:eex, "app.vue.eex", "#{@components_path}/App.vue"}
        ]

        # TODO Alternatively, propose to use vue-router2, in which case it's the app
        # layout file that needs to be updated, index.html.eex doesn't even need to
        # exist.
        indexhtml = File.read!(@indexhtml_path) |> String.replace(~r{\n<div class="row marketing">(.*\n)+</div>\n?$}, "<app></app>")
        File.write(@indexhtml_path, indexhtml)

        """
        import App from 'web/static/components/App.vue';

        new Vue({
            el: "app",
            components: {App}
        });
        """
    end
end
