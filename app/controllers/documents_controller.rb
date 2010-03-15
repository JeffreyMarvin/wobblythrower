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
    doc.write data, 0
    
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
    doc.write data, 0
    
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
    new_doc = REXML::Document.new
    new_doc << doc.xml_decl
    new_doc << doc.doctype
    new_element = doc.elements[1].clone
    new_element = parse_children(new_element, doc.elements[1].children) if doc.elements[1].has_elements?
    new_doc.add_element(new_element)
    return new_doc
  end
  
  def parse_children(parent, children)
    children.each do |child|
      if child.respond_to?("has_elements?")
        if child.has_elements?
          new_element = REXML::Element.new("div")
          new_element.add_attribute("class", child.name)
          new_element.add_attributes(child.attributes) if child.has_attributes?
          new_element = parse_children(new_element, child.children) if child.has_elements?
          parent.add_element(new_element)
        elsif child.has_text?
          if child.name == 'p' || child.name == 'img' || child.name == 'b'
            new_element = child.clone
            new_element.add_text(child.get_text)
            parent.add_element(new_element)
          elsif child.name == 'heading'
            name = "h" + child.attributes["level"]
            child.attributes.delete "level"
            new_element = REXML::Element.new(name)
            new_element.add_attributes(child.attributes) if child.has_attributes?
            new_element.add_text(child.get_text)
            parent.add_element(new_element)
          else
            new_element = REXML::Element.new("div")
            new_element.add_attribute("class", child.name)
            new_element.add_attributes(child.attributes) if child.has_attributes?
            new_element.add_text(child.get_text)
            parent.add_element(new_element)
          end
        else
            new_element = REXML::Element.new("div")
            new_element.add_attribute("class", child.name)
            new_element.add_attributes(child.attributes) if child.has_attributes?
            parent.add_element(new_element)
        end
      else
#        parent.add_element(child)
      end
    end
    return parent
  end

end
