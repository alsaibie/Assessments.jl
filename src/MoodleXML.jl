
function svg_as_html_text(filename)
    svg_content = readuntil(filename, "</svg>", keep = true)
    # for patch in [':', '~', '=', '#', '{', '}']
    #     svg_content = replace(svg_content, patch => "\\" * patch)
    # end
    # svg_content = replace(svg_content, "\n" => "<br>")
    # remove blank lines
    svg_content = replace(svg_content, r"(?m)^[ \t]*\r?\n" => "" )
    # return "<br><body>" * svg_content * "</body><br>"
    return "<br>" * svg_content * "<br>"

end

function parse_to_html_text(text)

    text = preparse_text(text);

    # Replace "\n" with "<br>"
    text = replace(text, "\n" => "<br>")

    # # Gift requires addition of backslash to certain delimeters
    # for escape_patch in [':', '~', '=', '#', '{', '}']
    #     text = replace(text, escape_patch => "\\" * escape_patch)
    # end

    # Replace SVG figs 
    # TODO: check svg extension is valid
    matches = eachmatch(r"@FIG\(\"(.*?)\"\)", text)
    for m in matches
        svg_text = svg_as_html_text("$(m.captures[1])")
        text = replace(text, r"@FIG\(\"" * "$(m.captures[1])" * r"\"\)" => svg_text)
    end

    return text;
end