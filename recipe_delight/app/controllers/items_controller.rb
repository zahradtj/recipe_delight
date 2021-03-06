class ItemsController < ApplicationController
    
    def index
    end

    def search
        #logger.info "*********************** #{params.inspect}"
        #redirect_to root_path
        #@hash = JSON.load(open("http://api.target.com/v2/products/11678018?idType=TCIN&key=J5PsS2XGuqCnkdQq0Let6RSfvU7oyPwF"))
        @bar_codes = Array.new
        @amounts_saved = Array.new
        @prices = Array.new
        @official_prices = Array.new
        @return_policies = Array.new
        @percentages_saved = Array.new
        @thumbnails = Array.new
        @titles = Array.new
        @product_count = 0
        
        @hash = JSON.load(open("https://api.target.com/v2/products/search?searchTerm=#{params[:Search]}&key=J5PsS2XGuqCnkdQq0Let6RSfvU7oyPwF"))
        #logger.info "*********************** #{@hash["CatalogEntryView"][0]["CustomerReview"][0]["Reviews"]}"
        #@product_id = Array.new
        #@product_id = @product_id.paginate(:page => params[:page], :per_page => 10)
        @reviews = Array.new
        @product_ids = Array.new
        #logger.info("******* #{@hash}")
        @hash["CatalogEntryView"].each do |product| 
            @product_ids << product["partNumber"]
        end
        @pub_dates = Array.new
        @product_ids.each do |id|
            @product_count += 1
            @new_hash = JSON.load(open("https://api.target.com/v2/products/#{id}?idType=TCIN&key=J5PsS2XGuqCnkdQq0Let6RSfvU7oyPwF"))
            #logger.info"**************#{@new_hash}"
            logger.info"**************#{@product_ids.count}"
            @new_hash["CatalogEntryView"].each do |info|
                #Item pictures
                info["Images"].each do |images|
                    if !images["ThumbnailImage"].nil?
                        images["ThumbnailImage"].each do |thumbnail|
                            @thumbnails << thumbnail["image"]
                        end
                    end
                end

                #Item Attributes
                info["ItemAttributes"].each do |attributes|
                    attributes["Attribute"].each do |attribute|
                        if attribute["identifier"] == "PRIMARY_BARCODE"
                            @bar_codes << attribute["value"]                     
                        end 
                    end

                end
                info["Offers"].each do |offers|
                    logger.info "**** Offers hash #{offers}"
                    if offers["AmountSaved"].nil?
                        @amounts_saved << nil
                    else
                        offers["AmountSaved"].each do |offer|
                            @amounts_saved << offer["formattedPriceValue"]
                        end
                    end
                    if offers["ListPrice"].nil?
                        @prices << nil
                    else
                        offers["ListPrice"].each do |offer|
                            @prices << offer["formattedPriceValue"]
                        end
                    end

                    if offers["OfferPrice"].nil?
                        @official_prices << nil
                    else
                        offers["OfferPrice"].each do |offer|
                            @official_prices << offer["formattedPriceValue"]
                        end
                    end
                    @percentages_saved << offers["percentageSaved"]
                end
                @titles << info["title"]
            end
        end
        logger.info "******************* Titles #{@titles} #{@titles.count}"
        logger.info "******************* img urls #{@thumbnails} #{@thumbnails.count}"
        logger.info "******************* Barcodes #{@bar_codes}"
        logger.info "******************* Amounts Saved #{@amounts_saved}"
        logger.info "******************* Prices #{@prices}"
        logger.info "******************* Official Prices #{@official_prices}"
        logger.info "******************* Percentages Saved #{@percentages_saved}"

    end
    
    def new
        @item = Item.find(params[:id])
    end

    def create
        @item = Item.create(item_params)
        if @item.save
            flash[:success] = "Your item was successfully created."
            redirect_to @item
        else
            flash[:error] = @item.errors.full_messages.to_sentence
        end
    end

    def edit
        @item = Item.find(params[:id])
    end

    def update
        @item = Item.find(params[:id])
        if @item.update_attributes(item_params)
            flash[:success] = "Item #{item.name} was successfully created."
            redirect_to @item
        else
            flash[:error] = "There was an error updating #{item.name}."
        end
    end
    
    def destroy
    end

    private

    def item_params
        params.require(:items).permit!
    end
end
