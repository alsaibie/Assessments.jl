using Dates

export compile_pdflatex
function compile_pdflatex(filepath::String)
    run(`pdflatex -quiet -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape --aux-directory=.aux -output-directory=output $filepath `)
    # run(`pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape --aux-directory=.aux -output-directory=output $filepath `)
end

export generate_exam_tex
function generate_exam_tex(h::ExamHeader, qlist::Array{ExamQuestion})
    try
        mkdir("output")
    catch
        println("output directory already exists")
    end

    templatefile = normpath(Assessments.TEMPLATE_DIR, "exam.tex.in")
    template_text = read(templatefile, String)

    text = replace(template_text, "{{course_name}}" => h.course_name)
    text = replace(text, "{{exam_type}}" => h.exam_type)
    text = replace(text, "{{course_number}}" => h.course_number)
    text = replace(text, "{{university_name}}" => h.university_name)
    text = replace(text, "{{college_name}}" => h.college_name)
    text = replace(text, "{{instructor_name}}" => h.instructor_name)
    text = replace(text, "{{course_section}}" => h.course_section)
    text = replace(text, "{{semester}}" => h.semester)
    text = replace(text, "{{exam_number}}" => "$(h.exam_number)")
    text = replace(text, "{{exam_date}}" => "$(Dates.format(h.exam_date, "e, dd u yyyy HH:MM"))")
    text = replace(text, "{{instructions}}" => h.instructions)

    questions_only = ""
    questions_solution = ""
    for (idx,q) in enumerate(qlist)
        newpage = idx > 0 ? "\\newpage" : " "

        title = "$(parse_exam_to_pdflatex(q.title))" 
        prob = "$(parse_exam_to_pdflatex(q.problem))"
        sol = "$(parse_exam_to_pdflatex(q.solution))"

        # Questions only
        if h.force_new_page
            questions_only *= newpage
        end

        questions_only *= """
        \\question
        \\textbf{($(q.points)pts - $(q.variation)) }\\\\
        $(prob)"""
        if h.print_solution
            # Questions and Solution
            questions_solution *= """
            $newpage\\question
            \\textbf{($(q.points)pts - $(q.variation)) }\\\\
            $(prob)
            {
            \\color{red}
            Solution: \\\\
            $(sol)
            }"""
        end
    end

    text_questions = replace(text, "{{questions}}" => questions_only)
    filename = "$(h.course_number) $(h.course_name) $(h.semester) - $(h.exam_type) #$(h.exam_number) V-$(h.version).tex" 
    filepath = "output/" * filename
    open(filepath,"w") do file
        write(file, text_questions)
    end

    filepath_sol = ""
    if h.print_solution
        text_solutions = replace(text, "{{questions}}" => questions_solution)
        filename_sol = "$(h.course_number) $(h.course_name) $(h.semester) - $(h.exam_type) #$(h.exam_number) V-$(h.version) Solution.tex" 
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

function parse_exam_to_pdflatex(text)

    text = preparse_text(text);

    # Replace figures
    # TODO: new new lines \\ after fig
    matches = eachmatch(r"@FIG\(\"(.*?)\"\)", text)
    for m in matches
        svg_text = """
        {\\begin{center}\\includesvg[width=0.9\\textwidth,keepaspectratio]{$(m.captures[1])} \\end{center}}"""
        text = replace(text, r"@FIG\(\"" * "$(m.captures[1])" * r"\"\)" => svg_text)
    end 

    # text = replace(text, "\n" => " \\leavevmode\\\\")

    return text;
end


export display_latex
function display_latex(q::ExamQuestion)

    prob = "$(preparse_text(q.problem, format = "PDFLaTeX"))"
    sol = "$(preparse_text(q.solution,format = "PDFLaTeX"))"

    println(prob)

    println(sol)

end