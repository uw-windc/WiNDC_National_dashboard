module Model

    using WiNDCNational
    const WN = WiNDCNational
    using JLD2
    using DataFrames
    import MPSGE
    import JuMP: is_solved_and_feasible


    @load joinpath(@__DIR__, "data/summary_ag_2023.jld2") summary
    @load joinpath(@__DIR__, "data/model.jld2") M

    table(summary) |>
        x -> leftjoin!(
            x,
            table(summary) |> x->rename(x, :value => :counterfactual),
            on = [:row, :col, :year, :parameter]
        )

    MPSGE.solve!(M, cumulative_iteration_limit=0)
    

    PARAMETERS = Dict(
        :Import_Tariff => (domain=:commodity,f = import_tariff_rate),
        :Output_Tax => (domain = :sector,f = output_tax_rate),
        :Absorption_Tax => (domain = :commodity,f = absorption_tax_rate)
    )


    function get_parameter(param_name)
        param_info = get(PARAMETERS, param_name, missing)
        ismissing(param_info) && error("Parameter $param_name not found in PARAMETERS dictionary.")
        
        domain = param_info.domain
        column = sets(summary, domain) |> x -> x[1,:domain]

        return param_info.f(summary) |>
            x -> leftjoin(
                x,
                elements(summary, domain) |> x -> select(x, Not(:set)),
                on = column => :name
            ) |>
            x -> transform(x,
                :value => identity => :counterfactual,
            ) |>
            x -> select(x,
                column => domain,
                :description,
                :value => :benchmark,
                :counterfactual
            )

    end


    function update_parameters(data_tables; summary=summary, M=M)
        for (key, value) in data_tables
            
            param_info = get(PARAMETERS, key, missing)
            domain = param_info.domain
            for row in eachrow(value)
                MPSGE.set_value!(M[key][Symbol(row[domain])], row[:counterfactual])
            end
        end
    end

    function update_summary!(; summary = summary, M = M)
        P = WN.reconstruct_table(summary, M)


        table(summary) |>
        x -> DataFrames.select!(x, Not(:counterfactual)) |>
        x -> leftjoin!(
            x,
            table(P) |> x->rename(x, :value => :counterfactual),
            on = [:row, :col, :year, :parameter]
        )
    end

    function solve!()
        MPSGE.solve!(M)
        solved = is_solved_and_feasible(MPSGE.jump_model(M))

        update_summary!()

        return solved

    end


end