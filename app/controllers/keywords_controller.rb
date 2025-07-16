class KeywordsController < ApplicationController
  def index
    render json: Keyword.all
  end

  def show
    render json: Keyword.find(params[:id])
  end

  def create
    keyword = Keyword.create!(keyword_params)
    render json: keyword, status: :created
  end

  def update
    keyword = Keyword.find(params[:id])
    keyword.update!(keyword_params)
    render json: keyword
  end

  def destroy
    keyword = Keyword.find(params[:id])
    keyword.destroy
    head :no_content
  end

  private

  def keyword_params
    params.require(:keyword).permit(:word)
  end
end