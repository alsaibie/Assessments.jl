# include("QuestionTypes.jl")
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

function parse_to_gift(text)

    text = preparse_text(text);
    # Replace "\n" with "<br>"

    text = replace(text, "\n" => "<br>")



    # Gift requires addition of backslash to certain delimeters
    for escape_patch in [':', '~', '=', '#', '{', '}']
        text = replace(text, escape_patch => "\\" * escape_patch)
    end



    # Finally replace SVG figs 
    # TODO: check svg extension is valid
    matches = eachmatch(r"@FIG\(\"(.*?)\"\)", text)
    for m in matches
        svg_text = svg_as_text("$(m.captures[1])")
        text = replace(text, r"@FIG\(\"" * "$(m.captures[1])" * r"\"\)" => svg_text)
    end

    return text;
end

function generate_gift_category(q) # TODO: include generic type for gift q
    return """
    \$CATEGORY: \$course\$/$(q.category)

    """
end

function list_wrong_ans(ans::Array{String})
    res = ""
    for (idx, a) in enumerate(ans)
        res *= "~$(a)"
        if idx < length(ans)
            res*="\n"
        end
    end
    return res
end

function generate_gift_mcq(q::JuliaAssessment.MCQQuestion)
    # generate gift text
    return """
    ::$(q.title)::$(parse_to_gift(q.statement)) 
    {
    =$(q.right_ans)
    $(list_wrong_ans(q.wrong_ans))
    ####$(parse_to_gift(q.feedback))
    }

    """
end

function generate_gift_mcq(q::JuliaAssessment.EssayQuestion)
    # generate gift text
    return """
    ::$(q.title)::$(parse_to_gift(q.statement)) 
    {
    ####$(parse_to_gift(q.feedback))
    }

    """
end

function generate_gift_mcq(q::JuliaAssessment.NumericalQuestion)
    # generate gift text
    return """
    ::$(q.title)::$(parse_to_gift(q.statement)) 
    {#
    =$(q.right_ans):$(q.tolerance)
    ####$(parse_to_gift(q.feedback))
    }

    """
end

export display_gift
function display_gift(q)
    # Provide an iterable list
    print(generate_gift_category(q[1]))
    for q_ in q
        print(generate_gift_mcq(q_))
    end
end

export export_to_gift
function export_to_gift(q)
    io = open("$(q[1].filename).gift.txt", "w")
    write(io, generate_gift_category(q[1]))
    for q_ in q
        write(io, generate_gift_mcq(q_))
    end
    close(io)
end






