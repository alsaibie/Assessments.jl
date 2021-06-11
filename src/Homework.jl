using Dates

export compile_pdflatex
function compile_pdflatex(filepath::String)
    run(`pdflatex -quiet -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape --aux-directory=.aux -output-directory=output $filepath `)
    # run(`pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape --aux-directory=.aux -output-directory=output $filepath `)
end

export generate_homework_tex
function generate_homework_tex(h::HomeworkHeader, qlist::Array{HomeworkQuestion})
    try
        mkdir("output")
    catch
        println("output directory already exists")
    end

    templatefile = normpath(JuliaAssessment.TEMPLATE_DIR, "homework.tex.in")
    template_text = read(templatefile, String)

    text = replace(template_text, "{{course_name}}" => h.course_name)
    text = replace(text, "{{assignment_type}}" => h.assignment_type)
    text = replace(text, "{{course_number}}" => h.course_number)
    text = replace(text, "{{course_section}}" => h.course_section)
    text = replace(text, "{{semester}}" => h.semester)
    text = replace(text, "{{assignment_number}}" => "$(h.assignment_number)")
    text = replace(text, "{{due_date}}" => "$(Dates.format(h.due_date, "e, dd u yyyy HH:MM"))")
    text = replace(text, "{{instructions}}" => h.instructions)

    questions_only = ""
    questions_solution = ""
    for (idx,q) in enumerate(qlist)
        newpage = idx > 1 ? "\\newpage" : " "

        title = "$(parse_homework_to_pdflatex(q.title))" 
        prob = "$(parse_homework_to_pdflatex(q.problem))"
        sol = "$(parse_homework_to_pdflatex(q.solution))"

        # Questions only
        if h.force_new_page
            questions_only *= newpage
        end

        questions_only *= """
        \\question
        \\textbf{$title ($(q.points)pts) }\\\\
        $(prob)"""
        if h.print_solution
            # Questions and Solution
            questions_solution *= """
            $newpage\\question
            \\textbf{$title ($(q.points)pts) }\\\\
            $(prob)
            {
            \\color{red}
            Solution: \\\\
            $(sol)
            }"""
        end
    end

    text_questions = replace(text, "{{questions}}" => questions_only)
    filename = "$(h.course_number) $(h.course_name) $(h.semester) - $(h.assignment_type) #$(h.assignment_number).tex" 
    filepath = "output/" * filename
    open(filepath,"w") do file
        write(file, text_questions)
    end

    filepath_sol = ""
    if h.print_solution
        text_solutions = replace(text, "{{questions}}" => questions_solution)
        filename_sol = "$(h.course_number) $(h.course_name) $(h.semester) - $(h.assignment_type) #$(h.assignment_number) Solution.tex" 
        filepath_sol = "output/" * filename_sol
        open(filepath_sol,"w") do file
            write(file, text_solutions)
        end
    end

    #TODO: add conditional 
    compile_pdflatex(filepath)
    if h.print_solution
        compile_pdflatex(filepath_sol)
    end

    return filepath, filepath_sol
end

function parse_homework_to_pdflatex(text)

    text = preparse_text(text);

    # Replace figures
    # TODO: new new lines \\ after fig
    matches = eachmatch(r"@FIG\(\"(.*?)\"\)", text)
    for m in matches
        svg_text = """
        {\\begin{center}\\includesvg[width=11cm,height=8cm,keepaspectratio]{$(m.captures[1])} \\end{center}}"""
        text = replace(text, r"@FIG\(\"" * "$(m.captures[1])" * r"\"\)" => svg_text)
    end 

    text = replace(text, "\n" => " \\leavevmode\\\\")

    return text;
end


export display_latex
function display_latex(q::HomeworkQuestion)

    prob = "$(preparse_text(q.problem, format = "PDFLaTeX"))"
    sol = "$(preparse_text(q.solution,format = "PDFLaTeX"))"

    println(prob)

    println(sol)

end