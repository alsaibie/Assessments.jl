
function parse_to_formula_part(p::Assessments.FormulaQPart, part_index::Int)
    templatefile = normpath(Assessments.TEMPLATE_DIR, "formula_qtype_part.xml.in")
    text = read(templatefile, String)

    text = replace(text, "{{QPARTSTATEMENT}}" => parse_to_html_text(p.question))
    text = replace(text, "{{QPARTFEEDBACK}}" => parse_to_html_text(p.feedback))
    text = replace(text, "{{QPARTINDEX}}" => "$(part_index-1)")
    text = replace(text, "{{QPARTPLACEHOLDER}}" => "#$part_index")
    text = replace(text, "{{QPARTWEIGHT}}" => "$(p.weight)")
    
    type_code = ""
    if p.answer_type == NumberFormula
        type_code = "0"
        # TODO: expand into other types, is it needed?
    end
    text = replace(text, "{{QPARTTYPE}}" => type_code) 

    # TODO: add more than one subpart / answer
    tolerances = []
    if isempty(p.tolerances)
        tolerances = 0.1*ones(length(p.answers))
    else
        @assert size(p.answers) == size(p.tolerances)
        tolerances = p.tolerances
    end

    LOCVARDICT = Dict("ANS" => p.answers, "TOL" => tolerances)
    
    text = replace(text, "{{QPARTLOCALVARS}}" => parse_to_formula_variables(LOCVARDICT))

    answer_text = "ANS[idx]"
    text = replace(text, "{{QPARTANSWER}}" => answer_text)
    grading_variables_text = ""

    if p.grading_strategy == RelativeError
        grading_variables_text = """
        rAns = _relerr <= TOL[idx];""" 
    elseif p.grading_strategy == AbsoluteError
        grading_variables_text = """
        rAns = _err <= TOL[idx];""" 
    end
    if ~isempty(p.unit)
            # TODO: add unit grading 
    end

    text = replace(text, "{{QPARTUNIT}}" => "$(p.unit)")
    text = replace(text, "{{QPARTUNITPENALTY}}" => "$(p.unit_penalty)")

    text = replace(text, "{{QPARTGRADINGVARS}}" => grading_variables_text)

    grading_criteria_text = "rAns"
    text = replace(text, "{{QPARTGRADINGCRITERIA}}" => grading_criteria_text)

    text = replace(text, "{{QPARTNUMSUBPARTS}}" => "1")

    return text
end


function parse_to_formula_variables(d::Dict)
    # Convert arrays to text and
    # TODO: add latex delimeters to tex interpolated elements
    text = ""
    for pair in d 
        arr = pair[2]
        if length(arr) == 1
            text *= "$(pair[1]) = [$(arr[1])]";
        else
            text *= "$(pair[1]) = ["
            for (k,e) in enumerate(arr)
                text *= k == length(arr) ? "$e];\n" : "$e, "; 
            end
        end
    end


    return text
end

function generate_formula_question(q::Assessments.FormulaQuestion)
    
    templatefile = normpath(Assessments.TEMPLATE_DIR, "formula_qtype.xml.in")
    text = read(templatefile, String)
    
    text = replace(text, "{{QCATEGORY}}" => "\$course\$/$(q.category)")

    text = replace(text, "{{QTITLE}}" => q.title)
    text = replace(text, "{{QDEFAULTGRADE}}" => q.default_grade)

    statement = q.statement
    for k in 1:length(q.parts)
        statement *= """

        {#$k}
        """
    end

    text = replace(text, "{{QSTATEMENT}}" => parse_to_html_text(statement))
    text = replace(text, "{{QGLOBALVARS}}" => parse_to_formula_variables(q.global_variables))
    text = replace(text, "{{QRANDOMVARS}}" => "idx = {0:$(q.instances)};")

    answers = ""

    for (k,p) in enumerate(q.parts)
        answers *= """
        $(parse_to_formula_part(p,k))
        """
    end

    text = replace(text, "{{QANSWERS}}" => answers)

    return text
end

export export_to_formula
function export_to_formula(q::Assessments.FormulaQuestion)
    # Parse main question 
    xml_text = generate_formula_question(q)
    io = open("$(q.filename).xml", "w")
    write(io, xml_text)
    close(io)
end