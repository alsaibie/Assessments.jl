using Parameters
# All JuliaAssessment question types are defined here

export HomeworkQuestion
@with_kw mutable struct HomeworkQuestion
    # Homework Type 
    title::String = "Essay Question"
    problem::String = "statement"
    solution::String = " "
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

