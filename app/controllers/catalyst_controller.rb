class CatalystController < ApplicationController

  def builder
    render 'catalyst/builder'
  end

  def jobs
    render 'catalyst/jobs'
  end

end
