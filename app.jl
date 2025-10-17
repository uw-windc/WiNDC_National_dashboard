module App

    include("ParameterTab/ParameterTab.jl")
    include("ResultsTab/ResultsTab.jl")
    include("Model/Model.jl")

    import DataFrames
    import PlotlyBase

    const DF = DataFrames
    const PB = PlotlyBase


    using GenieFramework
    @genietools

    Stipple.enable_model_storage(false)

    function build_trace(df, param_name)
        param_info = get(Model.PARAMETERS, param_name, missing)

        [
            PB.bar(df, x=param_info.domain, y=:benchmark, text = :description, name = "Benchmark"),
            PB.bar(df, x=param_info.domain, y=:counterfactual, text = :description, name = "Counterfactual"),
        ]
    end


    all_parameters = collect(keys(Model.PARAMETERS))
    data_tables = Dict(param => Model.get_parameter(param) for param in all_parameters)

    @app begin
        @in data = DataTable(data_tables[all_parameters[1]])

        @in Select_fruit = all_parameters[1]
        @out Select_fruit_list = all_parameters

        @out plot_trace = build_trace(data_tables[all_parameters[1]], all_parameters[1])

        @onchange Select_fruit begin
            plot_trace = build_trace(data_tables[Select_fruit], Select_fruit)
            data = DataTable(data_tables[Select_fruit])
        end

        
        @out results_trace = ResultsTab.build_results_trace(Model.summary, :Investment, "Real Value")
        @out results_parameters = collect(keys(ResultsTab.display_parameters))
        @in results_parameter = :Investment

        @out results_display_options = ["Real Value", "Percentage Change"]
        @in results_display_option = "Real Value"

        @onchange results_parameter begin
            results_trace = ResultsTab.build_results_trace(Model.summary, results_parameter, results_display_option)
        end

        @onchange results_display_option begin
            results_trace = ResultsTab.build_results_trace(Model.summary, results_parameter, results_display_option)
        end
        
        
        
        
        @onchange data begin
            data_tables[Select_fruit] = data.data       
            plot_trace = build_trace(data_tables[Select_fruit], Select_fruit)
        end

        @in tab_selected = "Results"
        @in run_simulation = false

        @onbutton run_simulation begin
            tab_selected = "Results"
            @show 1
            Model.update_parameters(data_tables)
            @show 2
            solved = Model.solve!()
            @show 3
            
        end

    end





    function ui()

        
        cell(class = "container st-col  col-sm st-module", [
            #h2("WiNDC National Parameters"),
            tabgroup(
                :tab_selected,
                inlinelabel = true,
                class = "bg-primary text-white shadow-2",

                [
                    tab(name = "Results", label = "Results"),
                    tab(name = "Parameters",  label = "Parameters"),
                    tab(name = "Model Description", label = "Model Description"),
                ],
            ),
            tabpanels(
                :tab_selected,
                animated = true,
                var"transition-prev" = "scale",
                var"transition-next" = "scale",
                style="background-color: lightgrey",
                [
                    tabpanel(name = "Results", [ResultsTab.ui(Model.summary)]),
                    tabpanel(name = "Parameters", [ParameterTab.ui(:data)]),
                    tabpanel(name = "Model Description", [p("Movies content")]),
                ],
            ),
        ])
    end



    @page("/", ui, layout = "layout.jl", model = App)



end