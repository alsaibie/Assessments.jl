module JuliaAssessment

include("QuestionTypes.jl")
include("DeLaTeX.jl")
include("MoodleGift.jl")
include("AssessmentPlots.jl")

using UUIDs

function relerror(x, e)
    return round(e*abs(x), sigdigits=3)
end

function rd(x::Number)
    # Convenience rounding to 3 sig figs - pretty standard
    return round(x, sigdigits=3)
end


function unique_filename(filepath::String)
    patch = r"([^\\\/]+(?=\.[\w]+$))"
    m = match(patch, filepath)
    newfilename = "$(m.captures[1])" * "-$(uuid4())"
    return replace(filepath, patch => newfilename)
end


function preparse_text(text::String)
    matches = eachmatch(r"L\"(.*?)\"", text)
    for m in matches
        expression_text = String(tex(m.captures[1]))
        text = replace(text, r"L\"" * "$(m.captures[1])" * r"\"" => expression_text)
    end

    # matches2 = eachmatch(r"E\"(.*?)\"", text)
    # print(matches2)
    # for m in matches2
    #     println("test" * typeof(m.captures[1]))
    #     expression_text = "$tex($(m.captures[1]))"
    #     text = replace(text, r"L\"" * "$(m.captures[1])" * r"\"" => expression_text)
    # end


    return text

end

end # module
