class DocumentsController < ApplicationController
  # GET /documents
  # GET /documents.xml
  def index
    @documents = Document.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @documents }
    end
  end

  # GET /documents/1
  # GET /documents/1.xml
  def show
    @document = Document.find(params[:id])
    @documentversion = @document.versions.find(:all)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /documents/new
  # GET /documents/new.xml
  def new
    @document = Document.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /documents/1/edit
  def edit
    @document = Document.find(params[:id])
  end

  # POST /documents
  # POST /documents.xml
  def create
    
    uploaded_file = params[:xml_file]
    doc = REXML::Document.new uploaded_file
    doc = parse_xml(doc)
    data = ""
    doc.write data
    
#    data = uploaded_file.read if uploaded_file.respond_to? :read
    
    @document = Document.new({:title => params[:title], :content => data})
    
#    @document = Document.new(params[:document])

    respond_to do |format|
      if @document.save
        flash[:notice] = 'Document was successfully created.'
        format.html { redirect_to(@document) }
        format.xml  { render :xml => @document, :status => :created, :location => @document }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.xml
  def update
    
    uploaded_file = params[:xml_file]
    doc = REXML::Document.new uploaded_file
    doc = parse_xml(doc)
    data = ""
    doc.write data
    
#    data = uploaded_file.read if uploaded_file.respond_to? :read
    
    @document = Document.find(params[:id])

    respond_to do |format|
      if @document.update_attributes({:title => params[:title], :content => data})
        flash[:notice] = 'Document was successfully updated.'
        format.html { redirect_to(@document) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.xml
  def destroy
    @document = Document.find(params[:id])
    @document.destroy

    respond_to do |format|
      format.html { redirect_to(documents_url) }
      format.xml  { head :ok }
    end
  end
  
  def revert_to_version
    @document = Document.find(params[:document_id])
    @document.revert_to! params[:version_id]

    redirect_to :action => 'show', :id => @document
  end

  # GET /show_version/1
  # GET /show_version/1.xml
  def show_version
    @document = Document.find(params[:id])
    @version = @document.revert_to(params[:version_id])
    @documentversion = @document.versions.find(:all)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /diff_versions/1?version_id=2
  def diff_versions
    @document = Document.find(params[:id])
    @version = Document.find(params[:id])
    @versioner = @version.revert_to(params[:version_id])
    @documentversion = @document.versions.find(:all)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document }
    end
  end
  
  def parse_xml(doc)
    return doc
  end

end
