using Latexify
using LaTeXStrings
import Polynomials: Polynomial, coeffs
import Base.print
using SymPy


# Latexify doesn't provide options to change the delimeter, extend the method here. 

LaTeX_Formats = ["PDFLaTeX", "KaTeX", "MoodleGift", "MoodleXML"]
Format = "MoodleGift"; # TODO: change it as an option on the user end

export set_format
function set_format(format::String)
    global Format = format
end

# Custom print methods for string interpolation
Base.print(io::IO, S::Sym) = print(io, SymPy.latex(S.evalf(3)))
Base.print(io::IO, M::Array) = print(io, latexbmatrix(M))

export UE # Use when not wanting to evaluate expression in substitutions
UE = sympy.UnevaluatedExpr

export tex, match_delimiter, latexbmatrix
function tex(x)
    global Format;

    if isa(x, LaTeXString)
        text = x;
    elseif isa(x, String) || isa(x, SubString)
        text = latexstring(x);
    else
        text = latexify(x);
    end
    
    return match_delimiter(text)
    
end

function match_delimiter(text)
    global Format;
    if Format == "KaTeX" 
        return text;
    elseif Format == "MoodleGift" || Format == "PDFLaTeX" || Format == "MoodleXML"
        patch = r"\$([^$]+)\$";
        return replace(text, patch => s"\\(\1\\)")
    else
        return text; # TODO: extend
    end
end

function latexbmatrix(arr::AbstractArray; adjustment::Symbol=:c, transpose=false,
    starred=false, kwargs...)
    
    global Format
    transpose && (arr = permutedims(arr))
    rows = first(size(arr))
    columns = length(size(arr)) > 1 ? size(arr)[2] : 1

    if Format == "MoodleGift"
        eol = " \\\\\\\\"
    else
        eol = " \\\\"
    end

    # eol = double_linebreak ? " \\\\\\\\" : " \\\\"

    str = "\\begin{bmatrix}"
    # arr = latexraw(arr; kwargs...)
    
    for i=1:rows, j=1:columns
        str *= string(arr[i,j])
        if i==rows &&  j==columns
            # str *= "\\" # TODO: VERIFY WITH GIFT
        else
            j==columns ? (str *= eol) : (str *= " & ")
        end
    end


    str *= "\\end{bmatrix}"
    latexstr = LaTeXString(str)
    return latexstr
end

function tex(P::Polynomial, v::String, diffeq=false)
    P = reverse(P[:])
    if diffeq
        str = ""
        orderN1 = length(P)
        for (i, coeff) in enumerate(P)
            if coeff != 0
                if i > 1  
                    signbit(coeff) ? str*="-" : str*="+"
                    coeff = abs(coeff)
                end
                if orderN1 - i == 0
                coeff == 1 ? str*= "$v" : str *= "$coeff$v"
                elseif orderN1 - i == 1
                coeff == 1 ? str *= "\\frac{d$v}{dt}" : str *= "$coeff\\frac{d$v}{dt}"
                else
                coeff == 1 ? str *= "\\frac{d^{$(orderN1-i)}$v}{dt}" : str *= "$coeff\\frac{d^{$(orderN1-i)}$v}{dt}"                
                end
            end
        end
    else
        # TODO:: regular Polynomial
        str = ""
    end
    str = string("\$" * str * "\$")
    return match_delimiter(str)
end
