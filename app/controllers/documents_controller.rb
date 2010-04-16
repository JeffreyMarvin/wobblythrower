require 'zip/zip'
require 'RMagick'

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
    
    file = params[:uploaded_file]
    
#    if file.path.downcase =~ /.xml/
#      doc = REXML::Document.new uploaded_file
#    elsif file.path.downcase =~ /.zip/
      zip = Zip::ZipFile.open(file.path)
      FileUtils.mkdir_p ("public/assets/xml/" + File.dirname(zip.each.entries[1].name))
      FileUtils.mkdir_p "public" + (str = "/images/" + File.dirname(zip.each.entries[1].name))
      doc = REXML::Document.new
      
      zip.each do |single_file|
        if single_file.name.downcase =~ /.xml/
          path = File.join("public/assets/xml/", single_file.name)
          File.delete(path) if File.exist?(path)
          single_file.extract(path)
          doc = REXML::Document.new File.new(path)
        elsif single_file.name =~ /\./
          path = File.join("public/images/", single_file.name)
          puts path
          File.delete(path) if File.file?(path)
          single_file.extract(path)
          img = Magick::ImageList.new(path)
          img.write(path[0..(path =~ /\./)] + "png")
          File.delete(path) if File.file?(path)
        end
      end
      
#    else
#      format.html { render :action => "new" }
#      format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
#    end  
      doc = parse_xml(doc, str)
      data = ""
      doc.write data, -1
#      flash[:notice] = str
    
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
    doc.write data, -1
    
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
  
  def parse_xml(doc, path_to_images)
    new_doc = REXML::Document.new
    new_doc << doc.xml_decl
    new_doc << doc.doctype
    new_element = doc.elements[1].clone
    new_element = parse_children(new_element, doc.elements[1].children, path_to_images) if doc.elements[1].has_elements?
    new_doc.add_element(new_element)
    return new_doc
  end
  
  def parse_children(parent, children, path_to_images)
    children.each do |child|
      if child.respond_to?("has_elements?")
        if child.name == 'tables'
          new_element = REXML::Element.new("div")
          new_element.add_attribute("class", child.name)
          new_element.add_attributes(child.attributes) if child.has_attributes?
          child.children.each do |table|
            new_element = parse_table(new_element, table)
          end   
            if(!new_element.attributes["id"].nil?)
              new_element.add_attribute({"class" => "commentable"})
            end
          parent.add_element(new_element)
        elsif child.name == 'img'
          new_element = REXML::Element.new("img")
          child.attributes.each do |key, value|
            if key == "file"
              new_element.add_attribute("src", File.join(path_to_images, value[0..(value =~ /\./)] + "png"))
            elsif key == "img-format"
              new_element.add_attribute("img-format", "png")
          else
              new_element.add_attribute(key, value)
            end
          end   
            if(!new_element.attributes["id"].nil?)
              new_element.add_attribute({"class" => "commentable"})
            end
          parent.add_element(new_element)
        elsif child.has_text?
          if child.name == 'p' || child.name == 'b'|| child.name == 'i' || child.name == 'u'
            new_element = child.clone
            new_element = parse_children(new_element, child.children, path_to_images) if child.has_elements? || child.has_text?
              if(!new_element.attributes["id"].nil?)
                new_element.add_attribute({"class" => "commentable"})
              end
            parent.add_element(new_element)
          elsif child.name == 'heading'
            name = "h" + child.attributes["level"]
            child.attributes.delete "level"
            new_element = REXML::Element.new(name)
            new_element.add_attributes(child.attributes) if child.has_attributes?
            new_element = parse_children(new_element, child.children, path_to_images) if child.has_elements? || child.has_text?
              if(!new_element.attributes["id"].nil?)
                new_element.add_attribute({"class" => "commentable"})
              end
            parent.add_element(new_element)
          else
            new_element = REXML::Element.new("div")
            new_element.add_attribute("class", child.name)
            new_element.add_attributes(child.attributes) if child.has_attributes?
            new_element = parse_children(new_element, child.children, path_to_images) if child.has_elements? || child.has_text?
              if(!new_element.attributes["id"].nil?)
                new_element.add_attribute({"class" => "commentable"})
              end
            parent.add_element(new_element)
          end
        elsif child.has_elements?  
            new_element = REXML::Element.new("div")
            new_element.add_attribute("class", child.name)
            new_element.add_attributes(child.attributes) if child.has_attributes?
            new_element = parse_children(new_element, child.children, path_to_images) if child.has_elements? || child.has_text?
              if(!new_element.attributes["id"].nil?)
                new_element.add_attribute({"class" => "commentable"})
              end
            parent.add_element(new_element)
        else
            new_element = REXML::Element.new("div")
            new_element.add_attribute("class", child.name)
            new_element.add_attributes(child.attributes) if child.has_attributes?
            new_element = parse_children(new_element, child.children, path_to_images) if child.has_elements? || child.has_text?
              if(!new_element.attributes["id"].nil?)
                new_element.add_attribute({"class" => "commentable"})
              end
            parent.add_element(new_element)
        end
      elsif child.is_a? REXML::Text
        child.raw = true
        parent.add_text(child)
      end
    end
    return parent
  end
  
  def parse_table(parent, child)
    if child.respond_to? "name"
      table = child.clone
      child.elements.each do |group|
        tgroup = REXML::Element.new("div")
        tgroup.add_attribute("class", group.name)
        tgroup.add_attributes(group.attributes) if group.has_attributes?
        group.elements.each do |e|
          if(e.name == "colspec")
            colspec = REXML::Element.new("div")
            colspec.add_attribute("class", e.name)
            colspec.add_attributes(e.attributes) if e.has_attributes?
            tgroup.add_element colspec
          else
            thread = REXML::Element.new("div")
            thread.add_attribute("class", e.name)
            thread.add_attributes(e.attributes) if e.has_attributes?
            e.elements.each do |r|
              row = REXML::Element.new("tr")
              row.add_attributes(r.attributes) if r.has_attributes?
              n = 1
              r.elements.each do |c|
                cell = REXML::Element.new("td")
                cell.add_attributes(c.attributes) if c.has_attributes?
                if c.has_text?
                  c.get_text.raw = true
                  cell.add_text(c.text)
                else
                  nbsp = REXML::Text.new "&nbsp;"
                  nbsp.raw = true
                  cell.add_text(nbsp)
                end
                row.add_element cell
                n = n + 1
              end
=begin
              if(n < tgroup.attributes["cols"])
                for i in n..(tgroup.attributes["cols"])
                  cell = REXML::Element.new("td")
                  cell.add_text("&nbsp;")
                  row.add_element cell
                end
              end
=end
              thread.add_element row
            end
            tgroup.add_element thread
          end
        end
        table.add_element tgroup
      end
      parent.add_element table
    end
    return parent
  end
  
end
