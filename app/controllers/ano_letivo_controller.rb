class AnoLetivosController < ApplicationController
	# GET /ano_letivos
	# GET /ano_letivos.xml
	before_filter :verificar_ano,:except=>[:new,:create,:update,:edit,:destroy]
	def index
		@ano_letivos = AnoLetivo.all.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
		
		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :xml => @ano_letivos }
		end
	end

	# GET /ano_letivos/1
	# GET /ano_letivos/1.xml
	def show
		@ano_letivo = AnoLetivo.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @ano_letivo }
		end
	end

	# GET /ano_letivos/new
	# GET /ano_letivos/new.xml
	def new
		@escola = Escola.find(params[:escola_id])
		@ano_letivo = @escola.anos_letivos.new
		render :layout=>nil
	end

	# GET /ano_letivos/1/edit
	def edit
		@ano_letivo = AnoLetivo.find(params[:id])
	end

	# POST /ano_letivos
	# POST /ano_letivos.xml
	def create
		@ano_letivo = AnoLetivo.new(params[:ano_letivo])
		ano ||= @ano_letivo.inicio.year
        @escola = Escola.find params[:escola_id]
        @ano_letivo.ano = ano

		respond_to do |format|
			if @ano_letivo.save
				redirect_to escola_ano_letivo_settings_url(@escola,@ano_letivo)
				
			else
				format.html { render :action => "new" }
				format.xml  { render :xml => @ano_letivo.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /ano_letivos/1
	# PUT /ano_letivos/1.xml
	def update
		@ano_letivo = AnoLetivo.find(params[:id])

		respond_to do |format|
			if @ano_letivo.update_attributes(params[:ano_letivo])
				format.html { redirect_to(@ano_letivo, :notice => 'Ano letivo atualizado com sucesso.') }
				format.xml  { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml  { render :xml => @ano_letivo.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /ano_letivos/1
	# DELETE /ano_letivos/1.xml
	def destroy
		@ano_letivo = AnoLetivo.find(params[:id])
		@ano_letivo.destroy

		respond_to do |format|
			format.html { redirect_to(ano_letivos_url) }
			format.xml  { head :ok }
		end
	end

	private
	def verificar_ano
		@escola = Escola.find params[:escola_id]
		#@ano_letivo = @escola.anos_letivos.find(params[:ano_letivo])
    end
end
