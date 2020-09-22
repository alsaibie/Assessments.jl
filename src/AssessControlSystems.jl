include("JuliaAssessment.jl")
using ControlSystems
using SymPy
import Latexify.latexify
using OrdinaryDiffEq

function TF_to_Sym(G::TransferFunction)
    # Assuming one TF only
    s = symbols("s")
    G = sympy.Poly(reverse(G.matrix[1].num.coeffs), s) / sympy.Poly(reverse(G.matrix[1].den.coeffs), s);
end

@latexrecipe function f(G::TransferFunction; reverse=false)
    return TF_to_Sym(G)
end

function Latexify.latexify(arg::Sym)
    # Prefer Sympy's method of latexifying symbolic terms (fractions to be specific)
    return LaTeXString("\$" * sympy.latex(arg) * "\$")
end

# TODO: for some reason the recipe doesn't send the Extend latexify to Sym
function tex(G::TransferFunction)    
    Gi = TF_to_Sym(G)
    Gi = LaTeXString("\$" * sympy.latex(Gi) * "\$")
    return match_delimiter(Gi)
end

function rlocus_pretty(G::TransferFunction; kwargs...)

    kwargs = Dict(kwargs);
    zeros = tzero(G);
    poles = pole(G);
    min_real = minimum(real(vcat(zeros, poles)))
    max_real = maximum(real(vcat(zeros, poles)))
    
    ylimL = -15; 
    ylimH = 15;
    print(min_real)
    xlimL = round(Int, min(-2, min_real - round(5*abs(min_real)))); 
    xlimH = round(Int, max(2, max_real + round(0.1*abs(max_real))));

    p = plot( [xlimL,xlimH], [0, 0], arrow = (.4, .32), c="black", lw=1, label=false)
    plot!(p, [0, 0], [ylimL, ylimH], arrow  = (0.4, 0.32), c="black", lw=1, label=false)
    rlocusplot!(p, G, Kmax=1000, lw=2, xaxis=[xlimL, xlimH], yaxis=[ylimL, ylimH], 
    framestyle = :origin, xlab="σ", ylab="Im", yguidefontrotation=-90, leg=false,
    background_color=:transparent, foreground_color=:black, size=(500, 350); palette = :jet)

    if haskey(kwargs, :Ts)
        # Place vertical Ts or σ design line
        # TODO: add case for σ
        Ts = kwargs[:Ts]
        σd = - 4 / Ts;
        plot!(p, [σd], seriestype = :vline, lw=2, c="green", label=false)
        annotate!(p, σd + 0.1*abs(σd), 0.9*ylimH, text(L"T_s", 12, :black))   
    end

    if haskey(kwargs, :ωd)
        # Place horizontal wd design line
        plot!(p, [kwargs[:ωd]], seriestype = :hline, lw=2, c="green", label=false)
        annotate!(p, xlimH, 1.1*kwargs[:ωd], text(L"ω_d", 12, :black))   
    end

    if haskey(kwargs, :ζ)
        # Place diagonal ζ line
        f(x) = -tan(acos(kwargs[:ζ])) * x
        plot!(p, x->-tan(acos(kwargs[:ζ])) * x , xlimL, xlimH, lw=2, c="green", label=false)
        annotate!(p, xlimL+.05*abs(xlimL), f(xlimL)+.05*abs(f(xlimL)), text(L"ζ", 12, :black))
    end
    
    if haskey(kwargs, :K)
        # Show Closed Loop Poles (Doesn't the rlocus function handle this already?)
        
    end


    return p
end

function solve_for_k_stability_range_intercept(G::TransferFunction)
    # Given an open-loop transfer function, find the range of K for which the system is stable
    # Return K, ω_d and the solution steps 
    # return the steps as LaTeXString and K and ω_d

    K = symbols("K", real=true, positive=true)

    CharPoly = sympy.factor(1 + K*TF_to_Sym(G))
    CharPoly = sympy.fraction(CharPoly)[1]
    CharPolyIm = subs(CharPoly, symbols("s")=>symbols("ωd", real=true)im)
    KStabSol =  sympy.solve(CharPolyIm, K, symbols("ωd", real=true))

    if isempty(KStabSol) #TODO: add a case for all unstable and for stability beyond a certain range
        KmaxStability = NaN
        ω_d = NaN
        solution_steps = """
        Observing that the root locus does not intercept the imaginary axis, the system is stable for all K 
        The range for which is the system is stable is L"0<K<∞" """
    else
        KmaxStability = KStabSol[1][1]
        ω_d = KStabSol[1][2]
        solution_steps = """
        The range of K for which the system is stable is found by observing the intercept location of the root-locus with the imaginary axis
        Solving for L"1+KG(s)=0", and substituting L"s=±ω_di"
        $(tex(CharPolyIm))L"="$(tex(real(CharPolyIm)))L"+("$(tex(im(CharPolyIm)))L")i=0"
        
        Solving for L"K, ω_d" we get L"K=$KmaxStability, ω_d=$ω_d rad/s", and since the open loop poles are stable, the system becomes unstable beyond this L"K" value. The range for which the system is stable is L"0<K<$KmaxStability" """
    end

    return KmaxStability, ω_d, solution_steps

end


function solve_for_addzero_angle_condition(G::TransferFunction, s_d::Number)
    poles = pole(G)
    zeros = tzero(G)
    θ_p = [atan(imag(s_d) - imag(p), real(s_d) - real(p)) for p in poles]
    θ_z = [atan(imag(s_d) - imag(z), real(s_d) - real(z)) for z in zeros]
        
    if isempty(θ_z)
        θ_z = 0;
    end

    θ_zₙ = rd(sum(θ_p) - sum(θ_z) - π)
    z = rd(imag(s_d) / tan(θ_zₙ) - real(s_d))

    
    solution_steps = """
    Find the location of the zero using the angle condition. Where L"θ_zₙ" is the angle contribution of the added zero. 
    L"∠KG(s)=∑θ_p -∑θ_z=±(2k+1)180°=$(rd(sum(θ_p)))-θ_addz$(θ_z == 0 ? "" : "-")$(θ_z == 0 ? "" : rd(sum(θ_z)))→θ_addz=$(rd(sum(θ_p)-sum(θ_z)))-π=$θ_zₙ"
    
    Solving for the zero location: L"tan(θ_zₙ)=\\frac{im(s_d)}{re(s_d)+ z}→z=\\frac{im(s_d)}{tan(θ_zₙ)} - re(s_d) = $z" """
    return z, θ_zₙ, solution_steps
end

function solve_for_gain_magnitude_condition(G::TransferFunction, s_d::Number)
    # Given open loop poles and zeros, and a desired pole location (assuming it's a valid location), find the gain and setup solution steps
    poles = pole(G)
    zeros = tzero(G)
    
    L_p = [sqrt((imag(s_d) - imag(p))^2 + (real(s_d) - real(p))^2) for p in poles]
    L_z = [sqrt((imag(s_d) - imag(z))^2 + (real(s_d) - real(z))^2) for z in zeros]

    if isempty(L_z)
        L_z = 1;
    end

    L_pProd = rd(prod(L_p));
    L_zProd = rd(prod(L_z))
    K = rd(L_pProd / L_zProd)

    solution_steps = """
    To find the gain, we can use the angle condition: L"K=\\frac{∏L_p}{∏L_z}=\\frac{$L_pProd}{$L_zProd}=$K" """

    return K, solution_steps
end


# s = tf("s")

# Gp = (s+2) / (s^2 + 2*s + 100)

# p = rlocus_pretty(Gp)