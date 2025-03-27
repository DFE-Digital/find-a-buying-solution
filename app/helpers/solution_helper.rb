module SolutionHelper
  def solution_cta(solution)
    solution.call_to_action || t(".cta", title: solution.title)
  end
end
