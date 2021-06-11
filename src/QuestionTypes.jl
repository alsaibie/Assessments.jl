using Parameters
using Dates

# All Assessment question types are defined here

export HomeworkHeader
@with_kw mutable struct HomeworkHeader
    course_number::String = " "
    assignment_type::String = "Homework"
    course_name::String = " "
    course_section::Int = 1
    semester::String = " "
    assignment_number::Int = 1
    due_date::DateTime = DateTime(2000,1,1,23,59)
    instructions::String = " "
    print_solution::Bool = true
    force_new_page::Bool = false
end

export HomeworkQuestion
@with_kw mutable struct HomeworkQuestion
    # Homework Type 
    title::String = "Question"
    problem::String = "statement"
    solution::String = "answer"
    points::Int = 1
end

export ExamHeader
@with_kw mutable struct ExamHeader
    course_number::String = ""
    exam_type::String = "Midterm"
    course_name::String = ""
    course_section::Int = 1
    university_name::String = ""
    college_name::String = ""
    instructor_name::String = ""
    semester::String = " "
    exam_number::Int = 1
    exam_date::DateTime = DateTime(2000,1,1,23,59)
    instructions::String = " "
    print_solution::Bool = true
    force_new_page::Bool = true
    version::String = "A"
end

export ExamQuestion
@with_kw mutable struct ExamQuestion
    # Exam Question Type 
    title::String = "Question"
    problem::String = "statement"
    variation::String = "" 
    solution::String = "answer"
    points::Int = 1
end

export MCQQuestion
@with_kw mutable struct MCQQuestion
    # Multiple Choice Question with Single Correct Answer
    # Compatible with: ALL
    filename::String = "default"
    category::String = " "
    title::String = "MCQ Question"
    statement::String = "statement"
    right_ans::String = " "
    wrong_ans::Array{String} = []
    feedback::String = " "
    # compatibility = "ALL";
end

export MCQMQuestion
@with_kw mutable struct MCQMQuestion
    # Multiple Choice Question with Multiple Correct Answers
    filename::String = "default"
    category::String = " "
    title::String = "MCQM Question"
    statement::String = "statement"
    right_ans::Array{String} = []
    wrong_ans::Array{String} = []
    feedback::String = " "
    strategy::String = "WinLose"
end

export EssayQuestion
@with_kw mutable struct EssayQuestion
    # Essay Type 
    filename::String = "default"
    category::String = " "
    title::String = "Essay Question"
    statement::String = "statement"
    response_template::String = " "
    feedback::String = " "
end

export NumericalQuestion
@with_kw mutable struct NumericalQuestion
    filename::String = "default"
    category::String = " "
    title::String = "Numerical Question"
    statement::String = "statement"
    right_ans::Number = 0
    tolerance::Number = 0
    feedback::String = " "
end

export MatchQuestion
@with_kw mutable struct MatchQuestion
    # Moodle Matching Question
    # Compatible with: Moodle
    filename::String = "default"
    category::String = " "
    title::String = "Matching Question"
    statement::String = "Statement"
    answer_pairs::Array{Tuple} = []
    feedback::String = " "
    # compatibility = "ALL";
end

export FormulaPartType
@enum FormulaPartType NumberFormula NumericFormula NumericalFormula AlgebraicFormula

export FormulaPartGradingStrategy
@enum FormulaPartGradingStrategy RelativeError AbsoluteError 

export FormulaQPart
@with_kw mutable struct FormulaQPart
    question::String = "Part Question"
    answer_type::FormulaPartType = NumberFormula
    weight::Real = 1
    # random_variables::Dict{String, Array} = Dict{String, Array}()
    # grading_variables::Dict{String, Array} = Dict{String, Array}()
    answers::Array{Real} = [] #TODO: make type union between number and array?
    grading_strategy::FormulaPartGradingStrategy = RelativeError
    tolerances::Array{Real} = [] # Used with AbsoluteError
    unit::String = ""
    unit_penalty::Real = 0.2
    feedback::String = "Part Feedback"
    # index = 0 # TODO: auto-increment based on order?
    # placeholder::String = "{#1}" # Should be automatically set by parsing
    # subparts = [] # Future implementation
end

export FormulaQuestion
@with_kw mutable struct FormulaQuestion
    filename::String = "formula_default"
    category::String = " "
    title::String = "Formula Question"
    statement::String = "Main Statement"
    parts::Array{FormulaQPart} = []
    global_variables::Dict{String, Array} = Dict{String, Array}()
    default_grade = 5
    instances = 1
end



