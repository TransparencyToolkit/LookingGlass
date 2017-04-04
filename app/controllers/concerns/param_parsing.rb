module ParamParsing
  # Calculate start and page num from URL params
  def page_calc(params)
    # Set page number from params
    pagenum = params[:page] ? params[:page].to_i : 1

    # Calculate start index for docs
    start = pagenum*30-30
    return pagenum, start
  end
end
