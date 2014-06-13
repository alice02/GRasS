class ManagementsController < ApplicationController

  def index
  	@management = Management.find(1)
  end
  
  def destroy
  	@management = Management.find(1)
  	@management.state = false
  	if @management.save
  		redirect_to managements_path, notice: '計測を終了しました！' 
  	end
  end

end
