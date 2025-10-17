using WiNDCNational

using JLD2
using MPSGE

using  DataFrames

@load joinpath(@__DIR__, "Model/data/summary_ag_2023.jld2") summary




domain = :commodity

column = sets(summary, domain) |> x -> x[1,:domain]

import_tariff_rate(summary)

elements(summary, domain) |> x->select(x, Not(:set))



App.data_tables[:Output_Tax]

WN.sets(X,:Output_Tax)



X = App.Model.summary


param = WN.table(X, :Personal_Consumption) |>
    x -> transform(x,
        [:value, :counterfactual] .=> ByRow(y -> y * -1) .=> [:benchmark, :counterfactual]
    ) |>
    x -> DataFrames.select(x, :row, :benchmark, :counterfactual) |>
    x -> sort(x, :row)|>
x -> transform(x,
    [:benchmark, :counterfactual] => ByRow((b,c) -> (c - b) / b * 100) => :pct_change
)

round(123.12312312312321, digits=2)