using Plots; pyplot();

rcParams = PyPlot.PyDict(PyPlot.matplotlib."rcParams")
config = Dict(
        "font.size" => 16,
        "axes.labelweight" => "bold",
        "axes.labelsize" => 16,
        "xtick.labelsize" => 12,
        "ytick.labelsize" => 12,
        "yaxis.labellocation" => "top",
        "xaxis.labellocation" => "right",
        "legend.fontsize" => 14,
)
merge!(rcParams, config)
