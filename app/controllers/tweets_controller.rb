class TweetsController < ApplicationController
  def index
    @tweets = Tweet.all.order(created_at: :desc)
    render 'tweets/index'
  end

  def create
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)
    user = session.user
    @tweet = user.tweets.new(tweet_params)

    # render 'tweets/create' if @tweet.save

    if @tweet.save
      TweetMailer.notify(@tweet).deliver! # invoke TweetMailer to send out the email when a tweet is successfully posted
      render 'tweets/create'
    end
  end

  def destroy
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)

    return render json: { success: false } unless session

    user = session.user
    tweet = Tweet.find_by(id: params[:id])

    if tweet && (tweet.user == user) && tweet.destroy
      render json: {
        success: true
      }
    else
      render json: {
        success: false
      }
    end
  end

  def index_by_user
    user = User.find_by(username: params[:username])

    if user
      @tweets = user.tweets
      render 'tweets/index'
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:message, :image)
  end
end
