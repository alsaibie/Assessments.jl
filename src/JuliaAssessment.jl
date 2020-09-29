module JuliaAssessment

include("QuestionTypes.jl")
include("DeLaTeX.jl")
include("MoodleGift.jl")
include("AssessmentPlots.jl")

export Plots
# export NumericalQuestion
using UUIDs

export relerror
function relerror(x, e)
    return round(e*abs(x), sigdigits=3)
end

export rd
function rd(x::Number)
    # Convenience rounding to 3 sig figs - pretty standard
    return round(x, sigdigits=3)
end

# export rd
# function rd(x::Float64)
#     # Convenience rounding to 3 sig figs - pretty standard
#     return round(x, sigdigits=3)
# end

export unique_filename
function unique_filename(filepath::String)
    patch = r"([^\\\/]+(?=\.[\w]+$))"
    m = match(patch, filepath)
    newfilename = "$(m.captures[1])" * "-$(uuid4())"
    return replace(filepath, patch => newfilename)
end


function preparse_text(text::String; format = "MoodleGift")
    global Format = format
    # TODO: add shorthands for bold, italic, underline: (eg. \B{} \I{} \U{})
    matches = eachmatch(r"L\"(.*?)\"", text)
    for m in matches
        expression_text = String(tex(m.captures[1]))
        text = replace(text, r"L\"" * "$(m.captures[1])" * r"\"" => expression_text)
    end

    text = replace(text, "\\B{"=>"\\mathbf{")

    # Force fraction into display mode 
    text = replace(text, "\\frac" => "\\dfrac")

    return text

end

export display_latex
function display_latex(q::HomeworkQuestion)

    prob = "$(preparse_text(q.problem, format = "PDFLaTeX"))"
    sol = "$(preparse_text(q.solution,format = "PDFLaTeX"))"

    println(prob)

    println(sol)

end

end # module



