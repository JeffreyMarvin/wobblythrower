class CommentsController < ApplicationController

  def create
    @comment = Comment.new({:comment_text => params[:comment_text], :document_id => params[:document_id], :node_id => params[:node_id]})
    @comment.save
  end

  def show
    @comment = Comment.all(:conditions => "document_id = #{params[:id]} AND node_id = '#{params[:node_id]}'", :order => "created_at DESC") 
  end

end
