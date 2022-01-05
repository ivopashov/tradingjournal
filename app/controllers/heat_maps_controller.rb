class HeatMapsController < ApplicationController
    def index
        @heat_maps = HeatMap.where user_id: current_user.id
    end

    def new
        @heat_map = HeatMap.new
    end

    def create
        tickers = parse_param_tickers_to_list

        @heat_map = HeatMap.new tickers: tickers.join(','), name: heat_map_params[:name], user_id: current_user.id

        if @heat_map.save
            DailyQuotes.delay.backfill tickers
            redirect_to action: :index
        else
            render :new, heat_map: @heat_map
        end
    end

    def show
        @heat_map = HeatMap.find params["id"]
        @data = HeatMapService.new.get @heat_map
        @name = @heat_map.name
        @periods = ["1d", "1w", "1m", "3m"]
    end

    def edit
        @heat_map = HeatMap.find params["id"]
    end

    def update
        @heat_map = HeatMap.find params["id"]
        @heat_map.name = heat_map_params["name"]

        tickers = parse_param_tickers_to_list
        extra_tickers = tickers - @heat_map.tickers.split(",")

        @heat_map.tickers = tickers.join(",")

        if @heat_map.save
            if !extra_tickers.empty?
                DailyQuotes.delay.backfill extra_tickers
            end

            redirect_to action: :index
        else
            render :edit, heat_map: @heat_map
        end
    end

    def destroy
        @heat_map = HeatMap.find params["id"]
        @heat_map.destroy

        flash.notice = "Heat map '#{@heat_map.name}' was deleted"

        redirect_to action: :index
    end

    private

    def parse_param_tickers_to_list
        heat_map_params['tickers'].
            split(',').
            map(&:strip).
            reject(&:empty?).
            map(&:upcase)
    end

    def heat_map_params
        secure_params = params.require(:heat_map).permit(:tickers, :name)
        secure_params
    end
end