class CommentsController < ApplicationController
  before_filter :admin_required, :except => [:create]
  
  layout 'main'
  
  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    @item = Item.find(params[:item_id])
    @comment.item = @item
    
    if logged_in?
      @comment.user = current_user
    else
      @comment.byline = "Anonymous Coward" if @comment.byline.empty?
      @comment.content = @comment.content.gsub(/((<a\s+.*?href.+?\".*?\")([^\>]*?)>)/, '\2 rel="nofollow" \3>')
      unless Digest::SHA1.hexdigest(params[:captcha].upcase.chomp)[0..5] == params[:captcha_guide]
        @item.errors.add("Word")
        flash.now[:notice] = "Votre commentaire ne peut être posté. Veuillez réessayer en faisant attention au Captcha."
        render :template => 'items/show'
        return
      end
    end
    

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Commentaire créé.'
        format.html { redirect_to(@comment.item) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        flash.now[:notice] = "Votre commentaire ne peut être poster. Veuillez corriger et réessayer."
        format.html { render :template => 'items/show' }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Commentaire mis à jour'
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end
