class BranchesController < ApplicationController
  before_action :set_branch, only: [:show, :edit, :update, :destroy, :add_packages, :auto_add]

  # GET /branches
  # GET /branches.json
  def index
    @branches = Branch.all
  end

  # GET /branches/1
  # GET /branches/1.json
  def show
    @debfiles = Debfile.all.map {|d| [d.name, d.id] }
  end

  # GET /branches/new
  def new
    @branch = Branch.new
  end

  # GET /branches/1/edit
  def edit
  end

  # POST /branches
  # POST /branches.json
  def create
    @branch = Branch.new(branch_params)

    respond_to do |format|
      if @branch.save
        format.html { redirect_to @branch, notice: 'Branch was successfully created.' }
        format.json { render :show, status: :created, location: @branch }
      else
        format.html { render :new }
        format.json { render json: @branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /branches/1
  # PATCH/PUT /branches/1.json
  def update
    respond_to do |format|
      if @branch.update(branch_params)
        format.html { redirect_to @branch, notice: 'Branch was successfully updated.' }
        format.json { render :show, status: :ok, location: @branch }
      else
        format.html { render :edit }
        format.json { render json: @branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /branches/1
  # DELETE /branches/1.json
  def destroy
    @branch.destroy
    respond_to do |format|
      format.html { redirect_to branches_url, notice: 'Branch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_packages
    service = Services::PackageAssignment.new(@branch)
    result = service.process(params[:debfile_ids])
    
    redirect_to :back, flash: result
  end

  def auto_add
    name = Package.find(params[:package_id]).name
    if @branch.auto_added?(name)
      @branch.stop_auto_adding(name)
      msg = "The package #{name} will not be automatically added anymore"
    else
      @branch.auto_add(name)
      msg = "The package #{name} will be automatically added when a new version is added to the library"
    end

    if @branch.save and @branch.auto_added?(name)
      flash = {success: msg}
    else
      flash = {error: "Failed to save the changes"}
    end

    redirect_to :back, flash: flash
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branch
      @branch = Branch.find(params[:id] || params[:branch_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def branch_params
      params.require(:branch).permit(:name, :project_id, :debfile_ids, :branch_id, :repo_name, :package_id)
    end
end
