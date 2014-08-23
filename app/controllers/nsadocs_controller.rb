class NsadocsController < ApplicationController
  before_action :set_nsadoc, only: [:show, :edit, :update, :destroy]

  # GET /nsadocs
  # GET /nsadocs.json
  def index
    @nsadocs = Nsadoc.all
  end

  # GET /nsadocs/1
  # GET /nsadocs/1.json
  def show
  end

  # GET /nsadocs/new
  def new
    @nsadoc = Nsadoc.new
  end

  # GET /nsadocs/1/edit
  def edit
  end

  # POST /nsadocs
  # POST /nsadocs.json
  def create
    @nsadoc = Nsadoc.new(nsadoc_params)

    respond_to do |format|
      if @nsadoc.save
        format.html { redirect_to @nsadoc, notice: 'Nsadoc was successfully created.' }
        format.json { render :show, status: :created, location: @nsadoc }
      else
        format.html { render :new }
        format.json { render json: @nsadoc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nsadocs/1
  # PATCH/PUT /nsadocs/1.json
  def update
    respond_to do |format|
      if @nsadoc.update(nsadoc_params)
        format.html { redirect_to @nsadoc, notice: 'Nsadoc was successfully updated.' }
        format.json { render :show, status: :ok, location: @nsadoc }
      else
        format.html { render :edit }
        format.json { render json: @nsadoc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nsadocs/1
  # DELETE /nsadocs/1.json
  def destroy
    @nsadoc.destroy
    respond_to do |format|
      format.html { redirect_to nsadocs_url, notice: 'Nsadoc was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nsadoc
      @nsadoc = Nsadoc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def nsadoc_params
      params.require(:nsadoc).permit(:release_date, :released_by, :article_url, :title, :doc_path, :type, :legal_authority, :records_collected, :creation_date, :doc_text, :aclu_desc, :sigads, :codewords, :programs, :countries)
    end
end
