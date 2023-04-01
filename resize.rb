require 'tty-option'
require "rmagick"

include Magick

class Resize
  include TTY::Option

  WEB_MAX_DIMENSION = 500
  THUMB_MAX_DIMENSION = 50

  usage do
    header 'RESIZING TIME BABY'

    command 'run'

    desc 'resize an image'

    example 'Resize the image to have a maximum width of 200 pixels', '  $ resize ~/UsErS/roydonk/images/pong.png -w 200'
  end

  argument :image_file do
    required
    desc 'path to image file'
  end

  keyword :out_path do
    desc 'path for image output'
  end

  option :width do
    short '-w'
    long '--width int'
    convert :int
    desc 'output width'
  end

  option :height do
    short '-h'
    long '--height int'
    convert :int
    desc 'output height'
  end

  flag :web do
    long '--web bool'
    desc 'output for web (500px max either dimension)'
  end

  flag :thumb do
    long '--thumb bool'
    desc 'output for thumbnail (50px max either dimension)'
  end

  flag :help do
    long "--help"
    desc "get help"
  end

  def run
    if params[:help]
      print help
      exit
    else
      img = Image.read(params[:image_file]).first

      # TODO refactor to share resize ability across other commands
      width = img.columns
      height = img.rows

      puts "image #{img.filename} loaded at #{width}x#{height}"

      if params[:height]
        out_height = params[:out_height]
        out_width = out_height * width / height
      else
        out_width = if !params[:width].nil?
                      params[:width]
                    elsif params[:web].nil?
                      WEB_MAX_DIMENSION
                    elsif params[:thumb].nil?
                      THUMB_MAX_DIMENSION
                    end
        out_height = out_width * height / width
      end

      puts "calculated new dimensions: #{out_width}x#{out_height}"

      new_img = img.resize(out_width, out_height)

      puts "resized image"

      unless params[:out_path].nil?
        new_img.write(params[:out_path])
        exit
      end
      new_img.write("./#{img.filename.split('/').last}")
    end
  end
end

Resize.new.parse.run
