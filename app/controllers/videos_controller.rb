class VideosController < ApplicationController
  before_action :require_video, only: [:show]

  def index
    if params[:query]
      data = VideoWrapper.search(params[:query])
    else
      data = Video.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @video.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  def create
    unless Video.find_by(external_id: params[:external_id])
      video = Video.new(video_params)
      if video.save
        render(
          status: :ok,
          json: video.as_json
        )
      else
        render(
          status: :bad_request,
          errors: video.errors
        )
      end
    end
  end

  private

  def require_video
    @video = Video.find_by(title: params[:title])
    unless @video
      render status: :not_found, json: { errors: { title: ["No video with title #{params["title"]}"] } }
    end
  end

  def video_params
    params.permit(:title, :overview, :release_date, :inventory, :created_at, :updated_at, :image_url, :external_id)
  end
end
