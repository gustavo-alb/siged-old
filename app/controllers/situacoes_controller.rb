class SituacoesController < ApplicationController
  before_filter :set_situacao, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @q = Situacao.ransack(params[:q])
    @situacoes = @q.result.all.paginate :page => params[:page], :per_page => 10
    respond_with(@situacoes)
  end

  def show
    respond_with(@situacao)
  end

  def new
    @situacao = Situacao.new
    respond_with(@situacao)
  end

  def edit
  end

  def create
    @situacao = Situacao.new(params[:situacao])
    @situacao.save
    respond_with(@situacao)
  end

  def update
    @situacao.update_attributes(params[:situacao])
    respond_with(@situacao)
  end

  def destroy
    @situacao.destroy
    respond_with(@situacao)
  end

  private
    def set_situacao
      @situacao = Situacao.find(params[:id])
    end
end
