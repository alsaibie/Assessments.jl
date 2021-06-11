# include("QuestionTypes.jl")
using Random

function svg_as_gift_text(filename)
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
export parse_to_gift
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
        svg_text = svg_as_gift_text("$(m.captures[1])")
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
        res *= "~$(parse_to_gift(a))"
        if idx < length(ans)
            res*="\n"
        end
    end
    return res
end

function list_multiple_ans(ans::Array{String}, correct = true)
    mark = correct ? "" : "-";
    res = ""
    for (idx, a) in enumerate(ans)
        res *= "~%$mark$(100/length(ans))%$(parse_to_gift(a))"
        if idx < length(ans)
            res*="\n"
        end
    end
    return res
end

function generate_gift_question(q::Assessments.MCQQuestion)
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

function generate_gift_question(q::Assessments.MCQMQuestion)
    # generate gift text
    return """
    ::$(q.title)::$(parse_to_gift(q.statement)) 
    {
    $(list_multiple_ans(q.right_ans, true))
    $(list_multiple_ans(q.wrong_ans, false))
    ####$(parse_to_gift(q.feedback))
    }

    """
end

function generate_gift_question(q::Assessments.EssayQuestion)
    # generate gift text
    return """
    ::$(q.title)::$(parse_to_gift(q.statement)) 
    {
    ####$(parse_to_gift(q.feedback))
    }

    """
end

function generate_gift_question(q::Assessments.NumericalQuestion)
    # generate gift text
    return """
    ::$(q.title)::$(parse_to_gift(q.statement)) 
    {#
    =$(q.right_ans):$(q.tolerance)
    ####$(parse_to_gift(q.feedback))
    }

    """
end

function generate_gift_question(q::Assessments.MatchQuestion)
    # generate gift text
    answer_pairs = q.answer_pairs # TODO: No need to shuffle, Moodle already shuffles them
    ans_list = """
                =$(parse_to_gift(answer_pairs[1][1]))->$(parse_to_gift(answer_pairs[1][2]))"""
    for pair in answer_pairs[2:end]
        ans_list *="""

        =$(parse_to_gift(pair[1]))->$(parse_to_gift(pair[2]))"""
    end

    return """
    ::$(q.title)::$(parse_to_gift(q.statement)) 
    {
    $ans_list
    ####$(parse_to_gift(q.feedback))
    }

    """
end

export display_gift
function display_gift(q)
    # Provide an iterable list
    print(generate_gift_category(q[1]))
    for q_ in q
        print(generate_gift_question(q_))
    end
end

export export_to_gift
function export_to_gift(q)
    io = open("$(q[1].filename).gift", "w")
    write(io, generate_gift_category(q[1]))
    for q_ in q
        write(io, generate_gift_question(q_))
    end
    close(io)
end






