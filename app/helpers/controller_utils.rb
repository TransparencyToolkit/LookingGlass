module ControllerUtils
  # Calculate start and page num
  def page_calc(params)    
    pagenum = params[:page] ? params[:page].to_i : 1
    start = pagenum*30-30

    return pagenum, start
  end
end
