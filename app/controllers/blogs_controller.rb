class BlogsController < ApplicationController
  before_action :authorized

  # GET /blogs
  def index
    user = current_user

    @blogs = Blog.find_by(user: user)

    render json: @blogs
  end

  # GET /blogs/1
  def show
    @blog = Blog.find_by(id: params[:id])
    user = current_user

    unless @blog&.user == user
      render json: { error: "Blog not found" }, status: :not_found
      return
    end

    render json: @blog
  end

  # POST /blogs
  def create
    category = Category.find_by(id: blog_params[:category_id])

    # Return an error if the category is not found
    unless category
      render json: { error: "Category not found" }, status: :not_found
      return
    end

    user = current_user

    @blog = Blog.new(blog_params)

    # Assign the current user and category to the blog
    @blog.user = user      # assuming the Blog model has a `user` association
    @blog.category = category  # assuming the Blog model has a `category` association

    if @blog.save
      render json: @blog, status: :created, location: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /blogs/1
  def update
    @blog = Blog.find_by(id: params[:id])
    user = current_user

    unless @blog&.user == user
      render json: { error: "Blog not found" }, status: :not_found
      return
    end

    if @blog.update(blog_params)
      render json: @blog
    else
      render json: @blog.errors, status: :unprocessable_entity
    end
  end

  # DELETE /blogs/1
  def destroy
    @blog = Blog.find_by(id: params[:id])
    user = current_user

    unless @blog&.user == user
      render json: { error: "Blog not found" }, status: :not_found
      return
    end

    @blog.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      @blog = Blog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def blog_params
      params.permit(:title, :body, :category_id)
    end
end
