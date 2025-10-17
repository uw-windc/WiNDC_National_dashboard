module ResultsTab

    using WiNDCNational
    const WN = WiNDCNational

    using DataFrames

    using GenieFramework
    using PlotlyBase
    @genietools

    function compute_gdp(summary; column = :value)
        WN.table(summary, :Value_Added, :Output_Tax, :Sector_Subsidy) |>
            x -> DataFrames.combine(x, column=> sum => :gdp) |>
            x -> -x[1,:gdp]
    end


    display_parameters = Dict(
            :Investment =>  (description = "Investment", parameter = :Investment_Final_Demand, sign = -1),
            :Consumption => (description = "Consumption", parameter = :Personal_Consumption, sign = -1),
            :Exports => (description = "Exports", parameter = :Export, sign = -1),
            :Imports => (description = "Imports", parameter = :Import, sign = 1),
        )

    function build_results_trace(summary, results_parameter, display_option)
        param_info = get(display_parameters, results_parameter, missing)
        ismissing(param_info) && error("Results parameter $results_parameter not found in display_parameters dictionary.")

        param = WN.table(summary, param_info.parameter) |>
            x -> transform(x,
                [:value, :counterfactual] .=> ByRow(y -> y * param_info.sign) .=> [:benchmark, :counterfactual]
            ) |>
            x -> DataFrames.select(x, :row, :benchmark, :counterfactual) |>
            x -> sort(x, :row)

        if display_option == "Percentage Change"
            param = transform(param,
                [:benchmark, :counterfactual] => ByRow((b,c) -> b==0 ? 0 : round((c - b) / b * 100, digits=2)) => :pct_change
            )

            return [
                bar(param, x=:row, y=:pct_change, name="Percentage Change")
            ]
        else
            return [
                bar(param, x=:row, y=:benchmark, name="Benchmark"),
                bar(param, x=:row, y=:counterfactual, name="Counterfactual"),
            ] 
        end

    end

    function ui(summary)
        benchmark_gdp = compute_gdp(summary, column=:value)
        counterfactual_gdp = compute_gdp(summary, column=:counterfactual)
        cell(class = "container", [
            cell(class = "row", [
                cell(class = "col-6 st-col  col-sm st-module", [
                    h4("Benchmark GDP"),
                    p(benchmark_gdp, style="text-align: center; font-size: 24px; font-weight: bold;")
                ]),
                cell(class = "col-6 st-col  col-sm st-module", [
                    h4("Counterfactual GDP"),
                    p(counterfactual_gdp, style="text-align: center; font-size: 24px; font-weight: bold;")
                ])

            ])

            cell(class = "container st-col  col-sm st-module", [
                cell(class = "row", [
                    cell(class = "col-sm-12", [
                        h3("Results Data"),

                    ]),
                ]),
                cell(class = "row", [
                    cell(class = "col-12", [
                        select(:results_parameter, options = :results_parameters)
                    ]),
                ]),
                cell(class = "row", [
                    cell(class = "col-12", [
                        select(:results_display_option, options = :results_display_options)
                    ]),
                ]),
                cell(class = "row", [
                    cell(class = "col-sm-12", [
                        plot(:results_trace, layout = PlotlyBase.Layout(title="WiNDC National Results", barmode = "group"))
                    ])
                ])

            ])


        ])

    end

end