module Assessments

const PKG_DIR = normpath(@__DIR__, "..")
const TEMPLATE_DIR = normpath(PKG_DIR, "templates")


include("QuestionTypes.jl")
include("DeLaTeX.jl")
include("Homework.jl")
include("Exam.jl")
include("MoodleXML.jl")
include("MoodleGift.jl")
include("MoodleFormula.jl")
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


# function preparse_text(text::String; format = "MoodleGift")
function preparse_text(text::String)
    # global Format = format
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

using Markdown
export markdown_parse
function markdown_parse(text::String)
    text = preparse_text(text)
    text = replace(text, "\\(" => "\$" )
    text = replace(text, "\\)" => "\$" )
    return Markdown.parse(text)
end


function svg_as_text(filename)
    svg_content = readuntil(filename, "</svg>", keep = true)
    for patch in [':', '~', '=', '#', '{', '}']
        svg_content = replace(svg_content, patch => "\\" * patch)
    end
    # svg_content = replace(svg_content, "\n" => "<br>")
    # remove blank lines
    svg_content = replace(svg_content, r"(?m)^[ \t]*\r?\n" => "" )
    # return "<br><body>" * svg_content * "</body><br>"
    return "<br>" * svg_content * "<br>"

end

end # module



