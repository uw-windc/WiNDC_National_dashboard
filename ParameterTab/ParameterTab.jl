module ParameterTab

    using PlotlyBase
    using GenieFramework
    @genietools


    function ui(data)
        cell(class = "container", [
            cell(class = "row", [
                cell(class = "col-sm-12", [
                   btn("Run Simulation", @click(:run_simulation))
                ]),
            ]),

            cell(class = "container st-col  col-sm st-module", [
                cell(class = "row", [
                    cell(class = "col-sm-12", [
                        h3("Parameter Data"),

                    ]),
                ]),
                cell(class = "row", [
                    cell(class = "col-6", [
                        select(:Select_fruit, options = :Select_fruit_list)
                    ]),
                ]),
                cell(class = "row", [
                    cell(class = "col-12", [
                        plot(:plot_trace, layout = PlotlyBase.Layout(title="WiNDC National Parameter Values", barmode = "group"))
                    ]),
                ]),
                cell(class = "row", [
                    cell(class = "col-sm-12", [
                        GenieFramework.table(:data, edit = ["counterfactual"], cell_type = ["number"] )
                    ])
                ])

            ])
        ])
    end

end