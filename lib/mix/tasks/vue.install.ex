defmodule Mix.Tasks.PhoenixVueHelpers.Install do
    use Mix.Task

    @moduledoc """
    Install all vue dependencies into a phoenix project, and optionally adds a
    root component in the project.
    """

    @npmBaseDependencies ["vue"]
    @npmDevDependencies ["vue-brunch", "babel-plugin-transform-runtime"]

    @shortdoc "Install Vuejs support into this phoenix project"

    @jsstatic_path "web/static/js"
    @appjs_path "#{@jsstatic_path}/app.js"
    @apphtml_path "web/templates/layout/app.html.eex"
    @components_path "web/static/components"
    @indexhtml_path "web/templates/page/index.html.eex"

    def run(args) do
        config = %{npm_deps: @npmBaseDependencies, npm_dev_deps: @npmDevDependencies}
                |> add_router?
                |> routes_specified?(args)
                |> add_root_component?

        # Install npm dependencies
        if Mix.shell.cmd("npm install --save #{Enum.join(config[:npm_deps], " ")}") != 0, do: Mix.raise "Error installing npm packages. Please copy the npm output above when reporting a bug."
        if Mix.shell.cmd("npm install --save-dev #{Enum.join(config[:npm_dev_deps], " ")}") != 0, do: Mix.raise "Error installing npm packages. Please copy the npm output above when reporting a bug."

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
        appjs = File.read!(@appjs_path)
            |> add_vue_imports(config)
            |> add_root_component(config)
        File.write!(@appjs_path, appjs)
    end

    defp paths do
        [".", :phoenix_vue_helpers]
    end

    # Imports Vue into `app.js` if it is not already present.
    defp add_vue_imports(appjs, config) do
        init_code = EEx.eval_file "#{Application.app_dir(:phoenix_vue_helpers)}/priv/templates/app.js.eex", Map.to_list(config)
        app_code = String.split(appjs, "\n")
        uniques = String.split(init_code, "\n") -- app_code

        Enum.join(app_code ++ uniques, "\n")
    end

    defp add_router?(config) do
        config
        |> Map.put(:vue_router, Mix.shell.yes?("Use vue router ?"))
        |> Map.put(:npm_deps, config[:npm_deps] ++ ["vue-router"])
    end

    # Ask the user if they want a scaffolded root component
    defp add_root_component?(config) do
        Map.put(config, :root_component, Mix.shell.yes?("Scaffold the app by adding a root component?"))
    end

    defp routes_specified?(config, args) do
        if length(args) > 0 do
            Map.put(config, :routes, Enum.map(args, fn route -> bindings = Mix.Phoenix.inflect(route); {bindings[:alias], bindings[:path]} end))
        else
            Map.put(config, :routes, [])
        end
    end

    # Effectively add the root component to the project's config files.
    defp add_root_component(appjs, config) do
        if config[:root_component] do
            params = Mix.Phoenix.inflect("app") ++ Map.to_list(config)

            Mix.Phoenix.copy_from paths(), "priv/templates/app.component", "", params, [
                {:eex, "app.vue.eex", "#{@components_path}/App.vue"}
            ] ++ (if config[:vue_router], do: [{:eex, "routes.config.js.eex", "#{@jsstatic_path}/routes.config.js"}], else: [])

            for {alias_name, path_name } <- config[:routes] do
                File.write!(
                    "#{@components_path}/#{alias_name}RouteComponent.vue",
                    EEx.eval_file("#{Application.app_dir(:phoenix_vue_helpers)}/priv/templates/default.component.vue.eex", [route_name: path_name, route_module: alias_name]))
            end

            # TODO Alternatively, propose to use vue-router2, in which case it's the app
            # layout file that needs to be updated, index.html.eex doesn't even need to
            # exist.
            indexhtml = File.read!(@indexhtml_path) |> String.replace(~r{\n<div class="row marketing">(.*\n)+</div>\n?$}, "<app></app>")
            File.write(@indexhtml_path, indexhtml)

            appjs <> "\n" <> EEx.eval_file("#{Application.app_dir(:phoenix_vue_helpers)}/priv/templates/root_component.js.eex", params)
        else
            appjs
        end
    end
end
