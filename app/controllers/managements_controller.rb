# -*- coding: utf-8 -*-
class ManagementsController < ApplicationController
  
  def edit
    @management = Management.find(1)
  end
  
  
  def update
    @management = Management.find(1)
    if @management.update(params[:management].permit(:kei))
      redirect_to measurements_path, notice: '更新されました！'
    else
      render action: 'edit'
    end
  end

  def reset_db
    `rake -f /home/pi/gomihiroi/grass/Rakefile db:migrate:reset && rake -f /home/pi/gomihiroi/grass/Rakefile db:seed`
    redirect_to measurements_path, notice: 'データベースが正常にリセットされました！'
  end
  
end
