module SolutionHelper
  def solution_cta(solution)
    solution.call_to_action.presence || ct("solutions.show.cta", title: solution.title)
  end
end
