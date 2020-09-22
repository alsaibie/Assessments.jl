using Latexify
using LaTeXStrings

# Latexify doesn't provide options to change the delimeter, extend the method here. 

LaTeX_Formats = ["PDFLaTeX", "KaTeX", "MoodleGift", "MoodleXML"]
Format = "MoodleGift"; # TODO: change it as an option on the user end

function tex(x)
    global Format;

    if isa(x, LaTeXString)
        text = x;
    elseif isa(x, String) || isa(x, SubString)
        text = latexstring(x);
    else
        println(x)
        text = latexify(x);
    end

    return match_delimiter(text)
end

function match_delimiter(text)
    global Format;
    if Format == "KaTeX" 
        return text;
    elseif Format == "MoodleGift" || Format == "PDFLaTeX"
        patch = r"\$([^$]+)\$";
        return replace(text, patch => s"\\(\1\\)")
    else
        return text; # TODO: extend
    end
end